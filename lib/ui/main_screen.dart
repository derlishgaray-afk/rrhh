import 'package:flutter/material.dart';

import '../data/database/app_database.dart';
import '../services/attendance_service.dart';
import '../services/company_service.dart';
import '../services/company_settings_service.dart';
import '../services/department_service.dart';
import '../services/employees_service.dart';
import '../services/payroll_service.dart';
import 'screens/attendance/attendance_screen.dart';
import 'screens/companies/companies_screen.dart';
import 'screens/companies/company_form_dialog.dart';
import 'screens/employees/employees_list_screen.dart';
import 'screens/payroll/payroll_screen.dart';
import 'screens/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    required this.companyService,
    required this.companySettingsService,
    required this.departmentService,
    required this.employeesService,
    required this.attendanceService,
    required this.payrollService,
    super.key,
  });

  final CompanyService companyService;
  final CompanySettingsService companySettingsService;
  final DepartmentService departmentService;
  final EmployeesService employeesService;
  final AttendanceService attendanceService;
  final PayrollService payrollService;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  List<Company> _companies = const [];
  int? _activeCompanyId;
  bool _isLoadingCompanies = false;

  @override
  void initState() {
    super.initState();
    _reloadCompanies();
  }

  Future<void> _reloadCompanies() async {
    setState(() {
      _isLoadingCompanies = true;
    });

    try {
      final companies = await widget.companyService.listCompanies();
      final activeCompany = await widget.companyService.getActiveCompany();

      if (!mounted) {
        return;
      }

      setState(() {
        _companies = companies;
        _activeCompanyId = activeCompany?.id;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No se pudo cargar empresas.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCompanies = false;
        });
      }
    }
  }

  Future<void> _setActiveCompany(int companyId) async {
    try {
      await widget.companyService.setActiveCompany(companyId);
      await _reloadCompanies();
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
      await _reloadCompanies();
    }
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Empresas';
      case 1:
        return 'Empleados';
      case 2:
        return 'Asistencia';
      case 3:
        return 'Liquidacion';
      case 4:
        return 'Configuracion';
      default:
        return 'RRHH';
    }
  }

  String _activeCompanyName() {
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

  Widget _buildBody(int index) {
    if (_isLoadingCompanies) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_companies.isEmpty) {
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

    switch (index) {
      case 0:
        return CompaniesScreen(
          service: widget.companyService,
          departmentService: widget.departmentService,
          companyId: _activeCompanyId!,
          activeCompanyId: _activeCompanyId,
          onCompanyDataChanged: _reloadCompanies,
          onSetActiveCompany: _setActiveCompany,
        );
      case 1:
        return EmployeesListScreen(
          service: widget.employeesService,
          departmentService: widget.departmentService,
          companyId: _activeCompanyId!,
          companyName: _activeCompanyName(),
        );
      case 2:
        return AttendanceScreen(
          service: widget.attendanceService,
          employeesService: widget.employeesService,
          companySettingsService: widget.companySettingsService,
          companyId: _activeCompanyId!,
          companyName: _activeCompanyName(),
        );
      case 3:
        return PayrollScreen(
          service: widget.payrollService,
          companyId: _activeCompanyId!,
          companyName: _activeCompanyName(),
        );
      case 4:
        return SettingsScreen(
          service: widget.companySettingsService,
          companyId: _activeCompanyId!,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxIndex = 4;
    final safeSelectedIndex = _selectedIndex.clamp(0, maxIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(safeSelectedIndex)),
        actions: [
          if (_companies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
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
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: safeSelectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('Empresas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Empleados'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.fact_check),
                label: Text('Asistencia'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calculate),
                label: Text('Liquidacion'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Config'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildBody(safeSelectedIndex)),
        ],
      ),
    );
  }
}
