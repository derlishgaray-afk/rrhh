import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../security/security_constants.dart';
import 'authorization_service.dart';

class CompanyService {
  CompanyService(
    this._companiesDao,
    this._settingsDao,
    this._companySettingsDao,
    this._securityDao,
    this._authorizationService,
  );

  static const String activeCompanySettingKey = 'active_company_id';

  final CompaniesDao _companiesDao;
  final SettingsDao _settingsDao;
  final CompanySettingsDao _companySettingsDao;
  final SecurityDao _securityDao;
  final AuthorizationService _authorizationService;

  Future<int> createCompany({
    required String name,
    String? abbreviation,
    String? ruc,
    String? address,
    String? phone,
    String? mjtEmployerNumber,
    Uint8List? logoPng,
    bool active = true,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.companiesCreate,
    );

    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre de la empresa es obligatorio.');
    }

    final companyId = await _companiesDao.insertCompany(
      CompaniesCompanion.insert(
        name: normalizedName,
        abbreviation: _toOptionalValue(abbreviation),
        ruc: _toOptionalValue(ruc),
        address: _toOptionalValue(address),
        phone: _toOptionalValue(phone),
        mjtEmployerNumber: _toOptionalValue(mjtEmployerNumber),
        logoPng: Value(logoPng),
        active: Value(active),
      ),
    );
    final template = await _companySettingsDao.getMostRecentlyUpdatedSettings(
      excludeCompanyId: companyId,
    );
    await _companySettingsDao.upsertCompanySettings(
      template == null
          ? CompanySettingsCompanion.insert(companyId: Value(companyId))
          : CompanySettingsCompanion.insert(
              companyId: Value(companyId),
              ipsEmployeeRate: Value(template.ipsEmployeeRate),
              ipsEmployerRate: Value(template.ipsEmployerRate),
              minimumWage: Value(template.minimumWage),
              familyBonusRate: Value(template.familyBonusRate),
              overtimeDayRate: Value(template.overtimeDayRate),
              overtimeNightRate: Value(template.overtimeNightRate),
              ordinaryNightSurchargeRate: Value(
                template.ordinaryNightSurchargeRate,
              ),
              ordinaryNightStart: Value(template.ordinaryNightStart),
              ordinaryNightEnd: Value(template.ordinaryNightEnd),
              overtimeDayStart: Value(template.overtimeDayStart),
              overtimeDayEnd: Value(template.overtimeDayEnd),
              overtimeNightStart: Value(template.overtimeNightStart),
              overtimeNightEnd: Value(template.overtimeNightEnd),
              holidayDates: Value(template.holidayDates),
              updatedAt: Value(DateTime.now()),
            ),
    );

    await _grantSuperAdminAccessToCompany(companyId);

    final activeCompany = await getActiveCompany();
    if (activeCompany == null) {
      await setActiveCompany(companyId);
    }

