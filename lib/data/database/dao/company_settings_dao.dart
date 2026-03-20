part of '../app_database.dart';

@DriftAccessor(tables: [CompanySettings])
class CompanySettingsDao extends DatabaseAccessor<AppDatabase>
    with _$CompanySettingsDaoMixin {
  CompanySettingsDao(super.db);

  Future<CompanySetting?> getCompanySettings(int companyId) async {
    final rows =
        await (select(companySettings)
              ..where((tbl) => tbl.companyId.equals(companyId))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
              ..limit(1))
            .get();
    if (rows.isEmpty) {
      return null;
    }
    return rows.first;
  }

  Future<void> upsertCompanySettings(CompanySettingsCompanion settings) async {
    final sanitized = settings.copyWith(updatedAt: const Value.absent());
    final companyId = settings.companyId.present
        ? settings.companyId.value
        : null;
    if (companyId == null || companyId <= 0) {
      throw ArgumentError(
        'companyId es obligatorio para guardar configuracion.',
      );
    }

    final updatedRows = await (update(
      companySettings,
    )..where((tbl) => tbl.companyId.equals(companyId))).write(sanitized);
    if (updatedRows > 0) {
      return;
    }

    try {
      await into(companySettings).insert(sanitized);
    } catch (_) {
      await (update(
        companySettings,
      )..where((tbl) => tbl.companyId.equals(companyId))).write(sanitized);
    }
  }

  Future<bool> updateCompanySettings(CompanySetting settings) async {
    final updatedRows =
        await (update(
          companySettings,
        )..where((tbl) => tbl.companyId.equals(settings.companyId))).write(
          CompanySettingsCompanion(
            ipsEmployeeRate: Value(settings.ipsEmployeeRate),
            ipsEmployerRate: Value(settings.ipsEmployerRate),
            minimumWage: Value(settings.minimumWage),
            familyBonusRate: Value(settings.familyBonusRate),
            overtimeDayRate: Value(settings.overtimeDayRate),
            overtimeNightRate: Value(settings.overtimeNightRate),
            ordinaryNightSurchargeRate: Value(
              settings.ordinaryNightSurchargeRate,
            ),
            ordinaryNightStart: Value(settings.ordinaryNightStart),
            ordinaryNightEnd: Value(settings.ordinaryNightEnd),
            overtimeDayStart: Value(settings.overtimeDayStart),
            overtimeDayEnd: Value(settings.overtimeDayEnd),
            overtimeNightStart: Value(settings.overtimeNightStart),
            overtimeNightEnd: Value(settings.overtimeNightEnd),
            holidayDates: Value(settings.holidayDates),
            lateArrivalToleranceMinutes: Value(
              settings.lateArrivalToleranceMinutes,
            ),
            lateArrivalAllowedTimesPerMonth: Value(
              settings.lateArrivalAllowedTimesPerMonth,
            ),
          ),
        );
    return updatedRows > 0;
  }

  Future<List<CompanySetting>> listCompanySettings() {
    return select(companySettings).get();
  }

  Future<CompanySetting?> getMostRecentlyUpdatedSettings({
    int? excludeCompanyId,
  }) async {
    final query = select(companySettings);
    if (excludeCompanyId != null) {
      query.where((tbl) => tbl.companyId.isNotValue(excludeCompanyId));
    }
    query
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
      ..limit(1);

    final rows = await query.get();
    if (rows.isEmpty) {
      return null;
    }
    return rows.first;
  }
}
