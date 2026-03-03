import 'dart:io';

import '../data/database/app_database.dart';
import '../security/security_constants.dart';
import 'company_service.dart';

class AuthorizationService {
  AuthorizationService(
    this._settingsDao,
    this._securityDao,
    this._companiesDao,
  );

  final SettingsDao _settingsDao;
  final SecurityDao _securityDao;
  final CompaniesDao _companiesDao;
  String? _sessionSettingKeyCache;

  Future<int?> getCurrentUserId() async {
    final setting = await _settingsDao.getSetting(_sessionSettingKey);
    final raw = setting?.value?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw);
  }

  Future<User?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      return null;
    }
    final user = await _securityDao.getUserById(userId);
    if (user == null || !user.active) {
      await clearCurrentUser();
      return null;
    }
    return user;
  }

  Future<void> setCurrentUser(int userId) {
    return _settingsDao.upsertSetting(_sessionSettingKey, '$userId');
  }

  Future<void> clearCurrentUser() {
    return _settingsDao.deleteSetting(_sessionSettingKey);
  }

  Future<bool> isSuperAdmin() async {
    final user = await getCurrentUser();
    if (user == null) {
      return false;
    }

    final companiesCount = await _companiesDao.getCompanies().then(
      (value) => value.length,
    );
    if (companiesCount == 0 &&
        user.username.trim().toLowerCase() ==
            SecurityBootstrap.defaultSuperAdminUsername.toLowerCase()) {
      return true;
    }

    final superRole = await _securityDao.getRoleByName(RoleNames.superAdmin);
    if (superRole == null) {
      return false;
    }
    final accesses = await _securityDao.getUserCompanyAccessByUser(user.id);
    return accesses.any(
      (access) => access.active && access.roleId == superRole.id,
    );
  }

  Future<void> ensureSuperAdmin({
    String message = 'Operacion permitida solo para SUPER_ADMIN.',
  }) async {
    final isAllowed = await isSuperAdmin();
    if (!isAllowed) {
      throw StateError(message);
    }
  }

  Future<List<Company>> listAccessibleCompanies() async {
    final user = await getCurrentUser();
    if (user == null) {
      return const [];
    }

    if (await isSuperAdmin()) {
      return _companiesDao.getCompanies();
    }
    return _securityDao.getCompaniesByUserAccess(user.id);
  }

  Future<bool> hasPermission(String permissionKey, {int? companyId}) async {
    final user = await getCurrentUser();
    if (user == null) {
      return false;
    }

    if (await isSuperAdmin()) {
      return true;
    }

    if (PermissionKeys.superAdminOnly.contains(permissionKey)) {
      return false;
    }

    final effectiveCompanyId = companyId ?? await _getActiveCompanyId();
    if (effectiveCompanyId == null) {
      return false;
    }

    final access = await _securityDao.getUserCompanyAccess(
      userId: user.id,
      companyId: effectiveCompanyId,
    );
    if (access == null || !access.active) {
      return false;
    }

    final permissions = await _securityDao.getPermissionsByRole(access.roleId);
    return permissions.any((permission) => permission.key == permissionKey);
  }

  Future<void> ensurePermission(
    String permissionKey, {
    int? companyId,
    String? message,
  }) async {
    final allowed = await hasPermission(permissionKey, companyId: companyId);
    if (!allowed) {
      throw StateError(message ?? 'No tiene permiso: $permissionKey');
    }
  }

  Future<void> ensureCompanyAccess(int companyId) async {
    final allowedCompanies = await listAccessibleCompanies();
    if (!allowedCompanies.any((company) => company.id == companyId)) {
      throw StateError('No tiene acceso a la empresa seleccionada.');
    }
  }

  Future<Set<String>> permissionsForCompany(int companyId) async {
    final user = await getCurrentUser();
    if (user == null) {
      return const <String>{};
    }

    if (await isSuperAdmin()) {
      return PermissionKeys.all.toSet();
    }

    final access = await _securityDao.getUserCompanyAccess(
      userId: user.id,
      companyId: companyId,
    );
    if (access == null || !access.active) {
      return const <String>{};
    }

    final permissions = await _securityDao.getPermissionsByRole(access.roleId);
    return permissions.map((permission) => permission.key).toSet();
  }

  Future<int?> _getActiveCompanyId() async {
    final setting = await _settingsDao.getSetting(
      CompanyService.activeCompanySettingKey,
    );
    final raw = setting?.value?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw);
  }

  String get _sessionSettingKey {
    if (_sessionSettingKeyCache != null) {
      return _sessionSettingKeyCache!;
    }

    final rawMachineId =
        Platform.environment['COMPUTERNAME']?.trim().isNotEmpty == true
        ? Platform.environment['COMPUTERNAME']!.trim()
        : Platform.localHostname.trim();
    final normalizedMachineId = rawMachineId.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_-]+'),
      '_',
    );
    final machineId = normalizedMachineId.isEmpty
        ? 'unknown_machine'
        : normalizedMachineId;

    _sessionSettingKeyCache =
        '${SecuritySettingKeys.currentUserIdByDevicePrefix}$machineId';
    return _sessionSettingKeyCache!;
  }
}
