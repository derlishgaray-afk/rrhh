part of '../app_database.dart';

@DriftAccessor(tables: [CompanySettings])
class CompanySettingsDao extends DatabaseAccessor<AppDatabase>
    with _$CompanySettingsDaoMixin {
  CompanySettingsDao(super.db);

  Future<CompanySetting?> getCompanySettings(int companyId) {
    return (select(
      companySettings,
    )..where((tbl) => tbl.companyId.equals(companyId))).getSingleOrNull();
  }

  Future<void> upsertCompanySettings(CompanySettingsCompanion settings) {
    return into(companySettings).insertOnConflictUpdate(settings);
  }

  Future<bool> updateCompanySettings(CompanySetting settings) {
    return update(companySettings).replace(settings);
  }

  Future<List<CompanySetting>> listCompanySettings() {
    return select(companySettings).get();
  }

  Future<CompanySetting?> getMostRecentlyUpdatedSettings({
    int? excludeCompanyId,
  }) {
    final query = select(companySettings);
    if (excludeCompanyId != null) {
      query.where((tbl) => tbl.companyId.isNotValue(excludeCompanyId));
    }
    query.orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]);
    query.limit(1);
    return query.getSingleOrNull();
  }
}
