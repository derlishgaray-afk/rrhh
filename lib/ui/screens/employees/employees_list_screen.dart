import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../data/database/app_database.dart';
import '../../../services/department_service.dart';
import '../../../services/employee_name_formatter.dart';
import '../../../services/employees_service.dart';
import '../../utils/guarani_currency.dart';
import 'employee_form_dialog.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({
    required this.service,
    required this.departmentService,
    required this.companyId,
    required this.companyName,
    required this.canCreateEmployee,
    required this.canUpdateEmployee,
    required this.canDeleteEmployee,
    super.key,
  });

  final EmployeesService service;
  final DepartmentService departmentService;
  final int companyId;
  final String companyName;
  final bool canCreateEmployee;
  final bool canUpdateEmployee;
  final bool canDeleteEmployee;

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  static const Duration _autoRefreshInterval = Duration(seconds: 8);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  Timer? _autoRefreshTimer;
  List<Employee> _employees = const [];
  Map<int, String> _sectorNamesById = const {};
  _EmployeesOvertimeFilter _overtimeFilter = _EmployeesOvertimeFilter.todos;
  bool _isLoading = false;
  bool _isExportingExcel = false;
  bool _isFetchingEmployees = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _startAutoRefresh();
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
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      if (!mounted || _isFetchingEmployees || _isExportingExcel) {
        return;
      }
      _loadEmployees(showLoader: false, silentErrors: true);
    });
  }

  Future<void> _loadEmployees({
    bool showLoader = true,
    bool silentErrors = false,
  }) async {
    if (_isFetchingEmployees) {
      return;
    }

    _isFetchingEmployees = true;
    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final query = _searchController.text.trim();
      final employeesFuture = query.isEmpty
          ? widget.service.listEmployeesByCompany(widget.companyId)
          : widget.service.searchEmployeesByName(widget.companyId, query);
      final sectorNamesFuture = _loadSectorNamesById();
      final employees = await employeesFuture;
      final sectorNames = await sectorNamesFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _employees = employees;
        _sectorNamesById = sectorNames;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      if (silentErrors) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No se pudieron cargar empleados.')),
        );
    } finally {
      _isFetchingEmployees = false;
      if (mounted) {
        if (showLoader) {
          setState(() {
            _isLoading = false;
          });
        }
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
        content: Text('Desea eliminar a ${employeeDisplayName(employee)}?'),
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
    } on ArgumentError catch (error) {
      if (!mounted) {
        return;
      }
      final message =
          error.message?.toString() ?? 'No se pudo eliminar el empleado.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
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

  Future<Map<int, String>> _loadSectorNamesById() async {
    try {
      final departments = await widget.departmentService
          .listDepartmentsByCompany(widget.companyId);
      if (departments.isEmpty) {
        return const {};
      }

      final sectorLists = await Future.wait(
        departments.map(
          (department) =>
              widget.departmentService.listSectorsByDepartment(department.id),
        ),
      );

      final map = <int, String>{};
      for (final sectors in sectorLists) {
        for (final sector in sectors) {
          map[sector.id] = sector.name;
        }
      }
      return map;
    } catch (_) {
      return const {};
    }
  }

  String _sectorName(Employee employee) {
    final sectorId = employee.sectorId;
    if (sectorId == null) {
      return '-';
    }
    return _sectorNamesById[sectorId] ?? '-';
  }

  List<Employee> get _visibleEmployees {
    return _employees.where((employee) {
      switch (_overtimeFilter) {
        case _EmployeesOvertimeFilter.todos:
          return true;
        case _EmployeesOvertimeFilter.activa:
          return employee.allowOvertime;
        case _EmployeesOvertimeFilter.inactiva:
          return !employee.allowOvertime;
      }
    }).toList();
  }

  String _overtimeFilterLabel(_EmployeesOvertimeFilter filter) {
    switch (filter) {
      case _EmployeesOvertimeFilter.todos:
        return 'Horas extra: Todas';
      case _EmployeesOvertimeFilter.activa:
        return 'Horas extra: Activa';
      case _EmployeesOvertimeFilter.inactiva:
        return 'Horas extra: Inactiva';
    }
  }

  Future<void> _printFilteredEmployees() async {
    final employees = _visibleEmployees;
    if (employees.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No hay empleados para imprimir.')),
        );
      return;
    }

    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _EmployeesPrintPreviewScreen(
            fileName: _filteredEmployeesFileName(),
            buildPdf: (format) => _buildFilteredEmployeesPdf(
              pageFormat: format,
              employees: employees,
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No se pudo imprimir la lista.')),
        );
    }
  }

  Future<void> _exportFilteredEmployeesExcel() async {
    final employees = _visibleEmployees;
    if (employees.isEmpty || _isExportingExcel) {
      return;
    }

    setState(() {
      _isExportingExcel = true;
    });

    try {
      final bytes = _buildFilteredEmployeesExcelBytes(employees);
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar lista de empleados en Excel',
        fileName: _filteredEmployeesExcelFileName(),
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
      );
      if (savePath == null || savePath.trim().isEmpty) {
        return;
      }

      var resolvedPath = savePath;
      if (!resolvedPath.toLowerCase().endsWith('.xlsx')) {
        resolvedPath = '$resolvedPath.xlsx';
      }

      await File(resolvedPath).writeAsBytes(bytes, flush: true);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Excel exportado correctamente.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('No se pudo exportar Excel: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingExcel = false;
        });
      }
    }
  }

  String _filteredEmployeesFileName() {
    final companyPart = widget.companyName
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .toLowerCase();
    return 'empleados_filtrados_${companyPart.isEmpty ? 'empresa' : companyPart}.pdf';
  }

  String _filteredEmployeesExcelFileName() {
    final companyPart = widget.companyName
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .toLowerCase();
    return 'empleados_filtrados_${companyPart.isEmpty ? 'empresa' : companyPart}.xlsx';
  }

  Uint8List _buildFilteredEmployeesExcelBytes(List<Employee> employees) {
    final workbook = xl.Excel.createExcel();
    const sheetName = 'Empleados';
    final defaultSheet = workbook.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetName) {
      workbook.rename(defaultSheet, sheetName);
    }
    final sheet = workbook[sheetName];

    const headers = [
      'Nombre',
      'Documento',
      'Sector',
      'Cargo',
      'Lugar trabajo',
      'Horas extra',
      'Salario',
      'Estado',
    ];

    for (var col = 0; col < headers.length; col++) {
      final cell = xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0);
      sheet.cell(cell).value = xl.TextCellValue(headers[col]);
    }

    for (var row = 0; row < employees.length; row++) {
      final employee = employees[row];
      final values = [
        employeeDisplayName(employee),
        employee.documentNumber,
        _sectorName(employee),
        employee.jobTitle ?? '-',
        employee.workLocation ?? '-',
        employee.allowOvertime ? 'Activa' : 'Inactiva',
        _formatSalary(employee.baseSalary),
        employee.active ? 'Activo' : 'Inactivo',
      ];

      for (var col = 0; col < values.length; col++) {
        final cell = xl.CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: row + 1,
        );
        sheet.cell(cell).value = xl.TextCellValue(values[col]);
      }
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw StateError('No se pudo generar el archivo Excel.');
    }
    return Uint8List.fromList(bytes);
  }

  Future<Uint8List> _buildFilteredEmployeesPdf({
    required PdfPageFormat pageFormat,
    required List<Employee> employees,
  }) async {
    final now = DateTime.now();
    final generatedAt =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final search = _searchController.text.trim();

    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(18),
        build: (_) => [
          pw.Text(
            'Listado de empleados',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Empresa: ${widget.companyName}'),
          pw.Text(_overtimeFilterLabel(_overtimeFilter)),
          if (search.isNotEmpty) pw.Text('Busqueda: $search'),
          pw.Text('Generado: $generatedAt'),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Nombre',
              'Documento',
              'Sector',
              'Cargo',
              'Lugar trabajo',
              'Horas extra',
              'Salario',
              'Estado',
            ],
            data: employees
                .map(
                  (employee) => [
                    employeeDisplayName(employee),
                    employee.documentNumber,
                    _sectorName(employee),
                    employee.jobTitle ?? '-',
                    employee.workLocation ?? '-',
                    employee.allowOvertime ? 'Activa' : 'Inactiva',
                    _formatSalary(employee.baseSalary),
                    employee.active ? 'Activo' : 'Inactivo',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            border: const pw.TableBorder(
              left: pw.BorderSide(color: PdfColors.grey500, width: 0.4),
              right: pw.BorderSide(color: PdfColors.grey500, width: 0.4),
              top: pw.BorderSide(color: PdfColors.grey500, width: 0.4),
              bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.4),
              horizontalInside: pw.BorderSide(
                color: PdfColors.grey400,
                width: 0.3,
              ),
              verticalInside: pw.BorderSide(
                color: PdfColors.grey400,
                width: 0.3,
              ),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.6),
              1: pw.FlexColumnWidth(1.4),
              2: pw.FlexColumnWidth(1.4),
              3: pw.FlexColumnWidth(1.5),
              4: pw.FlexColumnWidth(1.5),
              5: pw.FlexColumnWidth(1.1),
              6: pw.FlexColumnWidth(1.3),
              7: pw.FlexColumnWidth(0.9),
            },
          ),
        ],
      ),
    );

    return document.save();
  }

  @override
  Widget build(BuildContext context) {
    final visibleEmployees = _visibleEmployees;

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
                    labelText: 'Buscar por nombre, documento o lugar trabajo',
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
              DropdownButton<_EmployeesOvertimeFilter>(
                value: _overtimeFilter,
                items: _EmployeesOvertimeFilter.values
                    .map(
                      (filter) => DropdownMenuItem<_EmployeesOvertimeFilter>(
                        value: filter,
                        child: Text(_overtimeFilterLabel(filter)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _overtimeFilter = value;
                  });
                },
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _isLoading || visibleEmployees.isEmpty
                    ? null
                    : _printFilteredEmployees,
                icon: const Icon(Icons.print),
                label: const Text('Imprimir'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed:
                    _isLoading || visibleEmployees.isEmpty || _isExportingExcel
                    ? null
                    : _exportFilteredEmployeesExcel,
                icon: const Icon(Icons.table_view),
                label: Text(
                  _isExportingExcel ? 'Exportando...' : 'Exportar Excel',
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: widget.canCreateEmployee
                    ? () => _openEmployeeForm()
                    : null,
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
                : visibleEmployees.isEmpty
                ? const Center(
                    child: Text(
                      'No hay empleados que coincidan con el filtro aplicado.',
                    ),
                  )
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
                        constraints: const BoxConstraints(minWidth: 1240),
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
                                DataColumn(label: Text('Sector')),
                                DataColumn(label: Text('Cargo')),
                                DataColumn(label: Text('Lugar trabajo')),
                                DataColumn(label: Text('Horas extra')),
                                DataColumn(label: Text('Salario')),
                                DataColumn(label: Text('Estado')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: visibleEmployees
                                  .map(
                                    (employee) => DataRow(
                                      cells: [
                                        DataCell(
                                          Text(employeeDisplayName(employee)),
                                        ),
                                        DataCell(Text(employee.documentNumber)),
                                        DataCell(Text(_sectorName(employee))),
                                        DataCell(
                                          Text(employee.jobTitle ?? '-'),
                                        ),
                                        DataCell(
                                          Text(employee.workLocation ?? '-'),
                                        ),
                                        DataCell(
                                          Text(
                                            employee.allowOvertime
                                                ? 'Activa'
                                                : 'Inactiva',
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
                                                onPressed:
                                                    widget.canUpdateEmployee
                                                    ? () => _openEmployeeForm(
                                                        employee: employee,
                                                      )
                                                    : null,
                                                icon: const Icon(Icons.edit),
                                              ),
                                              if (widget.canDeleteEmployee)
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

enum _EmployeesOvertimeFilter { todos, activa, inactiva }

class _EmployeesPrintPreviewScreen extends StatelessWidget {
  const _EmployeesPrintPreviewScreen({
    required this.fileName,
    required this.buildPdf,
  });

  final String fileName;
  final Future<Uint8List> Function(PdfPageFormat pageFormat) buildPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa de impresion')),
      body: PdfPreview(
        pdfFileName: fileName,
        initialPageFormat: PdfPageFormat.a4,
        canChangeOrientation: false,
        canChangePageFormat: false,
        build: (format) => buildPdf(format),
      ),
    );
  }
}
