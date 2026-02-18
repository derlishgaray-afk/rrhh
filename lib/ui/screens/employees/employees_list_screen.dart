import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/department_service.dart';
import '../../../services/employees_service.dart';
import '../../utils/guarani_currency.dart';
import 'employee_form_dialog.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({
    required this.service,
    required this.departmentService,
    required this.companyId,
    required this.companyName,
    super.key,
  });

  final EmployeesService service;
  final DepartmentService departmentService;
  final int companyId;
  final String companyName;

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  List<Employee> _employees = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void didUpdateWidget(covariant EmployeesListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _searchController.clear();
      _loadEmployees();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = _searchController.text.trim();
      final employees = query.isEmpty
          ? await widget.service.listEmployeesByCompany(widget.companyId)
          : await widget.service.searchEmployeesByName(widget.companyId, query);

      if (!mounted) {
        return;
      }

      setState(() {
        _employees = employees;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No se pudieron cargar empleados.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openEmployeeForm({Employee? employee}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => EmployeeFormDialog(
        service: widget.service,
        departmentService: widget.departmentService,
        companyId: widget.companyId,
        companyName: widget.companyName,
        employee: employee,
      ),
    );

    if (saved == true) {
      await _loadEmployees();
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: Text('Desea eliminar a ${employee.fullName}?'),
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
      await widget.service.deleteEmployee(employee.id);
      if (!mounted) {
        return;
      }
      await _loadEmployees();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el empleado.')),
        );
    }
  }

  String _formatSalary(double value) => GuaraniCurrency.format(value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _loadEmployees(),
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _loadEmployees();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _openEmployeeForm(),
                icon: const Icon(Icons.person_add),
                label: const Text('Nuevo empleado'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _employees.isEmpty
                ? const Center(child: Text('No hay empleados registrados.'))
                : Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    notificationPredicate: (notification) =>
                        notification.metrics.axis == Axis.horizontal,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 1200),
                        child: Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          notificationPredicate: (notification) =>
                              notification.metrics.axis == Axis.vertical,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Documento')),
                                DataColumn(label: Text('Cargo')),
                                DataColumn(label: Text('Lugar trabajo')),
                                DataColumn(label: Text('Tipo')),
                                DataColumn(label: Text('Reloj biometrico')),
                                DataColumn(label: Text('Salario')),
                                DataColumn(label: Text('Estado')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: _employees
                                  .map(
                                    (employee) => DataRow(
                                      cells: [
                                        DataCell(Text(employee.fullName)),
                                        DataCell(Text(employee.documentNumber)),
                                        DataCell(
                                          Text(employee.jobTitle ?? '-'),
                                        ),
                                        DataCell(
                                          Text(employee.workLocation ?? '-'),
                                        ),
                                        DataCell(Text(employee.employeeType)),
                                        DataCell(
                                          Text(
                                            employee.biometricClockEnabled
                                                ? 'Con marcacion'
                                                : 'Sin marcacion',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _formatSalary(employee.baseSalary),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            employee.active
                                                ? 'Activo'
                                                : 'Inactivo',
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip: 'Editar',
                                                onPressed: () =>
                                                    _openEmployeeForm(
                                                      employee: employee,
                                                    ),
                                                icon: const Icon(Icons.edit),
                                              ),
                                              IconButton(
                                                tooltip: 'Eliminar',
                                                onPressed: () =>
                                                    _deleteEmployee(employee),
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
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
