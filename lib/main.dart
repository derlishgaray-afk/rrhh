import 'package:flutter/material.dart';

import 'data/database/app_database.dart';
import 'services/attendance_service.dart';
import 'services/company_service.dart';
import 'services/company_settings_service.dart';
import 'services/department_service.dart';
import 'services/employees_service.dart';
import 'services/payroll_service.dart';
import 'ui/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final companyService = CompanyService(
    database.companiesDao,
    database.settingsDao,
    database.companySettingsDao,
  );
  final companySettingsService = CompanySettingsService(
    database.companySettingsDao,
  );
  final departmentService = DepartmentService(database.departmentsDao);
  final employeesService = EmployeesService(
    database.employeesDao,
    database.departmentsDao,
  );
  final attendanceService = AttendanceService(
    database.attendanceDao,
    database.employeesDao,
  );
  final payrollService = PayrollService(
    payrollDao: database.payrollDao,
    employeesDao: database.employeesDao,
    attendanceDao: database.attendanceDao,
    companySettingsService: companySettingsService,
  );

  runApp(
    RrhhApp(
      database: database,
      companyService: companyService,
      companySettingsService: companySettingsService,
      departmentService: departmentService,
      employeesService: employeesService,
      attendanceService: attendanceService,
      payrollService: payrollService,
    ),
  );
}

class RrhhApp extends StatefulWidget {
  const RrhhApp({
    required this.database,
    required this.companyService,
    required this.companySettingsService,
    required this.departmentService,
    required this.employeesService,
    required this.attendanceService,
    required this.payrollService,
    super.key,
  });

  final AppDatabase database;
  final CompanyService companyService;
  final CompanySettingsService companySettingsService;
  final DepartmentService departmentService;
  final EmployeesService employeesService;
  final AttendanceService attendanceService;
  final PayrollService payrollService;

  @override
  State<RrhhApp> createState() => _RrhhAppState();
}

class _RrhhAppState extends State<RrhhApp> {
  @override
  void dispose() {
    widget.database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RRHH App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MainScreen(
        companyService: widget.companyService,
        companySettingsService: widget.companySettingsService,
        departmentService: widget.departmentService,
        employeesService: widget.employeesService,
        attendanceService: widget.attendanceService,
        payrollService: widget.payrollService,
      ),
    );
  }
}
