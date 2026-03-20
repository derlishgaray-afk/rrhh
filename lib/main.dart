import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/database/app_database.dart';
import 'services/attendance_service.dart';
import 'services/auth_service.dart';
import 'services/authorization_service.dart';
import 'services/company_service.dart';
import 'services/company_settings_service.dart';
import 'services/department_service.dart';
import 'services/employees_service.dart';
import 'services/payroll_service.dart';
import 'services/reports_service.dart';
import 'services/user_admin_service.dart';
import 'ui/main_screen.dart';
import 'ui/screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase.fromEnvironment();
  final authorizationService = AuthorizationService(
    database.settingsDao,
    database.securityDao,
    database.companiesDao,
  );
  final companyService = CompanyService(
    database.companiesDao,
    database.settingsDao,
    database.companySettingsDao,
    database.securityDao,
    authorizationService,
  );
  final companySettingsService = CompanySettingsService(
    database.companySettingsDao,
    authorizationService,
  );
  final departmentService = DepartmentService(
    database.departmentsDao,
    authorizationService,
  );
  final employeesService = EmployeesService(
    database.employeesDao,
    database.departmentsDao,
    authorizationService,
  );
  final attendanceService = AttendanceService(
    database.attendanceDao,
    database.employeesDao,
    database.payrollDao,
    authorizationService,
  );
  final payrollService = PayrollService(
    payrollDao: database.payrollDao,
    employeesDao: database.employeesDao,
    attendanceDao: database.attendanceDao,
    companySettingsService: companySettingsService,
    authorizationService: authorizationService,
  );
  final reportsService = ReportsService(
    database.employeesDao,
    database.departmentsDao,
    database.attendanceDao,
    database.payrollDao,
    authorizationService,
  );
  final authService = AuthService(
    authorizationService,
    database.securityDao,
    companyService,
  );
  final userAdminService = UserAdminService(
    database.securityDao,
    database.companiesDao,
    authorizationService,
  );

  runApp(
    RrhhApp(
      database: database,
      authService: authService,
      authorizationService: authorizationService,
      companyService: companyService,
      companySettingsService: companySettingsService,
      departmentService: departmentService,
      employeesService: employeesService,
      attendanceService: attendanceService,
      payrollService: payrollService,
      reportsService: reportsService,
      userAdminService: userAdminService,
    ),
  );
}

class RrhhApp extends StatefulWidget {
  const RrhhApp({
    required this.database,
    required this.authService,
    required this.authorizationService,
    required this.companyService,
    required this.companySettingsService,
    required this.departmentService,
    required this.employeesService,
    required this.attendanceService,
    required this.payrollService,
    required this.reportsService,
    required this.userAdminService,
    super.key,
  });

  final AppDatabase database;
  final AuthService authService;
  final AuthorizationService authorizationService;
  final CompanyService companyService;
  final CompanySettingsService companySettingsService;
  final DepartmentService departmentService;
  final EmployeesService employeesService;
  final AttendanceService attendanceService;
  final PayrollService payrollService;
  final ReportsService reportsService;
  final UserAdminService userAdminService;

  @override
  State<RrhhApp> createState() => _RrhhAppState();
}

class _RrhhAppState extends State<RrhhApp> {
  bool _isCheckingSession = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      await widget.authService.logout();
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoggedIn = false;
        _isCheckingSession = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoggedIn = false;
        _isCheckingSession = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await widget.authService.logout();
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoggedIn = false;
    });
  }

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
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
          PointerDeviceKind.unknown,
        },
      ),
      locale: const Locale('es', 'PY'),
      supportedLocales: const [Locale('es', 'PY'), Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: _isCheckingSession
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _isLoggedIn
          ? MainScreen(
              authService: widget.authService,
              authorizationService: widget.authorizationService,
              userAdminService: widget.userAdminService,
              companyService: widget.companyService,
              companySettingsService: widget.companySettingsService,
              departmentService: widget.departmentService,
              employeesService: widget.employeesService,
              attendanceService: widget.attendanceService,
              payrollService: widget.payrollService,
              reportsService: widget.reportsService,
              onLogout: _handleLogout,
            )
          : LoginScreen(
              authService: widget.authService,
              onLoginSuccess: () {
                setState(() {
                  _isLoggedIn = true;
                });
              },
            ),
    );
  }
}
