import 'package:drift/drift.dart';

import '../data/database/app_database.dart';

class CompanyService {
  CompanyService(
    this._companiesDao,
    this._settingsDao,
    this._companySettingsDao,
  );

  static const String activeCompanySettingKey = 'active_company_id';

  final CompaniesDao _companiesDao;
  final SettingsDao _settingsDao;
  final CompanySettingsDao _companySettingsDao;

  Future<int> createCompany({
    required String name,
    String? ruc,
    String? address,
    String? phone,
    bool active = true,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre de la empresa es obligatorio.');
    }

    final companyId = await _companiesDao.insertCompany(
      CompaniesCompanion.insert(
        name: normalizedName,
        ruc: _toOptionalValue(ruc),
        address: _toOptionalValue(address),
        phone: _toOptionalValue(phone),
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

    final activeCompany = await getActiveCompany();
    if (activeCompany == null) {
      await setActiveCompany(companyId);
    }

    return companyId;
  }

  Future<bool> updateCompany({
    required Company currentCompany,
    required String name,
    String? ruc,
    String? address,
    String? phone,
    required bool active,
  }) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre de la empresa es obligatorio.');
    }

    final updatedCompany = currentCompany.copyWith(
      name: normalizedName,
      ruc: Value(_toOptionalString(ruc)),
      address: Value(_toOptionalString(address)),
      phone: Value(_toOptionalString(phone)),
      active: active,
    );

    return _companiesDao.updateCompany(updatedCompany);
  }

  Future<void> deleteCompany(int companyId) async {
    if (companyId <= 0) {
      throw ArgumentError('La empresa no es valida.');
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
    return _companiesDao.getCompanies();
  }

  Future<Company?> getCompanyById(int companyId) {
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
    if (activeCompanyId != null) {
      final activeCompany = await _companiesDao.getCompanyById(activeCompanyId);
      if (activeCompany != null) {
        return activeCompany;
      }
    }

    final companies = await listCompanies();
    if (companies.isEmpty) {
      return null;
    }

    final fallbackCompany = companies.firstWhere(
      (company) => company.active,
      orElse: () => companies.first,
    );

    await setActiveCompany(fallbackCompany.id);
    return fallbackCompany;
  }

  Future<void> setActiveCompany(int companyId) async {
    final company = await _companiesDao.getCompanyById(companyId);
    if (company == null) {
      throw ArgumentError('La empresa seleccionada no existe.');
    }

    await _settingsDao.upsertSetting(
      activeCompanySettingKey,
      companyId.toString(),
    );
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
