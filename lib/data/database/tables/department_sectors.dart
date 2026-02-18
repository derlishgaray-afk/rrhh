part of '../app_database.dart';

class DepartmentSectors extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get departmentId => integer()
      .named('department_id')
      .references(Departments, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  BoolColumn get active => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {departmentId, name},
  ];
}
