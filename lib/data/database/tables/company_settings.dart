part of '../app_database.dart';

class CompanySettings extends Table {
  IntColumn get companyId => integer()
      .named('company_id')
      .references(Companies, #id, onDelete: KeyAction.cascade)();

  RealColumn get ipsEmployeeRate =>
      real().named('ips_employee_rate').withDefault(const Constant(0.09))();

  RealColumn get ipsEmployerRate =>
      real().named('ips_employer_rate').withDefault(const Constant(0.165))();

  RealColumn get minimumWage =>
      real().named('minimum_wage').withDefault(const Constant(0))();

  RealColumn get familyBonusRate =>
      real().named('family_bonus_rate').withDefault(const Constant(0))();

  RealColumn get overtimeDayRate =>
      real().named('overtime_day_rate').withDefault(const Constant(0.5))();

  RealColumn get overtimeNightRate =>
      real().named('overtime_night_rate').withDefault(const Constant(1.0))();

  RealColumn get ordinaryNightSurchargeRate => real()
      .named('ordinary_night_surcharge_rate')
      .withDefault(const Constant(0.3))();

  TextColumn get ordinaryNightStart => text()
      .named('ordinary_night_start')
      .withDefault(const Constant('20:00'))();

  TextColumn get ordinaryNightEnd =>
      text().named('ordinary_night_end').withDefault(const Constant('06:00'))();

  TextColumn get overtimeDayStart =>
      text().named('overtime_day_start').withDefault(const Constant('06:00'))();

  TextColumn get overtimeDayEnd =>
      text().named('overtime_day_end').withDefault(const Constant('20:00'))();

  TextColumn get overtimeNightStart => text()
      .named('overtime_night_start')
      .withDefault(const Constant('20:00'))();

  TextColumn get overtimeNightEnd =>
      text().named('overtime_night_end').withDefault(const Constant('06:00'))();

  TextColumn get holidayDates =>
      text().named('holiday_dates').withDefault(const Constant('[]'))();

  IntColumn get lateArrivalToleranceMinutes => integer()
      .named('late_arrival_tolerance_minutes')
      .withDefault(const Constant(0))();

  IntColumn get lateArrivalAllowedTimesPerMonth => integer()
      .named('late_arrival_allowed_times_per_month')
      .withDefault(const Constant(0))();

  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {companyId};
}
