part of '../app_database.dart';

class Employees extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get companyId => integer()
      .named('company_id')
      .references(Companies, #id, onDelete: KeyAction.cascade)();

  TextColumn get firstNames =>
      text().named('first_names').withDefault(const Constant(''))();

  TextColumn get lastNames =>
      text().named('last_names').withDefault(const Constant(''))();

  TextColumn get fullName => text().named('full_name')();

  TextColumn get documentNumber => text().named('document_number')();

  IntColumn get departmentId => integer()
      .named('department_id')
      .nullable()
      .references(Departments, #id, onDelete: KeyAction.setNull)();

  IntColumn get sectorId => integer()
      .named('sector_id')
      .nullable()
      .references(DepartmentSectors, #id, onDelete: KeyAction.setNull)();

  TextColumn get jobTitle => text().named('job_title').nullable()();

  TextColumn get workLocation => text().named('work_location').nullable()();

  DateTimeColumn get hireDate => dateTime().named('hire_date')();

  TextColumn get employeeType => text()
      .named('employee_type')
      .customConstraint(
        "NOT NULL CHECK (employee_type IN ('mensual', 'jornalero', 'servicio'))",
      )();

  RealColumn get baseSalary => real().named('base_salary')();

  BoolColumn get ipsEnabled =>
      boolean().named('ips_enabled').withDefault(const Constant(true))();

  IntColumn get childrenCount =>
      integer().named('children_count').withDefault(const Constant(0))();

  BoolColumn get allowOvertime =>
      boolean().named('allow_overtime').withDefault(const Constant(true))();

  BoolColumn get biometricClockEnabled => boolean()
      .named('biometric_clock_enabled')
      .withDefault(const Constant(true))();

  BoolColumn get hasEmbargo =>
      boolean().named('has_embargo').withDefault(const Constant(false))();

  TextColumn get embargoAccount => text().named('embargo_account').nullable()();

  RealColumn get embargoAmount => real().named('embargo_amount').nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get workStartTime1 =>
      text().named('work_start_time_1').withDefault(const Constant('06:00'))();

  TextColumn get workStartTime2 =>
      text().named('work_start_time_2').withDefault(const Constant('15:00'))();

  TextColumn get workStartTime3 =>
      text().named('work_start_time_3').withDefault(const Constant('18:00'))();

  TextColumn get workStartTimeSaturday =>
      text().named('work_start_time_saturday').nullable()();

  TextColumn get workEndTimeSaturday =>
      text().named('work_end_time_saturday').nullable()();

  BoolColumn get active => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').clientDefault(() => DateTime.now())();
}

