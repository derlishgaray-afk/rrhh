part of '../app_database.dart';

class AttendanceEvents extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get companyId => integer()
      .named('company_id')
      .references(Companies, #id, onDelete: KeyAction.cascade)();

  IntColumn get employeeId => integer()
      .named('employee_id')
      .references(Employees, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get date => dateTime()();

  TextColumn get eventType => text()
      .named('event_type')
      .customConstraint(
        "NOT NULL CHECK (event_type IN ('presente', 'ausente', 'permiso_remunerado', 'permiso_no_remunerado', 'vacaciones', 'paternidad', 'duelo', 'reposo', 'tardanza'))",
      )();

  IntColumn get minutesLate => integer().named('minutes_late').nullable()();

  RealColumn get hoursWorked => real().named('hours_worked').nullable()();

  RealColumn get overtimeHours => real().named('overtime_hours').nullable()();

  TextColumn get overtimeType => text().named('overtime_type').nullable()();

  TextColumn get checkInTime => text().named('check_in_time').nullable()();

  TextColumn get checkOutTime => text().named('check_out_time').nullable()();

  IntColumn get breakMinutes => integer().named('break_minutes').nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
}
