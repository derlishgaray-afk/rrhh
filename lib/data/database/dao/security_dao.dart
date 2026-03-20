part of '../app_database.dart';

@DriftAccessor(
  tables: [
    Users,
    Roles,
    Permissions,
    RolePermissions,
    UserCompanyAccess,
    Companies,
  ],
)
class SecurityDao extends DatabaseAccessor<AppDatabase>
    with _$SecurityDaoMixin {
  SecurityDao(super.db);

  Future<User?> getUserById(int userId) {
    return (select(
      users,
    )..where((tbl) => tbl.id.equals(userId))).getSingleOrNull();
  }

  Future<User?> getUserByUsername(String username) {
    final normalized = username.trim();
    return (select(
      users,
    )..where((tbl) => tbl.username.equals(normalized))).getSingleOrNull();
  }

  Future<int> insertUser(UsersCompanion companion) {
    return into(users).insert(companion);
  }

  Future<bool> updateUser(User user) {
    return update(users).replace(user);
  }

  Future<List<User>> getUsers() {
    return (select(
      users,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.username)])).get();
  }

  Future<Role?> getRoleById(int roleId) {
    return (select(
      roles,
    )..where((tbl) => tbl.id.equals(roleId))).getSingleOrNull();
  }

  Future<Role?> getRoleByName(String roleName) {
    return (select(
      roles,
    )..where((tbl) => tbl.name.equals(roleName))).getSingleOrNull();
  }

  Future<int> insertRole(RolesCompanion companion) {
    return into(roles).insert(companion);
  }

  Future<bool> updateRole(Role role) {
    return update(roles).replace(role);
  }

  Future<List<Role>> getRoles() {
    return (select(
      roles,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.name)])).get();
  }

  Future<int> deleteRole(int roleId) {
    return (delete(roles)..where((tbl) => tbl.id.equals(roleId))).go();
  }

  Future<Permission?> getPermissionByKey(String permissionKey) {
    return (select(
      permissions,
    )..where((tbl) => tbl.key.equals(permissionKey))).getSingleOrNull();
  }

  Future<int> insertPermission(PermissionsCompanion companion) {
    return into(permissions).insert(companion);
  }

  Future<bool> updatePermission(Permission permission) {
    return update(permissions).replace(permission);
  }

  Future<List<Permission>> getPermissions() {
    return (select(
      permissions,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.key)])).get();
  }

  Future<int> insertRolePermission(RolePermissionsCompanion companion) {
    return into(rolePermissions).insert(companion);
  }

  Future<int> deleteRolePermissionsByRole(int roleId) {
    return (delete(
      rolePermissions,
    )..where((tbl) => tbl.roleId.equals(roleId))).go();
  }

  Future<List<RolePermission>> getRolePermissionsByRole(int roleId) {
    return (select(
      rolePermissions,
    )..where((tbl) => tbl.roleId.equals(roleId))).get();
  }

  Future<List<Permission>> getPermissionsByRole(int roleId) {
    final joined = select(rolePermissions).join([
      innerJoin(
        permissions,
        permissions.id.equalsExp(rolePermissions.permissionId),
      ),
    ])..where(rolePermissions.roleId.equals(roleId));

    return joined.map((row) => row.readTable(permissions)).get();
  }

  Future<UserCompanyAccessData?> getUserCompanyAccess({
    required int userId,
    required int companyId,
  }) {
    return (select(userCompanyAccess)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.companyId.equals(companyId),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> upsertUserCompanyAccess(
    UserCompanyAccessCompanion companion,
  ) async {
    final userId = companion.userId.present ? companion.userId.value : null;
    final companyId = companion.companyId.present
        ? companion.companyId.value
        : null;
    if (userId == null || companyId == null) {
      throw ArgumentError('userId y companyId son obligatorios.');
    }

    final existing =
        await (select(userCompanyAccess)
              ..where(
                (tbl) =>
                    tbl.userId.equals(userId) & tbl.companyId.equals(companyId),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)]))
            .get();

    if (existing.isEmpty) {
      return into(userCompanyAccess).insert(companion);
    }

    final primary = existing.first;
    final roleId = companion.roleId.present
        ? companion.roleId
        : Value(primary.roleId);
    final active = companion.active.present
        ? companion.active
        : Value(primary.active);

    await (update(userCompanyAccess)..where((tbl) => tbl.id.equals(primary.id)))
        .write(UserCompanyAccessCompanion(roleId: roleId, active: active));

    if (existing.length > 1) {
      final duplicateIds = existing.skip(1).map((row) => row.id).toList();
      await (delete(
        userCompanyAccess,
      )..where((tbl) => tbl.id.isIn(duplicateIds))).go();
    }

    return primary.id;
  }

  Future<List<UserCompanyAccessData>> getUserCompanyAccessByUser(int userId) {
    return (select(userCompanyAccess)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.companyId)]))
        .get();
  }

  Future<List<UserCompanyAccessData>> getUserCompanyAccessByRole(int roleId) {
    return (select(
      userCompanyAccess,
    )..where((tbl) => tbl.roleId.equals(roleId))).get();
  }

  Future<int> deleteUserCompanyAccessByUser(int userId) {
    return (delete(
      userCompanyAccess,
    )..where((tbl) => tbl.userId.equals(userId))).go();
  }

  Future<List<Company>> getCompaniesByUserAccess(int userId) {
    final query = select(companies).join([
      innerJoin(
        userCompanyAccess,
        userCompanyAccess.companyId.equalsExp(companies.id) &
            userCompanyAccess.userId.equals(userId) &
            userCompanyAccess.active.equals(true),
      ),
    ])..orderBy([OrderingTerm.asc(companies.name)]);

    return query.map((row) => row.readTable(companies)).get();
  }

  Future<List<RolePermission>> getRolePermissions() {
    return select(rolePermissions).get();
  }
}
