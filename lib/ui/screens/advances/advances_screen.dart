import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../services/advances_service.dart';
import '../../../services/employee_name_formatter.dart';
import '../../../services/employees_service.dart';
import '../../utils/guarani_currency.dart';
import 'advance_form_dialog.dart';

class AdvancesScreen extends StatefulWidget {
  const AdvancesScreen({
    required this.service,
    required this.employeesService,
    required this.companyId,
    super.key,
  });

  final AdvancesService service;
  final EmployeesService employeesService;
  final int companyId;

  @override
  State<AdvancesScreen> createState() => _AdvancesScreenState();
}

class _AdvancesScreenState extends State<AdvancesScreen> {
  List<Advance> _advances = const [];
  List<Employee> _employees = const [];
  bool _isLoading = false;
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadData();
  }

  @override
  void didUpdateWidget(covariant AdvancesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final employees = await widget.employeesService
          .listActiveEmployeesByCompany(widget.companyId);
      final advances = await widget.service.listAdvancesByMonth(
        companyId: widget.companyId,
        year: _selectedYear,
        month: _selectedMonth,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _employees = employees;
        _advances = advances;
      });
    } catch (_) {
      _showError('No se pudo cargar anticipos.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openForm({Advance? advance}) async {
    if (_employees.isEmpty) {
      _showError('Debe registrar empleados activos para cargar anticipos.');
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AdvanceFormDialog(
        service: widget.service,
        companyId: widget.companyId,
        employees: _employees,
        advance: advance,
      ),
    );

    if (saved == true) {
      await _loadData();
    }
  }

  Future<void> _deleteAdvance(Advance advance) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar anticipo'),
        content: const Text('Desea eliminar este anticipo?'),
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
      await widget.service.deleteAdvance(advance.id);
      if (!mounted) {
        return;
      }
      await _loadData();
    } catch (_) {
      _showError('No se pudo eliminar el anticipo.');
    }
  }

  String _employeeName(int employeeId) {
    for (final employee in _employees) {
      if (employee.id == employeeId) {
        return employeeDisplayName(employee);
      }
    }
    return 'Desconocido';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
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
    final years = List<int>.generate(
      8,
      (index) => DateTime.now().year - 3 + index,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              DropdownButton<int>(
                value: _selectedMonth,
                items: List<DropdownMenuItem<int>>.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('Mes ${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedMonth = value;
                  });
                  _loadData();
                },
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _selectedYear,
                items: years
                    .map(
                      (year) =>
                          DropdownMenuItem(value: year, child: Text('$year')),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedYear = value;
                  });
                  _loadData();
                },
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_card),
                label: const Text('Nuevo anticipo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _advances.isEmpty
                ? const Center(child: Text('No hay anticipos registrados.'))
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Fecha')),
                        DataColumn(label: Text('Empleado')),
                        DataColumn(label: Text('Monto')),
                        DataColumn(label: Text('Motivo')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: _advances
                          .map(
                            (advance) => DataRow(
                              cells: [
                                DataCell(Text(_formatDate(advance.date))),
                                DataCell(
                                  Text(_employeeName(advance.employeeId)),
                                ),
                                DataCell(
                                  Text(GuaraniCurrency.format(advance.amount)),
                                ),
                                DataCell(Text(advance.reason ?? '-')),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _openForm(advance: advance),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deleteAdvance(advance),
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
      ),
    );
  }
}
