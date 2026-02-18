import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'dao/advances_dao.dart';
part 'dao/attendance_dao.dart';
part 'dao/company_settings_dao.dart';
part 'dao/companies_dao.dart';
part 'dao/departments_dao.dart';
part 'dao/employees_dao.dart';
part 'dao/payroll_dao.dart';
part 'dao/settings_dao.dart';
part 'tables/advances.dart';
part 'tables/app_settings.dart';
part 'tables/attendance_events.dart';
part 'tables/company_settings.dart';
part 'tables/companies.dart';
part 'tables/departments.dart';
part 'tables/department_sectors.dart';
part 'tables/employees.dart';
part 'tables/payroll_items.dart';
part 'tables/payroll_runs.dart';
part 'app_database.g.dart';

const String _activeCompanySettingKey = 'active_company_id';

@DriftDatabase(
  tables: [
    Companies,
    Departments,
    DepartmentSectors,
    AppSettings,
    Employees,
    AttendanceEvents,
    CompanySettings,
    Advances,
    PayrollRuns,
    PayrollItems,
  ],
  daos: [
    CompaniesDao,
    DepartmentsDao,
    SettingsDao,
    EmployeesDao,
    AttendanceDao,
    CompanySettingsDao,
    AdvancesDao,
    PayrollDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 19;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(companies);
        await m.createTable(appSettings);

        final defaultCompanyId = await into(
          companies,
        ).insert(CompaniesCompanion.insert(name: 'Empresa principal'));

        await m.alterTable(
          TableMigration(
            employees,
            newColumns: [
              employees.companyId,
              employees.ipsEnabled,
              employees.childrenCount,
              employees.allowOvertime,
              employees.biometricClockEnabled,
              employees.hasEmbargo,
              employees.embargoAccount,
              employees.embargoAmount,
              employees.workStartTime1,
              employees.workStartTime2,
              employees.workStartTime3,
              employees.workStartTimeSaturday,
              employees.workEndTimeSaturday,
            ],
            columnTransformer: {
              employees.companyId: Constant(defaultCompanyId),
              employees.ipsEnabled: const Constant(true),
              employees.childrenCount: const Constant(0),
              employees.allowOvertime: const Constant(true),
              employees.biometricClockEnabled: const Constant(true),
              employees.hasEmbargo: const Constant(false),
              employees.workStartTime1: const Constant('06:00'),
              employees.workStartTime2: const Constant('15:00'),
              employees.workStartTime3: const Constant('18:00'),
            },
          ),
        );

        await m.createTable(attendanceEvents);
        await m.createTable(advances);
        await m.createTable(payrollRuns);
        await m.createTable(payrollItems);

        await into(appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _activeCompanySettingKey,
            value: Value(defaultCompanyId.toString()),
          ),
        );
      }

      if (from < 3) {
        await m.createTable(companySettings);

        final existingCompanies = await select(companies).get();
        for (final company in existingCompanies) {
          await into(companySettings).insertOnConflictUpdate(
            CompanySettingsCompanion.insert(companyId: Value(company.id)),
          );
        }

        if (from >= 2) {
          await _addColumnIfMissing(m, employees, employees.childrenCount);
          await _addColumnIfMissing(m, employees, employees.allowOvertime);
          await _addColumnIfMissing(m, employees, employees.hasEmbargo);
          await _addColumnIfMissing(m, employees, employees.embargoAccount);
          await _addColumnIfMissing(m, employees, employees.embargoAmount);
          await _addColumnIfMissing(
            m,
            attendanceEvents,
            attendanceEvents.overtimeType,
          );
          await _addColumnIfMissing(
            m,
            payrollItems,
            payrollItems.embargoAmount,
          );
          await _addColumnIfMissing(
            m,
            payrollItems,
            payrollItems.embargoAccount,
          );
        }
      }

      if (from >= 2 && from < 4) {
        await _addColumnIfMissing(
          m,
          attendanceEvents,
          attendanceEvents.checkInTime,
        );
        await _addColumnIfMissing(
          m,
          attendanceEvents,
          attendanceEvents.checkOutTime,
        );
      }

      if (from >= 2 && from < 5) {
        await _addColumnIfMissing(
          m,
          attendanceEvents,
          attendanceEvents.breakMinutes,
        );
      }

      if (from >= 3 && from < 6) {
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.ordinaryNightSurchargeRate,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.ordinaryNightStart,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.ordinaryNightEnd,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.overtimeDayStart,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.overtimeDayEnd,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.overtimeNightStart,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.overtimeNightEnd,
        );
      }

      if (from >= 2 && from < 7) {
        await _addColumnIfMissing(m, employees, employees.workStartTime1);
        await _addColumnIfMissing(m, employees, employees.workStartTime2);
        await _addColumnIfMissing(m, employees, employees.workStartTime3);
      }

      if (from >= 2 && from < 8) {
        await _addColumnIfMissing(m, payrollItems, payrollItems.overtimePay);
      }

      if (from >= 2 && from < 9) {
        await _addColumnIfMissing(m, payrollItems, payrollItems.otherDiscount);
      }

      if (from >= 2 && from < 10) {
        await m.createTable(departments);
        await m.createTable(departmentSectors);
      }

      if (from >= 2 && from < 11) {
        await _addColumnIfMissing(m, employees, employees.departmentId);
        await _addColumnIfMissing(m, employees, employees.sectorId);
        await _addColumnIfMissing(m, employees, employees.jobTitle);
        await _addColumnIfMissing(m, employees, employees.workLocation);
      }

      if (from >= 2 && from < 12) {
        await _addColumnIfMissing(
          m,
          payrollItems,
          payrollItems.ordinaryNightHours,
        );
        await _addColumnIfMissing(
          m,
          payrollItems,
          payrollItems.ordinaryNightSurchargePay,
        );
      }

      if (from >= 2 && from < 13) {
        await _addColumnIfMissing(m, payrollItems, payrollItems.familyBonus);
      }

      if (from >= 3 && from < 14) {
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.holidayDates,
        );
      }

      if (from >= 3 && from < 15) {
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.lateArrivalToleranceMinutes,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.lateArrivalAllowedTimesPerMonth,
        );
      }

      if (from >= 2 && from < 16) {
        await _addColumnIfMissing(
          m,
          payrollItems,
          payrollItems.attendanceDiscount,
        );
      }

      if (from >= 2 && from < 17) {
        await _addColumnIfMissing(
          m,
          employees,
          employees.biometricClockEnabled,
        );
      }

      if (from >= 2 && from < 18) {
        await _addColumnIfMissing(
          m,
          employees,
          employees.workStartTimeSaturday,
        );
      }

      if (from >= 2 && from < 19) {
        await _addColumnIfMissing(m, employees, employees.workEndTimeSaturday);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo<Table, dynamic> table,
    GeneratedColumn column,
  ) async {
    final rows = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    final existingColumns = rows.map((row) => row.read<String>('name')).toSet();

    if (!existingColumns.contains(column.$name)) {
      await m.addColumn(table, column);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDirectory = await getApplicationSupportDirectory();
    final dbFile = File(p.join(dbDirectory.path, 'rrhh_app.sqlite'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