    return companyId;
  }

  Future<bool> updateCompany({
    required Company currentCompany,
    required String name,
    String? abbreviation,
    String? ruc,
    String? address,
    String? phone,
    String? mjtEmployerNumber,
    Uint8List? logoPng,
    required bool active,
  }) {
    return _updateCompanyWithPermission(
      currentCompany: currentCompany,
      name: name,
      abbreviation: abbreviation,
      ruc: ruc,
      address: address,
      phone: phone,
      mjtEmployerNumber: mjtEmployerNumber,
      logoPng: logoPng,
      active: active,
    );
  }

  Future<bool> _updateCompanyWithPermission({
    required Company currentCompany,
    required String name,
    String? abbreviation,
    String? ruc,
    String? address,
    String? phone,
    String? mjtEmployerNumber,
    Uint8List? logoPng,
    required bool active,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.companiesUpdate,
      companyId: currentCompany.id,
    );

    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre de la empresa es obligatorio.');
    }

    final updatedCompany = currentCompany.copyWith(
      name: normalizedName,
      abbreviation: Value(_toOptionalString(abbreviation)),
      ruc: Value(_toOptionalString(ruc)),
      address: Value(_toOptionalString(address)),
      phone: Value(_toOptionalString(phone)),
      mjtEmployerNumber: Value(_toOptionalString(mjtEmployerNumber)),
      logoPng: Value(logoPng),
      active: active,
    );

    return _companiesDao.updateCompany(updatedCompany);
  }

  Future<void> deleteCompany(int companyId) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.companiesDelete,
      companyId: companyId,
    );

    if (companyId <= 0) {
      throw ArgumentError('La empresa no es valida.');
    }

    final hasMovements = await _companiesDao.hasMovements(companyId);
    if (hasMovements) {
      throw ArgumentError(
        'No se puede eliminar la empresa porque tiene movimientos registrados.',
      );
    }

    final activeCompanyId = await getActiveCompanyId();
    await _companiesDao.deleteCompany(companyId);

    if (activeCompanyId == companyId) {
      final companies = await listCompanies();
      if (companies.isEmpty) {
        await _settingsDao.deleteSetting(activeCompanySettingKey);
      } else {
        await setActiveCompany(companies.first.id);
      }
    }
  }

  Future<List<Company>> listCompanies() {
    return _authorizationService.listAccessibleCompanies();
  }

  Future<Company?> getCompanyById(int companyId) async {
    await _authorizationService.ensureCompanyAccess(companyId);
    return _companiesDao.getCompanyById(companyId);
  }

  Future<int?> getActiveCompanyId() async {
    final setting = await _settingsDao.getSetting(activeCompanySettingKey);
    if (setting?.value == null) {
      return null;
    }
    return int.tryParse(setting!.value!);
  }

  Future<Company?> getActiveCompany() async {
    final activeCompanyId = await getActiveCompanyId();
    final accessibleCompanies = await listCompanies();
    if (accessibleCompanies.isEmpty) {
      return null;
    }

    if (activeCompanyId != null) {
      final activeCompany = await _companiesDao.getCompanyById(activeCompanyId);
      if (activeCompany != null &&
          accessibleCompanies.any(
            (company) => company.id == activeCompany.id,
          )) {
        return activeCompany;
      }
    }

    final fallbackCompany = accessibleCompanies.firstWhere(
      (company) => company.active,
      orElse: () => accessibleCompanies.first,
    );

    await setActiveCompany(fallbackCompany.id);
    return fallbackCompany;
  }

  Future<void> setActiveCompany(int companyId) async {
    await _authorizationService.ensureCompanyAccess(companyId);

    final company = await _companiesDao.getCompanyById(companyId);
    if (company == null) {
      throw ArgumentError('La empresa seleccionada no existe.');
    }

    await _settingsDao.upsertSetting(
      activeCompanySettingKey,
      companyId.toString(),
    );
  }

  Future<void> _grantSuperAdminAccessToCompany(int companyId) async {
    final superAdminRole = await _securityDao.getRoleByName(
      RoleNames.superAdmin,
    );
    if (superAdminRole == null) {
      return;
    }

    final existingAccess = await _securityDao.getUserCompanyAccessByRole(
      superAdminRole.id,
    );
    final superAdminUserIds = existingAccess
        .map((access) => access.userId)
        .toSet();
    final defaultAdmin = await _securityDao.getUserByUsername(
      SecurityBootstrap.defaultSuperAdminUsername,
    );
    if (defaultAdmin != null) {
      superAdminUserIds.add(defaultAdmin.id);
    }

    for (final userId in superAdminUserIds) {
      await _securityDao.upsertUserCompanyAccess(
        UserCompanyAccessCompanion.insert(
          userId: userId,
          companyId: companyId,
          roleId: superAdminRole.id,
          active: const Value(true),
        ),
      );
    }
  }

  Value<String?> _toOptionalValue(String? value) {
    return Value(_toOptionalString(value));
  }

  String? _toOptionalString(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
