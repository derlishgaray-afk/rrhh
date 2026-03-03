import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/department_service.dart';
import 'department_form_dialog.dart';
import 'department_sectors_dialog.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({
    required this.service,
    required this.companyId,
    required this.canCreateDepartment,
    required this.canUpdateDepartment,
    required this.canDeleteDepartment,
    super.key,
  });

  final DepartmentService service;
  final int companyId;
  final bool canCreateDepartment;
  final bool canUpdateDepartment;
  final bool canDeleteDepartment;

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  static const Duration _autoRefreshInterval = Duration(seconds: 8);

  Timer? _autoRefreshTimer;
  List<Department> _departments = const [];
  bool _isLoading = false;
  bool _isFetchingDepartments = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _startAutoRefresh();
  }

  @override
  void didUpdateWidget(covariant DepartmentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _loadDepartments();
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
      if (!mounted || _isFetchingDepartments) {
        return;
      }
      _loadDepartments(showLoader: false, silentErrors: true);
    });
  }

  Future<void> _loadDepartments({
    bool showLoader = true,
    bool silentErrors = false,
  }) async {
    if (_isFetchingDepartments) {
      return;
    }
    _isFetchingDepartments = true;

    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final departments = await widget.service.listDepartmentsByCompany(
        widget.companyId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _departments = departments;
      });
    } catch (_) {
      if (silentErrors) {
        return;
      }
      _showError('No se pudieron cargar los departamentos.');
    } finally {
      _isFetchingDepartments = false;
      if (mounted) {
        if (showLoader) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _openDepartmentForm({Department? department}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => DepartmentFormDialog(
        service: widget.service,
        companyId: widget.companyId,
        department: department,
      ),
    );

    if (saved == true) {
      await _loadDepartments();
    }
  }

  Future<void> _openSectors(Department department) async {
    await showDialog<void>(
      context: context,
      builder: (_) => DepartmentSectorsDialog(
        service: widget.service,
        department: department,
        canCreateSector: widget.canCreateDepartment,
        canUpdateSector: widget.canUpdateDepartment,
        canDeleteSector: widget.canDeleteDepartment,
      ),
    );
  }

  Future<void> _deleteDepartment(Department department) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar departamento'),
        content: Text(
          'Desea eliminar ${department.name}? Tambien se eliminaran sus sectores.',
        ),
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
      await widget.service.deleteDepartment(department.id);
      if (!mounted) {
        return;
      }
      await _loadDepartments();
    } on ArgumentError catch (error) {
      _showError(
        error.message?.toString() ?? 'No se pudo eliminar el departamento.',
      );
    } catch (_) {
      _showError('No se pudo eliminar el departamento.');
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
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Departamentos de la empresa activa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            if (widget.canCreateDepartment)
              FilledButton.icon(
                onPressed: () => _openDepartmentForm(),
                icon: const Icon(Icons.account_tree),
                label: const Text('Nuevo departamento'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _departments.isEmpty
              ? const Center(child: Text('No hay departamentos registrados.'))
              : SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Descripcion')),
                      DataColumn(label: Text('Estado')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: _departments
                        .map(
                          (department) => DataRow(
                            cells: [
                              DataCell(Text(department.name)),
                              DataCell(Text(department.description ?? '-')),
                              DataCell(
                                Text(department.active ? 'Activo' : 'Inactivo'),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () => _openSectors(department),
                                      child: const Text('Sectores'),
                                    ),
                                    if (widget.canUpdateDepartment)
                                      IconButton(
                                        tooltip: 'Editar',
                                        onPressed: () => _openDepartmentForm(
                                          department: department,
                                        ),
                                        icon: const Icon(Icons.edit),
                                      ),
                                    if (widget.canDeleteDepartment)
                                      IconButton(
                                        tooltip: 'Eliminar',
                                        onPressed: () =>
                                            _deleteDepartment(department),
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
