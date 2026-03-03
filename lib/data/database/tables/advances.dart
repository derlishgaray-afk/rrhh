part of '../app_database.dart';

class Advances extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get companyId => integer()
      .named('company_id')
      .references(Companies, #id, onDelete: KeyAction.cascade)();

  IntColumn get employeeId => integer()
      .named('employee_id')
      .references(Employees, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get date => dateTime()();

  RealColumn get amount => real()();

  TextColumn get reason => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').clientDefault(() => DateTime.now())();
}

