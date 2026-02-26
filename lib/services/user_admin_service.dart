import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../security/password_hasher.dart';
import '../security/security_constants.dart';
import 'authorization_service.dart';

class UserAdminService {
  UserAdminService(this._securityDao, this._companiesDao, this._authorization);

  final SecurityDao _securityDao;
  final CompaniesDao _companiesDao;
  final AuthorizationService _authorization;

  Future<List<UserWithAccess>> listUsersDetailed() async {
    await _authorization.ensurePermission(PermissionKeys.usersRead);

    final users = await _securityDao.getUsers();
    final roles = await _securityDao.getRoles();
    final companies = await _companiesDao.getCompanies();
    final roleById = {for (final role in roles) role.id: role};
    final companyById = {for (final company in companies) company.id: company};

    final result = <UserWithAccess>[];
    for (final user in users) {
      final accesses = await _securityDao.getUserCompanyAccessByUser(user.id);
      final mappedAccesses = accesses
          .map((access) {
            final role = roleById[access.roleId];
            final company = companyById[access.companyId];
            if (role == null || company == null) {
              return null;
            }
            return UserAccessView(access: access, company: company, role: role);
          })
          .whereType<UserAccessView>()
          .toList();

      result.add(UserWithAccess(user: user, accesses: mappedAccesses));
    }

    return result;
  }

  Future<List<RoleWithPermissions>> listRolesDetailed() async {
    await _authorization.ensurePermission(PermissionKeys.rolesManage);

    final roles = await _securityDao.getRoles();
    final result = <RoleWithPermissions>[];
    for (final role in roles) {
      final permissions = await _securityDao.getPermissionsByRole(role.id);
      permissions.sort((a, b) => a.key.compareTo(b.key));
      result.add(RoleWithPermissions(role: role, permissions: permissions));
    }
    return result;
  }

  Future<List<Permission>> listPermissions() async {
    await _authorization.ensurePermission(PermissionKeys.rolesManage);
    return _securityDao.getPermissions();
  }

  Future<List<Company>> listCompanies() async {
    await _authorization.ensurePermission(PermissionKeys.usersRead);
    return _companiesDao.getCompanies();
  }

  Future<int> createRole({
    required String name,
    String? description,
    required Set<String> permissionKeys,
  }) async {
    await _authorization.ensurePermission(PermissionKeys.rolesManage);

    final normalizedName = name.trim().toUpperCase();
    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre del rol es obligatorio.');
    }

    final existing = await _securityDao.getRoleByName(normalizedName);
    if (existing != null) {
      throw ArgumentError('Ya existe un rol con ese nombre.');
    }

    final roleId = await _securityDao.insertRole(
      RolesCompanion.insert(
        name: normalizedName,
        description: Value(_normalizeOptional(description)),
      ),
    );

