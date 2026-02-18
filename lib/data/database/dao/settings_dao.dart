part of '../app_database.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<AppSetting?> getSetting(String settingKey) {
    return (select(
      appSettings,
    )..where((tbl) => tbl.key.equals(settingKey))).getSingleOrNull();
  }

  Future<void> upsertSetting(String settingKey, String? settingValue) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: settingKey, value: Value(settingValue)),
    );
  }

  Future<int> deleteSetting(String settingKey) {
    return (delete(
      appSettings,
    )..where((tbl) => tbl.key.equals(settingKey))).go();
  }
}
