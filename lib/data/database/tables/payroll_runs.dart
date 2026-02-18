part of '../app_database.dart';

class PayrollRuns extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get companyId => integer()
      .named('company_id')
      .references(Companies, #id, onDelete: KeyAction.cascade)();

  IntColumn get year => integer()();

  IntColumn get month => integer()();

  DateTimeColumn get generatedAt =>
      dateTime().named('generated_at').withDefault(currentDateAndTime)();

  TextColumn get notes => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, year, month},
  ];
}
