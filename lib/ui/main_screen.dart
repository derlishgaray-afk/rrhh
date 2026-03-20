import 'package:flutter/material.dart';

import '../data/database/app_database.dart';
import '../security/security_constants.dart';
import '../services/attendance_service.dart';
import '../services/auth_service.dart';
import '../services/authorization_service.dart';
import '../services/company_service.dart';
import '../services/company_settings_service.dart';
import '../services/department_service.dart';
import '../services/employees_service.dart';
import '../services/payroll_service.dart';
import '../services/reports_service.dart';
import '../services/user_admin_service.dart';
import 'screens/attendance/attendance_screen.dart';
import 'screens/companies/companies_screen.dart';
import 'screens/companies/company_form_dialog.dart';
import 'screens/employees/employees_list_screen.dart';
import 'screens/payroll/payroll_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/users/users_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    required this.authService,
    required this.authorizationService,
    required this.userAdminService,
    required this.companyService,
    required this.companySettingsService,
    required this.departmentService,
    required this.employeesService,
    required this.attendanceService,
    required this.payrollService,
    required this.reportsService,
    required this.onLogout,
    super.key,
  });

  final AuthService authService;
  final AuthorizationService authorizationService;
  final UserAdminService userAdminService;
  final CompanyService companyService;
  final CompanySettingsService companySettingsService;
  final DepartmentService departmentService;
  final EmployeesService employeesService;
  final AttendanceService attendanceService;
  final PayrollService payrollService;
  final ReportsService reportsService;
  final Future<void> Function() onLogout;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _employeesModuleId = 'employees';

  String _selectedModuleId = _employeesModuleId;
  List<Company> _companies = const [];
  int? _activeCompanyId;
  bool _isLoading = false;
  bool _isSuperAdmin = false;
  User? _currentUser;
  Set<String> _activePermissions = const <String>{};
  List<_NavModule> _modules = const [];

  @override
  void initState() {
    super.initState();
    _reloadContext();
  }

  Future<void> _reloadContext() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await widget.authorizationService.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) {
          return;
        }
        await widget.onLogout();
        return;
      }

      final isSuperAdmin = await widget.authorizationService.isSuperAdmin();
      final companies = await widget.companyService.listCompanies();

      var activeCompanyId = await widget.companyService.getActiveCompanyId();
      if (companies.isNotEmpty &&
          (activeCompanyId == null ||
              !companies.any((company) => company.id == activeCompanyId))) {
        activeCompanyId = companies.first.id;
        await widget.companyService.setActiveCompany(activeCompanyId);
      }

      final permissions = activeCompanyId == null
          ? <String>{}
          : await widget.authorizationService.permissionsForCompany(
              activeCompanyId,
            );
      final modules = _buildModules(
        permissions: permissions,
        isSuperAdmin: isSuperAdmin,
      );

      var selectedModuleId = _selectedModuleId;
      if (!modules.any((module) => module.id == selectedModuleId)) {
        selectedModuleId = modules.isEmpty ? '' : modules.first.id;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _currentUser = currentUser;
        _isSuperAdmin = isSuperAdmin;
        _companies = companies;
        _activeCompanyId = activeCompanyId;
        _activePermissions = permissions;
        _modules = modules;
        _selectedModuleId = selectedModuleId;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar contexto de usuario.'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<_NavModule> _buildModules({
    required Set<String> permissions,
    required bool isSuperAdmin,
  }) {
    final modules = <_NavModule>[];

    if (isSuperAdmin || permissions.contains(PermissionKeys.companiesRead)) {
      modules.add(
        const _NavModule(
          id: 'companies',
          title: 'Empresas',
          icon: Icons.business,
          label: 'Empresas',
        ),
      );
    }
    if (isSuperAdmin || permissions.contains(PermissionKeys.employeesRead)) {
      modules.add(
        const _NavModule(
          id: 'employees',
          title: 'Empleados',
          icon: Icons.people,
          label: 'Empleados',
        ),
      );
    }
    if (isSuperAdmin || permissions.contains(PermissionKeys.attendanceRead)) {
      modules.add(
        const _NavModule(
          id: 'attendance',
          title: 'Asistencia',
          icon: Icons.fact_check,
          label: 'Asistencia',
        ),
      );
    }
    if (isSuperAdmin || permissions.contains(PermissionKeys.payrollRead)) {
      modules.add(
        const _NavModule(
          id: 'payroll',
          title: 'Liquidacion',
          icon: Icons.calculate,
          label: 'Liquidacion',
        ),
      );
    }
    if (isSuperAdmin || permissions.contains(PermissionKeys.reportsRead)) {
      modules.add(
        const _NavModule(
          id: 'reports',
          title: 'Informes',
          icon: Icons.insert_chart_outlined,
          label: 'Informes',
        ),
      );
    }
    if (isSuperAdmin ||
        permissions.contains(PermissionKeys.settingsRead) ||
        permissions.contains(PermissionKeys.settingsUpdate)) {
      modules.add(
        const _NavModule(
          id: 'settings',
          title: 'Configuracion',
          icon: Icons.settings,
          label: 'Config',
        ),
      );
    }
    if (isSuperAdmin) {
      modules.add(
        const _NavModule(
          id: 'users',
          title: 'Usuarios',
          icon: Icons.admin_panel_settings,
          label: 'Usuarios',
        ),
      );
    }

    return modules;
  }

  Future<void> _setActiveCompany(int companyId) async {
    try {
      await widget.companyService.setActiveCompany(companyId);
      await _reloadContext();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No se pudo seleccionar la empresa.')),
        );
    }
  }

  Future<void> _createInitialCompany() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CompanyFormDialog(service: widget.companyService),
    );
    if (created == true) {
      await _reloadContext();
    }
  }

  String get _activeCompanyName {
    final activeCompanyId = _activeCompanyId;
    if (activeCompanyId == null) {
      return 'Empresa';
    }
    for (final company in _companies) {
      if (company.id == activeCompanyId) {
        return company.name;
      }
    }
    return 'Empresa';
  }

  Company? get _activeCompanyRecord {
    final activeCompanyId = _activeCompanyId;
    if (activeCompanyId == null) {
      return null;
    }
    for (final company in _companies) {
      if (company.id == activeCompanyId) {
        return company;
      }
    }
    return null;
  }

  bool _hasPermission(String permissionKey) {
    return _isSuperAdmin || _activePermissions.contains(permissionKey);
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_companies.isEmpty) {
      if (!_isSuperAdmin) {
        return const Center(
          child: Text('No tiene empresas asignadas. Contacte al SUPER_ADMIN.'),
        );
      }
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No hay empresas registradas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para iniciar el sistema de la holding, cree su primera empresa.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _createInitialCompany,
                    icon: const Icon(Icons.add_business),
                    label: const Text('Crear empresa'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_activeCompanyId == null) {
      return const Center(child: Text('Seleccione una empresa activa.'));
    }

    switch (_selectedModuleId) {
      case 'companies':
        return CompaniesScreen(
          service: widget.companyService,
          departmentService: widget.departmentService,
          companyId: _activeCompanyId!,
          activeCompanyId: _activeCompanyId,
          canCreateCompany: _hasPermission(PermissionKeys.companiesCreate),
          canUpdateCompany: _hasPermission(PermissionKeys.companiesUpdate),
          canDeleteCompany: _hasPermission(PermissionKeys.companiesDelete),
          canCreateDepartment: _hasPermission(PermissionKeys.companiesUpdate),
          canUpdateDepartment: _hasPermission(PermissionKeys.companiesUpdate),
          canDeleteDepartment: _hasPermission(PermissionKeys.companiesDelete),
          onCompanyDataChanged: _reloadContext,
          onSetActiveCompany: _setActiveCompany,
        );
      case 'employees':
        return EmployeesListScreen(
          service: widget.employeesService,
          departmentService: widget.departmentService,
          companyId: _activeCompanyId!,
          companyName: _activeCompanyName,
          isSuperAdmin: _isSuperAdmin,
          canCreateEmployee: _hasPermission(PermissionKeys.employeesCreate),
          canUpdateEmployee: _hasPermission(PermissionKeys.employeesUpdate),
          canDeleteEmployee: _hasPermission(PermissionKeys.employeesDelete),
        );
      case 'attendance':
        return AttendanceScreen(
          service: widget.attendanceService,
          employeesService: widget.employeesService,
          companySettingsService: widget.companySettingsService,
          companyId: _activeCompanyId!,
          companyName: _activeCompanyName,
          canImportClock: _hasPermission(PermissionKeys.attendanceImportClock),
        );
      case 'payroll':
        final activeCompany = _activeCompanyRecord;
        return PayrollScreen(
          service: widget.payrollService,
          companyId: _activeCompanyId!,
          companyName: _activeCompanyName,
          companyMjtEmployerNumber: activeCompany?.mjtEmployerNumber,
          companyLogoPng: activeCompany?.logoPng,
          canGeneratePayroll: _hasPermission(PermissionKeys.payrollGenerate),
          canLockPayroll: _hasPermission(PermissionKeys.payrollLock),
          canUnlockPayroll: _hasPermission(PermissionKeys.payrollUnlock),
          canPrintPayroll: _hasPermission(PermissionKeys.payrollPrint),
          canExportPayroll: _hasPermission(PermissionKeys.payrollExport),
          isSuperAdmin: _isSuperAdmin,
        );
      case 'settings':
        return SettingsScreen(
          service: widget.companySettingsService,
          companyId: _activeCompanyId!,
          canUpdateSettings: _hasPermission(PermissionKeys.settingsUpdate),
        );
      case 'reports':
        return ReportsScreen(
          service: widget.reportsService,
          companyId: _activeCompanyId!,
          companyName: _activeCompanyName,
        );
      case 'users':
        return UsersScreen(service: widget.userAdminService);
      default:
        return const Center(child: Text('No hay modulos habilitados.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedModule = _modules.firstWhere(
      (module) => module.id == _selectedModuleId,
      orElse: () => const _NavModule(
        id: '',
        title: 'RRHH',
        icon: Icons.home,
        label: 'RRHH',
      ),
    );
    final selectedIndex = _modules.indexWhere(
      (module) => module.id == _selectedModuleId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedModule.title),
        actions: [
          if (_companies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _activeCompanyId,
                  hint: const Text('Empresa'),
                  items: _companies
                      .map(
                        (company) => DropdownMenuItem<int>(
                          value: company.id,
                          child: Text(company.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    _setActiveCompany(value);
                  },
                ),
              ),
            ),
          if (_currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  _currentUser!.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () async {
              await widget.onLogout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _modules.length < 2
          ? _buildBody()
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                  onDestinationSelected: (index) {
                    if (index < 0 || index >= _modules.length) {
                      return;
                    }
                    setState(() {
                      _selectedModuleId = _modules[index].id;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: _modules
                      .map(
                        (module) => NavigationRailDestination(
                          icon: Icon(module.icon),
                          label: Text(module.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildBody()),
              ],
            ),
    );
  }
}

class _NavModule {
  const _NavModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.label,
  });

  final String id;
  final String title;
  final IconData icon;
  final String label;
}
