part of '../app_database.dart';

class PayrollRuns extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get companyId => integer()
      .named('company_id')
      .references(Companies, #id, onDelete: KeyAction.cascade)();

  IntColumn get year => integer()();

  IntColumn get month => integer()();

  DateTimeColumn get generatedAt =>
      dateTime().named('generated_at').clientDefault(() => DateTime.now())();

  TextColumn get notes => text().nullable()();

  BoolColumn get isLocked =>
      boolean().named('is_locked').withDefault(const Constant(false))();

  DateTimeColumn get lockedAt => dateTime().named('locked_at').nullable()();

  IntColumn get lockedByUserId => integer()
      .named('locked_by_user_id')
      .nullable()
      .references(Users, #id, onDelete: KeyAction.setNull)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, year, month},
  ];
}

