part of '../app_database.dart';

class PayrollItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get companyId => integer()
      .named('company_id')
      .references(Companies, #id, onDelete: KeyAction.cascade)();

  IntColumn get payrollRunId => integer()
      .named('payroll_run_id')
      .references(PayrollRuns, #id, onDelete: KeyAction.cascade)();

  IntColumn get employeeId => integer()
      .named('employee_id')
      .references(Employees, #id, onDelete: KeyAction.cascade)();

  TextColumn get employeeType => text().named('employee_type')();

  RealColumn get baseSalary => real().named('base_salary')();

  RealColumn get workedDays => real().named('worked_days')();

  RealColumn get workedHours => real().named('worked_hours')();

  RealColumn get overtimeHours => real().named('overtime_hours')();

  RealColumn get overtimePay =>
      real().named('overtime_pay').withDefault(const Constant(0))();

  RealColumn get ordinaryNightHours =>
      real().named('ordinary_night_hours').withDefault(const Constant(0))();

  RealColumn get ordinaryNightSurchargePay => real()
      .named('ordinary_night_surcharge_pay')
      .withDefault(const Constant(0))();

  RealColumn get grossPay => real().named('gross_pay')();

  RealColumn get familyBonus =>
      real().named('family_bonus').withDefault(const Constant(0))();

  RealColumn get ipsEmployee => real().named('ips_employee')();

  RealColumn get ipsEmployer => real().named('ips_employer')();

  RealColumn get advancesTotal => real().named('advances_total')();

  RealColumn get attendanceDiscount =>
      real().named('attendance_discount').withDefault(const Constant(0))();

  RealColumn get otherDiscount =>
      real().named('other_discount').withDefault(const Constant(0))();

  RealColumn get embargoAmount => real().named('embargo_amount').nullable()();

  TextColumn get embargoAccount => text().named('embargo_account').nullable()();

  RealColumn get netPay => real().named('net_pay')();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').clientDefault(() => DateTime.now())();
}

