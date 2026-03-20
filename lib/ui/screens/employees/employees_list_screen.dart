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
import '../../utils/safe_excel_decoder.dart';
import 'employee_form_dialog.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({
    required this.service,
    required this.departmentService,
    required this.companyId,
    required this.companyName,
    required this.isSuperAdmin,
    required this.canCreateEmployee,
    required this.canUpdateEmployee,
    required this.canDeleteEmployee,
    super.key,
  });

  final EmployeesService service;
  final DepartmentService departmentService;
  final int companyId;
  final String companyName;
  final bool isSuperAdmin;
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
  bool _isImportingExcel = false;
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
      if (!mounted ||
          _isFetchingEmployees ||
          _isExportingExcel ||
          _isImportingExcel) {
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

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfo(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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

  Future<void> _importEmployeesFromExcel() async {
    if (_isImportingExcel) {
      return;
    }

    try {
      await widget.service.ensureSuperAdminEmployeeImport();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$error')));
      return;
    }

    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      withData: true,
    );
    if (pickedFile == null || pickedFile.files.isEmpty) {
      return;
    }

    setState(() {
      _isImportingExcel = true;
    });

    try {
      final file = pickedFile.files.first;
      final bytes = file.bytes;
      final filePath = file.path;
      if (bytes == null && (filePath == null || filePath.isEmpty)) {
        throw ArgumentError('No se pudo leer el archivo seleccionado.');
      }
      final payload = bytes ?? await File(filePath!).readAsBytes();

      final workbook = decodeExcelBytesSafe(payload);
      if (workbook.tables.isEmpty) {
        throw ArgumentError('El archivo no contiene hojas para importar.');
      }

      final sheet = workbook.tables.values.first;
      final reference = await _loadEmployeeImportReference();
      final parsed = _parseEmployeeImportSheet(
        sheet: sheet,
        reference: reference,
      );

      final totalCandidateRows = parsed.rows.length;
      final totalParsedErrors = parsed.errors.length;
      if (totalCandidateRows <= 0 && totalParsedErrors <= 0) {
        _showInfo('El archivo no contiene filas de empleados para importar.');
        return;
      }

      final shouldProceed = await _confirmEmployeeImport(
        rowsToImport: totalCandidateRows,
        rowsWithErrors: totalParsedErrors,
      );
      if (shouldProceed != true) {
        return;
      }

      final importErrors = <String>[...parsed.errors];
      var imported = 0;
      for (final row in parsed.rows) {
        try {
          await widget.service.createEmployee(
            companyId: widget.companyId,
            departmentId: row.departmentId,
            sectorId: row.sectorId,
            jobTitle: row.jobTitle,
            workLocation: row.workLocation,
            firstNames: row.firstNames,
            lastNames: row.lastNames,
            documentNumber: row.documentNumber,
            hireDate: row.hireDate,
            employeeType: row.employeeType,
            baseSalary: row.baseSalary,
            ipsEnabled: row.ipsEnabled,
            childrenCount: row.childrenCount,
            allowOvertime: row.allowOvertime,
            biometricClockEnabled: true,
            hasEmbargo: false,
            phone: row.phone,
            address: row.address,
            active: row.active,
          );
          imported += 1;
        } catch (error) {
          importErrors.add('Fila ${row.rowNumber}: $error');
        }
      }

      if (imported > 0) {
        await _loadEmployees();
      }

      if (!mounted) {
        return;
      }

      await _showEmployeeImportResultDialog(
        imported: imported,
        failed: importErrors.length,
        errors: importErrors,
      );
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Archivo invalido.');
    } catch (error) {
      _showError('No se pudo importar empleados: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isImportingExcel = false;
        });
      }
    }
  }

  Future<_EmployeeImportReference> _loadEmployeeImportReference() async {
    final departments = await widget.departmentService.listDepartmentsByCompany(
      widget.companyId,
    );

    final sectorsByDepartment = await Future.wait(
      departments.map(
        (department) =>
            widget.departmentService.listSectorsByDepartment(department.id),
      ),
    );

    final sectors = <_EmployeeImportSectorReference>[];
    for (var index = 0; index < departments.length; index++) {
      final department = departments[index];
      final departmentSectors = sectorsByDepartment[index];
      for (final sector in departmentSectors) {
        sectors.add(
          _EmployeeImportSectorReference(
            department: department,
            sector: sector,
          ),
        );
      }
    }

    return _EmployeeImportReference(departments: departments, sectors: sectors);
  }

  _EmployeeImportParseResult _parseEmployeeImportSheet({
    required xl.Sheet sheet,
    required _EmployeeImportReference reference,
  }) {
    final rows = sheet.rows;
    if (rows.isEmpty) {
      throw ArgumentError('El archivo no contiene filas para importar.');
    }

    final headerRow = rows.first;
    final headerIndexes = <String, int>{};
    for (var i = 0; i < headerRow.length; i++) {
      final header = _normalizeImportHeader(_cellText(headerRow[i]));
      if (header.isNotEmpty && !headerIndexes.containsKey(header)) {
        headerIndexes[header] = i;
      }
    }

    int? findHeader(List<String> aliases) {
      for (final alias in aliases) {
        final normalized = _normalizeImportHeader(alias);
        final index = headerIndexes[normalized];
        if (index != null) {
          return index;
        }
      }
      return null;
    }

    final nombresIndex = findHeader(const ['nombres', 'nombre(s)']);
    final apellidosIndex = findHeader(const ['apellidos', 'apellido(s)']);
    final nombreCompletoIndex = findHeader(const ['nombre', 'nombre completo']);
    final documentoIndex = findHeader(const ['documento', 'cedula', 'ci']);
    final departamentoIndex = findHeader(const ['departamento', 'dpto']);
    final sectorIndex = findHeader(const ['sector']);
    final cargoIndex = findHeader(const ['cargo', 'puesto']);
    final lugarTrabajoIndex = findHeader(const [
      'lugar trabajo',
      'lugar de trabajo',
      'sede',
    ]);
    final salarioIndex = findHeader(const [
      'salario',
      'salario base',
      'sueldo',
    ]);
    final fechaIngresoIndex = findHeader(const [
      'fecha ingreso',
      'fecha de ingreso',
      'ingreso',
    ]);
    final tipoIndex = findHeader(const [
      'tipo',
      'tipo empleado',
      'tipo de empleado',
    ]);
    final horasExtraIndex = findHeader(const [
      'horas extra',
      'hora extra',
      'overtime',
    ]);
    final estadoIndex = findHeader(const ['estado', 'activo']);
    final ipsIndex = findHeader(const ['ips', 'aporta ips']);
    final hijosIndex = findHeader(const ['hijos', 'cantidad hijos']);
    final telefonoIndex = findHeader(const ['telefono', 'tel']);
    final direccionIndex = findHeader(const ['direccion', 'domicilio']);

    final missingColumns = <String>[];
    if (documentoIndex == null) {
      missingColumns.add('Documento');
    }
    if (departamentoIndex == null) {
      missingColumns.add('Departamento');
    }
    if (sectorIndex == null) {
      missingColumns.add('Sector');
    }
    if (cargoIndex == null) {
      missingColumns.add('Cargo');
    }
    if (lugarTrabajoIndex == null) {
      missingColumns.add('Lugar trabajo');
    }
    if (salarioIndex == null) {
      missingColumns.add('Salario');
    }
    final hasSplitNameColumns = nombresIndex != null && apellidosIndex != null;
    final hasFullNameColumn = nombreCompletoIndex != null;
    if (!hasSplitNameColumns && !hasFullNameColumn) {
      missingColumns.add('Nombres + Apellidos (o Nombre)');
    }

    if (missingColumns.isNotEmpty) {
      throw ArgumentError(
        'Faltan columnas requeridas: ${missingColumns.join(', ')}.',
      );
    }

    final parseErrors = <String>[];
    final parsedRows = <_EmployeeImportDraft>[];
    final seenDocuments = <String>{};

    for (var rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      final visualRow = rowIndex + 1;
      if (_isExcelRowBlank(row)) {
        continue;
      }

      final documento = _cellText(_cellAt(row, documentoIndex!)).trim();
      if (documento.isEmpty) {
        parseErrors.add('Fila $visualRow: Documento es obligatorio.');
        continue;
      }

      final normalizedDocument = _normalizeDocumentLookup(documento);
      if (normalizedDocument.isEmpty) {
        parseErrors.add(
          'Fila $visualRow: Documento invalido, use valores alfanumericos.',
        );
        continue;
      }
      if (!seenDocuments.add(normalizedDocument)) {
        parseErrors.add(
          'Fila $visualRow: Documento duplicado dentro del archivo ($documento).',
        );
        continue;
      }

      String firstNames;
      String lastNames;
      if (hasSplitNameColumns) {
        firstNames = _cellText(_cellAt(row, nombresIndex)).trim();
        lastNames = _cellText(_cellAt(row, apellidosIndex)).trim();
      } else {
        final fullName = _cellText(_cellAt(row, nombreCompletoIndex!)).trim();
        final parts = fullName
            .split(RegExp(r'\s+'))
            .where((part) => part.trim().isNotEmpty)
            .toList();
        if (parts.length < 2) {
          parseErrors.add(
            'Fila $visualRow: Nombre invalido. Use Nombres y Apellidos.',
          );
          continue;
        }
        firstNames = parts.sublist(0, parts.length - 1).join(' ');
        lastNames = parts.last;
      }

      if (firstNames.isEmpty || lastNames.isEmpty) {
        parseErrors.add(
          'Fila $visualRow: Nombres y Apellidos son obligatorios.',
        );
        continue;
      }

      final departamentoNombre = _cellText(
        _cellAt(row, departamentoIndex!),
      ).trim();
      final sectorNombre = _cellText(_cellAt(row, sectorIndex!)).trim();
      if (departamentoNombre.isEmpty || sectorNombre.isEmpty) {
        parseErrors.add(
          'Fila $visualRow: Departamento y Sector son obligatorios.',
        );
        continue;
      }

      final sectorMatch = _resolveSectorReference(
        reference: reference,
        departmentName: departamentoNombre,
        sectorName: sectorNombre,
      );
      if (sectorMatch == null) {
        parseErrors.add(
          'Fila $visualRow: Sector "$sectorNombre" no encontrado en Departamento "$departamentoNombre".',
        );
        continue;
      }

      final cargo = _cellText(_cellAt(row, cargoIndex!)).trim();
      if (cargo.isEmpty) {
        parseErrors.add('Fila $visualRow: Cargo es obligatorio.');
        continue;
      }

      final lugarTrabajo = _cellText(_cellAt(row, lugarTrabajoIndex!)).trim();
      if (lugarTrabajo.isEmpty) {
        parseErrors.add('Fila $visualRow: Lugar trabajo es obligatorio.');
        continue;
      }

      final salario = _cellToSalary(_cellAt(row, salarioIndex!));
      if (salario == null || salario <= 0) {
        parseErrors.add(
          'Fila $visualRow: Salario invalido. Debe ser mayor que cero.',
        );
        continue;
      }

      final hireDate = fechaIngresoIndex == null
          ? DateTime.now()
          : (_cellDate(_cellAt(row, fechaIngresoIndex)) ?? DateTime.now());

      final employeeTypeRaw = tipoIndex == null
          ? ''
          : _cellText(_cellAt(row, tipoIndex)).trim().toLowerCase();
      final employeeType = employeeTypeRaw.isEmpty
          ? 'mensual'
          : employeeTypeRaw;
      if (!_allowedImportEmployeeTypes.contains(employeeType)) {
        parseErrors.add(
          'Fila $visualRow: Tipo "$employeeTypeRaw" invalido (mensual, jornalero o servicio).',
        );
        continue;
      }

      final allowOvertime = horasExtraIndex == null
          ? true
          : (_parseBooleanCell(_cellAt(row, horasExtraIndex)) ?? true);
      final active = estadoIndex == null
          ? true
          : (_parseBooleanCell(_cellAt(row, estadoIndex)) ?? true);
      final ipsEnabled = ipsIndex == null
          ? null
          : _parseBooleanCell(_cellAt(row, ipsIndex));
      final childrenCount = hijosIndex == null
          ? 0
          : (_cellToInteger(_cellAt(row, hijosIndex)) ?? 0);
      if (childrenCount < 0) {
        parseErrors.add(
          'Fila $visualRow: Cantidad de hijos no puede ser negativa.',
        );
        continue;
      }

      final phone = telefonoIndex == null
          ? null
          : _toNullableText(_cellText(_cellAt(row, telefonoIndex)));
      final address = direccionIndex == null
          ? null
          : _toNullableText(_cellText(_cellAt(row, direccionIndex)));

      parsedRows.add(
        _EmployeeImportDraft(
          rowNumber: visualRow,
          departmentId: sectorMatch.department.id,
          sectorId: sectorMatch.sector.id,
          firstNames: firstNames,
          lastNames: lastNames,
          documentNumber: documento,
          jobTitle: cargo,
          workLocation: lugarTrabajo,
          hireDate: DateTime(hireDate.year, hireDate.month, hireDate.day),
          employeeType: employeeType,
          baseSalary: salario,
          allowOvertime: allowOvertime,
          active: active,
          ipsEnabled: ipsEnabled,
          childrenCount: childrenCount,
          phone: phone,
          address: address,
        ),
      );
    }

    return _EmployeeImportParseResult(rows: parsedRows, errors: parseErrors);
  }

  _EmployeeImportSectorReference? _resolveSectorReference({
    required _EmployeeImportReference reference,
    required String departmentName,
    required String sectorName,
  }) {
    final normalizedDepartment = _normalizeImportLookupValue(departmentName);
    final normalizedSector = _normalizeImportLookupValue(sectorName);
    if (normalizedDepartment.isEmpty || normalizedSector.isEmpty) {
      return null;
    }

    for (final entry in reference.sectors) {
      final entryDepartment = _normalizeImportLookupValue(
        entry.department.name,
      );
      final entrySector = _normalizeImportLookupValue(entry.sector.name);
      if (entryDepartment == normalizedDepartment &&
          entrySector == normalizedSector) {
        return entry;
      }
    }
    return null;
  }

  Future<bool?> _confirmEmployeeImport({
    required int rowsToImport,
    required int rowsWithErrors,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar empleados'),
        content: Text(
          'Filas listas para importar: $rowsToImport\n'
          'Filas con error (se omitiran): $rowsWithErrors\n\n'
          'Desea continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEmployeeImportResultDialog({
    required int imported,
    required int failed,
    required List<String> errors,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultado de importacion'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Importados: $imported'),
              Text('Con error: $failed'),
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Detalle de errores:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: SingleChildScrollView(
                    child: SelectableText(errors.join('\n')),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _normalizeImportHeader(String value) {
    var normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    replacements.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  String _normalizeImportLookupValue(String value) {
    return _normalizeImportHeader(value);
  }

  xl.Data? _cellAt(List<xl.Data?> row, int index) {
    if (index < 0 || index >= row.length) {
      return null;
    }
    return row[index];
  }

  String _cellText(xl.Data? cell) {
    final value = cell?.value;
    if (value == null) {
      return '';
    }
    return switch (value) {
      xl.TextCellValue() => value.value.text?.trim() ?? '',
      xl.IntCellValue() => value.value.toString(),
      xl.DoubleCellValue() => value.value.toString(),
      xl.BoolCellValue() => value.value ? 'true' : 'false',
      xl.DateCellValue() =>
        '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
      xl.DateTimeCellValue() =>
        '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
      xl.TimeCellValue() => value.asDuration.toString(),
      xl.FormulaCellValue() => value.formula.trim(),
    };
  }

  bool _isExcelRowBlank(List<xl.Data?> row) {
    for (final cell in row) {
      if (_cellText(cell).trim().isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  DateTime? _cellDate(xl.Data? cell) {
    final value = cell?.value;
    if (value == null) {
      return null;
    }
    final parsed = switch (value) {
      xl.DateCellValue() => value.asDateTimeLocal(),
      xl.DateTimeCellValue() => value.asDateTimeLocal(),
      xl.TextCellValue() => _tryParseImportDate(value.value.text ?? ''),
      _ => _tryParseImportDate(_cellText(cell)),
    };
    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  DateTime? _tryParseImportDate(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final iso = DateTime.tryParse(normalized);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    final compact = normalized.replaceAll('-', '/');
    final parts = compact.split('/');
    if (parts.length == 3) {
      final p0 = int.tryParse(parts[0]);
      final p1 = int.tryParse(parts[1]);
      final p2 = int.tryParse(parts[2]);
      if (p0 != null && p1 != null && p2 != null) {
        if (parts[0].length == 4) {
          return DateTime(p0, p1, p2);
        }
        return DateTime(p2, p1, p0);
      }
    }

    return null;
  }

  double? _cellToSalary(xl.Data? cell) {
    final value = cell?.value;
    if (value == null) {
      return null;
    }

    return switch (value) {
      xl.IntCellValue() => value.value.toDouble(),
      xl.DoubleCellValue() => value.value,
      xl.TextCellValue() => GuaraniCurrency.parse(value.value.text ?? ''),
      _ => GuaraniCurrency.parse(_cellText(cell)),
    };
  }

  int? _cellToInteger(xl.Data? cell) {
    final value = cell?.value;
    if (value == null) {
      return null;
    }
    return switch (value) {
      xl.IntCellValue() => value.value,
      xl.DoubleCellValue() => value.value.round(),
      xl.TextCellValue() => int.tryParse(
        (value.value.text ?? '').trim().replaceAll(RegExp(r'[^0-9-]'), ''),
      ),
      _ => int.tryParse(_cellText(cell).replaceAll(RegExp(r'[^0-9-]'), '')),
    };
  }

  bool? _parseBooleanCell(xl.Data? cell) {
    final raw = _cellText(cell).trim().toLowerCase();
    if (raw.isEmpty) {
      return null;
    }
    if (raw == 'true' ||
        raw == '1' ||
        raw == 'si' ||
        raw == 'sí' ||
        raw == 'activo' ||
        raw == 'activa' ||
        raw == 'yes' ||
        raw == 'y') {
      return true;
    }
    if (raw == 'false' ||
        raw == '0' ||
        raw == 'no' ||
        raw == 'inactivo' ||
        raw == 'inactiva' ||
        raw == 'n') {
      return false;
    }
    return null;
  }

  String? _toNullableText(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _normalizeDocumentLookup(String value) {
    final trimmed = value.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isNotEmpty) {
      return digitsOnly;
    }
    return trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
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
                    _isLoading ||
                        visibleEmployees.isEmpty ||
                        _isExportingExcel ||
                        _isImportingExcel
                    ? null
                    : _exportFilteredEmployeesExcel,
                icon: const Icon(Icons.table_view),
                label: Text(
                  _isExportingExcel ? 'Exportando...' : 'Exportar Excel',
                ),
              ),
              if (widget.isSuperAdmin) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _isLoading || _isImportingExcel
                      ? null
                      : _importEmployeesFromExcel,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _isImportingExcel ? 'Importando...' : 'Importar Excel',
                  ),
                ),
              ],
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: widget.canCreateEmployee && !_isImportingExcel
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

const Set<String> _allowedImportEmployeeTypes = {
  'mensual',
  'jornalero',
  'servicio',
};

class _EmployeeImportReference {
  const _EmployeeImportReference({
    required this.departments,
    required this.sectors,
  });

  final List<Department> departments;
  final List<_EmployeeImportSectorReference> sectors;
}

class _EmployeeImportSectorReference {
  const _EmployeeImportSectorReference({
    required this.department,
    required this.sector,
  });

  final Department department;
  final DepartmentSector sector;
}

class _EmployeeImportDraft {
  const _EmployeeImportDraft({
    required this.rowNumber,
    required this.departmentId,
    required this.sectorId,
    required this.firstNames,
    required this.lastNames,
    required this.documentNumber,
    required this.jobTitle,
    required this.workLocation,
    required this.hireDate,
    required this.employeeType,
    required this.baseSalary,
    required this.allowOvertime,
    required this.active,
    required this.ipsEnabled,
    required this.childrenCount,
    required this.phone,
    required this.address,
  });

  final int rowNumber;
  final int departmentId;
  final int sectorId;
  final String firstNames;
  final String lastNames;
  final String documentNumber;
  final String jobTitle;
  final String workLocation;
  final DateTime hireDate;
  final String employeeType;
  final double baseSalary;
  final bool allowOvertime;
  final bool active;
  final bool? ipsEnabled;
  final int childrenCount;
  final String? phone;
  final String? address;
}

class _EmployeeImportParseResult {
  const _EmployeeImportParseResult({required this.rows, required this.errors});

  final List<_EmployeeImportDraft> rows;
  final List<String> errors;
}

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