    await updateRolePermissions(roleId: roleId, permissionKeys: permissionKeys);
    return roleId;
  }

  Future<void> updateRolePermissions({
    required int roleId,
    required Set<String> permissionKeys,
  }) async {
    await _authorization.ensurePermission(PermissionKeys.rolesManage);

    final role = await _securityDao.getRoleById(roleId);
    if (role == null) {
      throw ArgumentError('El rol no existe.');
    }

    final permissions = await _securityDao.getPermissions();
    final permissionsByKey = {
      for (final permission in permissions) permission.key: permission,
    };

    Set<String> effectivePermissionKeys;
    if (role.name == RoleNames.superAdmin) {
      effectivePermissionKeys = PermissionKeys.all.toSet();
    } else {
      effectivePermissionKeys = permissionKeys
          .where((key) => !PermissionKeys.superAdminOnly.contains(key))
          .toSet();
    }

    await _securityDao.deleteRolePermissionsByRole(roleId);
    for (final permissionKey in effectivePermissionKeys) {
      final permission = permissionsByKey[permissionKey];
      if (permission == null) {
        continue;
      }
      await _securityDao.insertRolePermission(
        RolePermissionsCompanion.insert(
          roleId: roleId,
          permissionId: permission.id,
        ),
      );
    }
  }

  Future<int> createUser({
    required String username,
    required String password,
    required String fullName,
    bool active = true,
    required List<UserCompanyRoleAssignment> accesses,
  }) async {
    await _authorization.ensurePermission(PermissionKeys.usersCreate);

    final normalizedUsername = username.trim().toLowerCase();
    final normalizedFullName = fullName.trim();
    if (normalizedUsername.isEmpty || normalizedFullName.isEmpty) {
      throw ArgumentError('Usuario y nombre completo son obligatorios.');
    }
    if (password.trim().isEmpty) {
      throw ArgumentError('La contrasena es obligatoria.');
    }

    final existing = await _securityDao.getUserByUsername(normalizedUsername);
    if (existing != null) {
      throw ArgumentError('El usuario ya existe.');
    }

    final userId = await _securityDao.insertUser(
      UsersCompanion.insert(
        username: normalizedUsername,
        passwordHash: PasswordHasher.hash(
          username: normalizedUsername,
          password: password,
        ),
        fullName: normalizedFullName,
        active: Value(active),
      ),
    );

    await replaceUserCompanyAccess(userId: userId, accesses: accesses);
    return userId;
  }

  Future<void> updateUser({
    required int userId,
    required String fullName,
    required bool active,
    required List<UserCompanyRoleAssignment> accesses,
  }) async {
    await _authorization.ensurePermission(PermissionKeys.usersUpdate);

    final user = await _securityDao.getUserById(userId);
    if (user == null) {
      throw ArgumentError('El usuario no existe.');
    }

    final normalizedFullName = fullName.trim();
    if (normalizedFullName.isEmpty) {
      throw ArgumentError('El nombre completo es obligatorio.');
    }

    await _securityDao.updateUser(
      user.copyWith(fullName: normalizedFullName, active: active),
    );

    await replaceUserCompanyAccess(userId: userId, accesses: accesses);
  }

  Future<void> replaceUserCompanyAccess({
    required int userId,
    required List<UserCompanyRoleAssignment> accesses,
  }) async {
    await _authorization.ensurePermission(PermissionKeys.usersUpdate);

    final user = await _securityDao.getUserById(userId);
    if (user == null) {
      throw ArgumentError('El usuario no existe.');
    }

    final uniqueAccesses = <int, UserCompanyRoleAssignment>{};
    for (final access in accesses) {
      uniqueAccesses[access.companyId] = access;
    }

    await _securityDao.deleteUserCompanyAccessByUser(userId);
    var hasSuperAdminAssignment = false;
    int? superAdminRoleId;
    final superAdminRole = await _securityDao.getRoleByName(
      RoleNames.superAdmin,
    );
    if (superAdminRole != null) {
      superAdminRoleId = superAdminRole.id;
    }

    for (final access in uniqueAccesses.values) {
      final company = await _companiesDao.getCompanyById(access.companyId);
      final role = await _securityDao.getRoleById(access.roleId);
      if (company == null || role == null) {
        continue;
      }
      if (superAdminRoleId != null && access.roleId == superAdminRoleId) {
        hasSuperAdminAssignment = true;
      }
      await _securityDao.upsertUserCompanyAccess(
        UserCompanyAccessCompanion.insert(
          userId: userId,
          companyId: access.companyId,
          roleId: access.roleId,
          active: Value(access.active),
        ),
      );
    }

    if (hasSuperAdminAssignment && superAdminRoleId != null) {
      final companies = await _companiesDao.getCompanies();
      for (final company in companies) {
        await _securityDao.upsertUserCompanyAccess(
          UserCompanyAccessCompanion.insert(
            userId: userId,
            companyId: company.id,
            roleId: superAdminRoleId,
            active: const Value(true),
          ),
        );
      }
    }
  }

  Future<void> setUserActive({
    required int userId,
    required bool active,
  }) async {
    await _authorization.ensurePermission(PermissionKeys.usersDisable);

    final user = await _securityDao.getUserById(userId);
    if (user == null) {
      throw ArgumentError('El usuario no existe.');
    }
    await _securityDao.updateUser(user.copyWith(active: active));
  }

  Future<void> resetPassword({
    required int userId,
    required String newPassword,
  }) async {
    await _authorization.ensurePermission(PermissionKeys.usersResetPassword);

    final user = await _securityDao.getUserById(userId);
    if (user == null) {
      throw ArgumentError('El usuario no existe.');
    }
    final normalizedPassword = newPassword.trim();
    if (normalizedPassword.isEmpty) {
      throw ArgumentError('La nueva contrasena es obligatoria.');
    }

    final hash = PasswordHasher.hash(
      username: user.username,
      password: normalizedPassword,
    );
    await _securityDao.updateUser(user.copyWith(passwordHash: hash));
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}

class UserWithAccess {
  const UserWithAccess({required this.user, required this.accesses});

  final User user;
  final List<UserAccessView> accesses;
}

class UserAccessView {
  const UserAccessView({
    required this.access,
    required this.company,
    required this.role,
  });

  final UserCompanyAccessData access;
  final Company company;
  final Role role;
}

class RoleWithPermissions {
  const RoleWithPermissions({required this.role, required this.permissions});

  final Role role;
  final List<Permission> permissions;
}

class UserCompanyRoleAssignment {
  const UserCompanyRoleAssignment({
    required this.companyId,
    required this.roleId,
    this.active = true,
  });

  final int companyId;
  final int roleId;
  final bool active;
}
