import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/company_service.dart';
import '../../../services/department_service.dart';
import 'departments_screen.dart';
import 'company_form_dialog.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({
    required this.service,
    required this.departmentService,
    required this.companyId,
    required this.activeCompanyId,
    required this.canCreateCompany,
    required this.canUpdateCompany,
    required this.canDeleteCompany,
    required this.canCreateDepartment,
    required this.canUpdateDepartment,
    required this.canDeleteDepartment,
    required this.onCompanyDataChanged,
    required this.onSetActiveCompany,
    super.key,
  });

  final CompanyService service;
  final DepartmentService departmentService;
  final int companyId;
  final int? activeCompanyId;
  final bool canCreateCompany;
  final bool canUpdateCompany;
  final bool canDeleteCompany;
  final bool canCreateDepartment;
  final bool canUpdateDepartment;
  final bool canDeleteDepartment;
  final Future<void> Function() onCompanyDataChanged;
  final Future<void> Function(int companyId) onSetActiveCompany;

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  static const Duration _autoRefreshInterval = Duration(seconds: 8);

  Timer? _autoRefreshTimer;
  List<Company> _companies = const [];
  bool _isLoading = false;
  bool _isFetchingCompanies = false;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _startAutoRefresh();
  }

  @override
  void didUpdateWidget(covariant CompaniesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _loadCompanies();
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      if (!mounted || _isFetchingCompanies) {
        return;
      }
      _loadCompanies(showLoader: false, silentErrors: true);
    });
  }

  Future<void> _loadCompanies({
    bool showLoader = true,
    bool silentErrors = false,
  }) async {
    if (_isFetchingCompanies) {
      return;
    }
    _isFetchingCompanies = true;

    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final companies = await widget.service.listCompanies();
      if (!mounted) {
        return;
      }

      setState(() {
        _companies = companies;
      });
    } catch (_) {
      if (silentErrors) {
        return;
      }
      _showError('No se pudieron cargar las empresas.');
    } finally {
      _isFetchingCompanies = false;
      if (mounted) {
        if (showLoader) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _openCompanyForm({Company? company}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) =>
          CompanyFormDialog(service: widget.service, company: company),
    );

    if (saved == true) {
      await _loadCompanies();
      await widget.onCompanyDataChanged();
    }
  }

  Future<void> _deleteCompany(Company company) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar empresa'),
        content: Text('Desea eliminar ${company.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await widget.service.deleteCompany(company.id);
      if (!mounted) {
        return;
      }

      await _loadCompanies();
      await widget.onCompanyDataChanged();
    } on ArgumentError catch (error) {
      _showError(
        error.message?.toString() ?? 'No se pudo eliminar la empresa.',
      );
    } catch (_) {
      _showError('No se pudo eliminar la empresa.');
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.business), text: 'Empresas'),
                Tab(icon: Icon(Icons.account_tree), text: 'Departamentos'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCompaniesTab(),
                  DepartmentsScreen(
                    service: widget.departmentService,
                    companyId: widget.companyId,
                    canCreateDepartment: widget.canCreateDepartment,
                    canUpdateDepartment: widget.canUpdateDepartment,
                    canDeleteDepartment: widget.canDeleteDepartment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompaniesTab() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Empresas de la holding',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            if (widget.canCreateCompany)
              FilledButton.icon(
                onPressed: () => _openCompanyForm(),
                icon: const Icon(Icons.add_business),
                label: const Text('Nueva empresa'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _companies.isEmpty
              ? const Center(child: Text('No hay empresas registradas.'))
              : SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Activa')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Abrev.')),
                      DataColumn(label: Text('RUC')),
                      DataColumn(label: Text('N° Patronal MJT')),
                      DataColumn(label: Text('Telefono')),
                      DataColumn(label: Text('Estado')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: _companies
                        .map(
                          (company) => DataRow(
                            cells: [
                              DataCell(
                                Icon(
                                  widget.activeCompanyId == company.id
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: widget.activeCompanyId == company.id
                                      ? Colors.green
                                      : null,
                                ),
                              ),
                              DataCell(Text(company.name)),
                              DataCell(Text(company.abbreviation ?? '-')),
                              DataCell(Text(company.ruc ?? '-')),
                              DataCell(Text(company.mjtEmployerNumber ?? '-')),
                              DataCell(Text(company.phone ?? '-')),
                              DataCell(
                                Text(company.active ? 'Activa' : 'Inactiva'),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          widget.onSetActiveCompany(company.id),
                                      child: const Text('Seleccionar'),
                                    ),
                                    if (widget.canUpdateCompany)
                                      IconButton(
                                        tooltip: 'Editar',
                                        onPressed: () =>
                                            _openCompanyForm(company: company),
                                        icon: const Icon(Icons.edit),
                                      ),
                                    if (widget.canDeleteCompany)
                                      IconButton(
                                        tooltip: 'Eliminar',
                                        onPressed: () =>
                                            _deleteCompany(company),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }
}
