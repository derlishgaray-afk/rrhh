import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../data/database/app_database.dart';
import '../../../services/attendance_service.dart';
import '../../../services/attendance_notes_markers.dart';
import '../../../services/company_settings_service.dart';
import '../../../services/employee_name_formatter.dart';
import '../../../services/employees_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    required this.service,
    required this.employeesService,
    required this.companySettingsService,
    required this.companyId,
    required this.companyName,
    required this.canImportClock,
    super.key,
  });

  final AttendanceService service;
  final EmployeesService employeesService;
  final CompanySettingsService companySettingsService;
  final int companyId;
  final String companyName;
  final bool canImportClock;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  static const List<String> _weekDayNames = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  final TextEditingController _searchController = TextEditingController();

  List<Employee> _activeEmployees = const [];
  List<AttendanceEvent> _events = const [];
  Set<DateTime> _holidayDates = <DateTime>{};
  Map<int, _EditableAttendanceRow> _rowsByEmployeeId = {};
  _AttendanceOvertimeFilter _selectedOvertimeFilter =
      _AttendanceOvertimeFilter.todos;
  _AttendanceStatusFilter _selectedStatusFilter = _AttendanceStatusFilter.todos;
  _AttendanceImportScope _selectedImportScope = _AttendanceImportScope.global;
  bool _isLoading = false;
  bool _isImporting = false;
  bool _isApplyingSpecialAbsence = false;
  bool _isAutoCompletingWithoutClock = false;
  bool _isSelectedPeriodLocked = false;
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  int get _daysInSelectedMonth =>
      DateTime(_selectedYear, _selectedMonth + 1, 0).day;

  DateTime get _selectedDate =>
      DateTime(_selectedYear, _selectedMonth, _selectedDay);

  bool get _isSelectedDateSunday => _selectedDate.weekday == DateTime.sunday;

  bool get _isSelectedDateHoliday => _isHoliday(_selectedDate);

  bool get _isSelectedDateSpecial =>
      _isSelectedDateSunday || _isSelectedDateHoliday;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDay = now.day;
    _searchController.addListener(() {
      setState(() {});
    });
    _loadData();
  }

  @override
  void didUpdateWidget(covariant AttendanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _disposeRows();
    super.dispose();
  }

  void _disposeRows() {
    for (final row in _rowsByEmployeeId.values) {
      row.dispose();
    }
    _rowsByEmployeeId = {};
  }

  void _replaceRows(Map<int, _EditableAttendanceRow> nextRows) {
    _disposeRows();
    _rowsByEmployeeId = nextRows;
  }

  Map<int, _EditableAttendanceRow> _buildRows({
    required List<Employee> employees,
    required List<AttendanceEvent> events,
  }) {
    final selectedDayEvents = <int, AttendanceEvent>{};

    for (final event in events) {
      if (!_isSameDay(event.date, _selectedDate)) {
        continue;
      }

      final current = selectedDayEvents[event.employeeId];
      if (current == null || event.id > current.id) {
        selectedDayEvents[event.employeeId] = event;
      }
    }

    final rows = <int, _EditableAttendanceRow>{};
    for (final employee in employees) {
      final event = selectedDayEvents[employee.id];
      final detail = attendanceUserDetailFromNotes(event?.notes) ?? '';
      rows[employee.id] = _EditableAttendanceRow(
        employee: employee,
        event: event,
        checkInController: TextEditingController(
          text: event?.checkInTime ?? '',
        ),
        checkOutController: TextEditingController(
          text: event?.checkOutTime ?? '',
        ),
        breakController: TextEditingController(
          text: (event?.breakMinutes ?? _defaultBreakMinutes).toString(),
        ),
        absenceType: _absenceTypeFromEventType(event?.eventType),
        detailController: TextEditingController(text: detail),
        sundaySurcharge100Enabled: hasSundaySurcharge100Marker(event?.notes),
      );
    }

    return rows;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait<dynamic>([
        widget.employeesService.listActiveEmployeesByCompany(widget.companyId),
        widget.service.listAttendanceByMonth(
          companyId: widget.companyId,
          year: _selectedYear,
          month: _selectedMonth,
        ),
        widget.companySettingsService.getOrCreateSettings(widget.companyId),
        widget.service.isAttendancePeriodLocked(
          companyId: widget.companyId,
          year: _selectedYear,
          month: _selectedMonth,
        ),
      ]);

      final activeEmployees = results[0] as List<Employee>;
      final events = results[1] as List<AttendanceEvent>;
      final settings = results[2] as CompanySetting;
      final isPeriodLocked = results[3] as bool;
      final rows = _buildRows(employees: activeEmployees, events: events);
      final holidayDates = widget.companySettingsService.parseHolidayDates(
        settings.holidayDates,
      );

      if (!mounted) {
        for (final row in rows.values) {
          row.dispose();
        }
        return;
      }

      setState(() {
        _activeEmployees = activeEmployees;
        _events = events;
        _holidayDates = holidayDates;
        _isSelectedPeriodLocked = isPeriodLocked;
        _replaceRows(rows);
      });
    } catch (_) {
      _showError('No se pudo cargar asistencia.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reloadMonthEvents() async {
    final results = await Future.wait<dynamic>([
      widget.service.listAttendanceByMonth(
        companyId: widget.companyId,
        year: _selectedYear,
        month: _selectedMonth,
      ),
      widget.service.isAttendancePeriodLocked(
        companyId: widget.companyId,
        year: _selectedYear,
        month: _selectedMonth,
      ),
    ]);
    final events = results[0] as List<AttendanceEvent>;
    final isPeriodLocked = results[1] as bool;

    final rows = _buildRows(employees: _activeEmployees, events: events);
    if (!mounted) {
      for (final row in rows.values) {
        row.dispose();
      }
      return;
    }

    setState(() {
      _events = events;
      _isSelectedPeriodLocked = isPeriodLocked;
      _replaceRows(rows);
    });
  }

  void _moveDay(int direction) {
    final nextDay = _selectedDay + direction;
    if (nextDay < 1 || nextDay > _daysInSelectedMonth) {
      return;
    }

    setState(() {
      _selectedDay = nextDay;
      final rows = _buildRows(employees: _activeEmployees, events: _events);
      _replaceRows(rows);
    });
  }

  Future<void> _changeMonth(int month) async {
    if (_selectedMonth == month) {
      return;
    }

    final maxDay = DateTime(_selectedYear, month + 1, 0).day;
    setState(() {
      _selectedMonth = month;
      if (_selectedDay > maxDay) {
        _selectedDay = maxDay;
      }
    });

    await _loadData();
  }

  Future<void> _changeYear(int year) async {
    if (_selectedYear == year) {
      return;
    }

    final maxDay = DateTime(year, _selectedMonth + 1, 0).day;
    setState(() {
      _selectedYear = year;
      if (_selectedDay > maxDay) {
        _selectedDay = maxDay;
      }
    });

    await _loadData();
  }

  Set<int> _completedDaysInSelectedMonth() {
    if (_activeEmployees.isEmpty) {
      return const <int>{};
    }

    final latestEventByDayAndEmployee = <int, Map<int, AttendanceEvent>>{};
    for (final event in _events) {
      if (event.date.year != _selectedYear ||
          event.date.month != _selectedMonth) {
        continue;
      }

      final byEmployee = latestEventByDayAndEmployee.putIfAbsent(
        event.date.day,
        () => <int, AttendanceEvent>{},
      );
      final current = byEmployee[event.employeeId];
      if (current == null || event.id > current.id) {
        byEmployee[event.employeeId] = event;
      }
    }

    final completedDays = <int>{};
    for (var day = 1; day <= _daysInSelectedMonth; day++) {
      final byEmployee = latestEventByDayAndEmployee[day];
      if (byEmployee == null) {
        continue;
      }

      var dayIsComplete = true;
      for (final employee in _activeEmployees) {
        final event = byEmployee[employee.id];
        if (event == null) {
          dayIsComplete = false;
          break;
        }

        if (event.eventType == 'presente' &&
            !_isPresentAttendanceComplete(event, employee)) {
          dayIsComplete = false;
          break;
        }
      }

      if (dayIsComplete) {
        completedDays.add(day);
      }
    }

    return completedDays;
  }

  Future<void> _openCalendarOverview() async {
    if (_isLoading) {
      return;
    }

    final selectedDay = await showDialog<int>(
      context: context,
      builder: (_) => _AttendanceMonthCalendarDialog(
        year: _selectedYear,
        month: _selectedMonth,
        selectedDay: _selectedDay,
        daysInMonth: _daysInSelectedMonth,
        completedDays: _completedDaysInSelectedMonth(),
      ),
    );

    if (!mounted || selectedDay == null || selectedDay == _selectedDay) {
      return;
    }

    setState(() {
      _selectedDay = selectedDay;
      final rows = _buildRows(employees: _activeEmployees, events: _events);
      _replaceRows(rows);
    });
  }

  Future<void> _openEmployeeMonthlySummaryDialog() async {
    if (_isLoading) {
      return;
    }

    try {
      final employees = await widget.employeesService.listEmployeesByCompany(
        widget.companyId,
      );
      if (!mounted) {
        return;
      }
      if (employees.isEmpty) {
        _showInfo('No hay empleados registrados para mostrar resumen.');
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (_) => _EmployeeMonthlySummaryDialog(
          employees: employees,
          companyName: _summaryCompanyName,
          year: _selectedYear,
          month: _selectedMonth,
          buildRowsForEmployee: _buildEmployeeMonthlySummaryRows,
          onShare: _shareEmployeeMonthlySummary,
          onPrint: _printEmployeeMonthlySummary,
        ),
      );
    } catch (_) {
      _showError('No se pudo abrir resumen por empleado.');
    }
  }

  List<_EmployeeMonthSummaryRow> _buildEmployeeMonthlySummaryRows(
    Employee employee,
  ) {
    final latestEventByDay = <int, AttendanceEvent>{};
    for (final event in _events) {
      if (event.employeeId != employee.id ||
          event.date.year != _selectedYear ||
          event.date.month != _selectedMonth) {
        continue;
      }

      final current = latestEventByDay[event.date.day];
      if (current == null || event.id > current.id) {
        latestEventByDay[event.date.day] = event;
      }
    }

    final rows = <_EmployeeMonthSummaryRow>[];
    for (var day = 1; day <= _daysInSelectedMonth; day++) {
      final date = DateTime(_selectedYear, _selectedMonth, day);
      final event = latestEventByDay[day];
      final weekDayLabel = _capitalize(_weekDayNames[date.weekday - 1]);

      if (event == null) {
        rows.add(
          _EmployeeMonthSummaryRow(
            day: day,
            dateLabel: _formatDateShort(date),
            weekDayLabel: weekDayLabel,
            checkIn: '',
            checkOut: '',
            breakMinutes: '',
            absenceLabel: '',
            detail: '',
            hoursLabel: '',
            statusLabel: 'Pendiente',
            isPending: true,
          ),
        );
        continue;
      }

      if (event.eventType == 'presente') {
        final isComplete = _isPresentAttendanceComplete(event, employee);
        final workedHours =
            event.hoursWorked ??
            _computeHoursFromText(
              employee: employee,
              checkInText: event.checkInTime ?? '',
              checkOutText: event.checkOutTime ?? '',
              breakMinutes: event.breakMinutes ?? _defaultBreakMinutes,
              date: event.date,
            );
        rows.add(
          _EmployeeMonthSummaryRow(
            day: day,
            dateLabel: _formatDateShort(date),
            weekDayLabel: weekDayLabel,
            checkIn: event.checkInTime ?? '',
            checkOut: event.checkOutTime ?? '',
            breakMinutes: event.breakMinutes?.toString() ?? '',
            absenceLabel: 'Presente',
            detail: attendanceUserDetailFromNotes(event.notes) ?? '',
            hoursLabel: workedHours == null
                ? ''
                : workedHours.toStringAsFixed(2),
            statusLabel: isComplete ? 'Completo' : 'Pendiente',
            isPending: !isComplete,
          ),
        );
        continue;
      }

      rows.add(
        _EmployeeMonthSummaryRow(
          day: day,
          dateLabel: _formatDateShort(date),
          weekDayLabel: weekDayLabel,
          checkIn: event.checkInTime ?? '',
          checkOut: event.checkOutTime ?? '',
          breakMinutes: event.breakMinutes?.toString() ?? '',
          absenceLabel: _eventTypeLabel(event.eventType),
          detail: attendanceUserDetailFromNotes(event.notes) ?? '',
          hoursLabel: event.hoursWorked?.toStringAsFixed(2) ?? '',
          statusLabel: _eventTypeLabel(event.eventType),
          isPending: false,
        ),
      );
    }

    return rows;
  }

  Future<void> _shareEmployeeMonthlySummary(
    Employee employee,
    List<_EmployeeMonthSummaryRow> rows,
  ) async {
    final bytes = await _buildEmployeeMonthlySummaryPdfBytes(
      employee: employee,
      rows: rows,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${_employeeMonthlySummaryBaseFileName(employee)}.pdf',
    );
  }

  Future<void> _printEmployeeMonthlySummary(
    Employee employee,
    List<_EmployeeMonthSummaryRow> rows,
  ) async {
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AttendanceEmployeeSummaryPrintPreviewScreen(
          fileName: '${_employeeMonthlySummaryBaseFileName(employee)}.pdf',
          buildPdf: (format) => _buildEmployeeMonthlySummaryPdfBytes(
            employee: employee,
            rows: rows,
            pageFormat: format,
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _buildEmployeeMonthlySummaryPdfBytes({
    required Employee employee,
    required List<_EmployeeMonthSummaryRow> rows,
    PdfPageFormat? pageFormat,
  }) async {
    final document = pw.Document();
    final effectivePageFormat = pageFormat ?? PdfPageFormat.a4;
    final monthLabel = _monthNames[_selectedMonth - 1];
    final periodLabel = '$monthLabel $_selectedYear';

    document.addPage(
      pw.MultiPage(
        pageFormat: effectivePageFormat,
        margin: const pw.EdgeInsets.all(20),
        build: (_) => [
          pw.Text(
            'Resumen de Asistencia por Empleado',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Empleado: ${employeeDisplayName(employee)}'),
          pw.Text('Empresa: $_summaryCompanyName'),
          pw.Text('Documento: ${employee.documentNumber}'),
          pw.Text('Periodo: $periodLabel'),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Dia',
              'Semana',
              'Entrada',
              'Salida',
              'Desc.',
              'Ausencia',
              'Detalle',
              'Horas',
            ],
            data: rows
                .map(
                  (row) => [
                    row.day.toString(),
                    row.weekDayLabel,
                    row.checkIn,
                    row.checkOut,
                    row.breakMinutes,
                    row.absenceLabel,
                    row.detail,
                    row.hoursLabel,
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
              0: pw.FlexColumnWidth(0.7),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(1.0),
              3: pw.FlexColumnWidth(1.0),
              4: pw.FlexColumnWidth(0.8),
              5: pw.FlexColumnWidth(1.3),
              6: pw.FlexColumnWidth(2.4),
              7: pw.FlexColumnWidth(0.9),
            },
            cellAlignments: {
              0: pw.Alignment.centerRight,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerLeft,
              6: pw.Alignment.centerLeft,
              7: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    return document.save();
  }

  String _employeeMonthlySummaryBaseFileName(Employee employee) {
    final employeePart = _sanitizeFileNamePart(employeeDisplayName(employee));
    final month = _selectedMonth.toString().padLeft(2, '0');
    return 'asistencia_empleado_${employeePart}_${_selectedYear}_$month';
  }

  String _sanitizeFileNamePart(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .toLowerCase();
  }

  String get _summaryCompanyName {
    final normalized = widget.companyName.trim();
    return normalized.isEmpty ? 'Empresa' : normalized;
  }

  String _formatDateShort(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _selectedPeriodLabel() {
    final month = _selectedMonth.toString().padLeft(2, '0');
    return '$month/$_selectedYear';
  }

  bool _isEditionBlockedByLockedPeriod() {
    if (!_isSelectedPeriodLocked) {
      return false;
    }
    _showInfo(
      'No se puede editar asistencia de ${_selectedPeriodLabel()} porque la liquidacion esta guardada y bloqueada.',
    );
    return true;
  }

  Future<void> _importClockMarks() async {
    if (_isLoading || _isImporting) {
      return;
    }
    if (_isEditionBlockedByLockedPeriod()) {
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

    List<_ImportPreviewRow> previewRows = const [];
    try {
      setState(() {
        _isImporting = true;
      });

      final file = pickedFile.files.first;
      final bytes = file.bytes;
      final filePath = file.path;
      if (bytes == null && (filePath == null || filePath.isEmpty)) {
        throw ArgumentError('No se pudo leer el archivo seleccionado.');
      }

      final payload = bytes ?? await File(filePath!).readAsBytes();

      final workbook = xl.Excel.decodeBytes(payload);
      if (workbook.tables.isEmpty) {
        throw ArgumentError('El archivo no contiene hojas para importar.');
      }

      final sheet = workbook.tables.values.first;
      final marks = _extractClockMarks(sheet);
      final entries = _buildImportEntriesForSelectedDate(marks);

      if (entries.isEmpty) {
        _showInfo('No se encontraron marcaciones para el dia seleccionado.');
        return;
      }

      final employeesForLookup = await _employeesForImportScope();
      previewRows = _buildImportPreviewRows(
        entries: entries,
        employeesForLookup: employeesForLookup,
      );
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Archivo invalido.');
    } catch (_) {
      _showError('No se pudo importar marcaciones.');
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }

    if (!mounted || previewRows.isEmpty) {
      return;
    }

    final shouldImport = await _showImportPreviewDialog(previewRows);
    if (!mounted || shouldImport != true) {
      return;
    }

    await _applyImportPreview(previewRows);
  }

  Future<List<Employee>> _employeesForImportScope() async {
    switch (_selectedImportScope) {
      case _AttendanceImportScope.global:
        return widget.employeesService.listEmployeesAccessibleCompanies();
      case _AttendanceImportScope.activeCompany:
        return _activeEmployees;
    }
  }

  List<_ImportPreviewRow> _buildImportPreviewRows({
    required List<_ImportedAttendanceEntry> entries,
    required List<Employee> employeesForLookup,
  }) {
    final employeesByDocument = <String, List<Employee>>{};
    for (final employee in employeesForLookup) {
      final normalizedDocument = _normalizeDocumentNumber(
        employee.documentNumber,
      );
      if (normalizedDocument.isNotEmpty) {
        employeesByDocument
            .putIfAbsent(normalizedDocument, () => [])
            .add(employee);
      }
    }

    final rows = <_ImportPreviewRow>[];
    for (final entry in entries) {
      final normalizedDocument = _normalizeDocumentNumber(entry.document);
      final matches = employeesByDocument[normalizedDocument] ?? const [];
      final employee = _resolveEmployeeForImport(matches);

      if (employee == null) {
        rows.add(
          _ImportPreviewRow(
            document: entry.document,
            checkIn: entry.checkIn,
            checkOut: entry.checkOut,
            status: _ImportPreviewStatus.withoutEmployee,
            companyId: null,
            employeeId: null,
            employeeName: null,
          ),
        );
        continue;
      }

      final baseName = employeeDisplayName(employee);
      final displayName = _selectedImportScope == _AttendanceImportScope.global
          ? '$baseName (Emp. ${employee.companyId})'
          : baseName;

      if (!employee.biometricClockEnabled) {
        rows.add(
          _ImportPreviewRow(
            document: entry.document,
            checkIn: entry.checkIn,
            checkOut: entry.checkOut,
            status: _ImportPreviewStatus.withoutClockMarking,
            companyId: employee.companyId,
            employeeId: employee.id,
            employeeName: displayName,
          ),
        );
        continue;
      }

      if (entry.checkOut == null) {
        rows.add(
          _ImportPreviewRow(
            document: entry.document,
            checkIn: entry.checkIn,
            checkOut: null,
            status: _ImportPreviewStatus.pending,
            companyId: employee.companyId,
            employeeId: employee.id,
            employeeName: displayName,
          ),
        );
        continue;
      }

      rows.add(
        _ImportPreviewRow(
          document: entry.document,
          checkIn: entry.checkIn,
          checkOut: entry.checkOut,
          status: _ImportPreviewStatus.complete,
          companyId: employee.companyId,
          employeeId: employee.id,
          employeeName: displayName,
        ),
      );
    }

    rows.sort((a, b) {
      final employeeA = (a.employeeName ?? '').toLowerCase();
      final employeeB = (b.employeeName ?? '').toLowerCase();
      if (employeeA != employeeB) {
        return employeeA.compareTo(employeeB);
      }
      return a.document.compareTo(b.document);
    });

    return rows;
  }

  Employee? _resolveEmployeeForImport(List<Employee> matches) {
    if (matches.isEmpty) {
      return null;
    }

    final sorted = [...matches]
      ..sort((left, right) {
        final byActive = _boolScore(right.active) - _boolScore(left.active);
        if (byActive != 0) {
          return byActive;
        }

        final byActiveCompany =
            _boolScore(right.companyId == widget.companyId) -
            _boolScore(left.companyId == widget.companyId);
        if (byActiveCompany != 0) {
          return byActiveCompany;
        }

        return left.id.compareTo(right.id);
      });

    return sorted.first;
  }

  int _boolScore(bool value) => value ? 1 : 0;

  Future<bool?> _showImportPreviewDialog(List<_ImportPreviewRow> rows) {
    return showDialog<bool>(
      context: context,
      builder: (_) => _ImportPreviewDialog(
        rows: rows,
        selectedDate: _selectedDate,
        formatTime: _formatTime,
      ),
    );
  }

  Future<void> _applyImportPreview(List<_ImportPreviewRow> rows) async {
    if (_isEditionBlockedByLockedPeriod()) {
      return;
    }

    setState(() {
      _isImporting = true;
    });

    try {
      var importedCompleteCount = 0;
      var importedPendingCount = 0;
      var withoutEmployeeCount = 0;
      var withoutClockMarkingCount = 0;
      var failedCount = 0;

      for (final rowPreview in rows) {
        switch (rowPreview.status) {
          case _ImportPreviewStatus.withoutEmployee:
            withoutEmployeeCount += 1;
            continue;
          case _ImportPreviewStatus.withoutClockMarking:
            withoutClockMarkingCount += 1;
            continue;
          case _ImportPreviewStatus.pending:
          case _ImportPreviewStatus.complete:
            break;
        }

        final employeeId = rowPreview.employeeId;
        final companyId = rowPreview.companyId;
        if (employeeId == null || companyId == null) {
          failedCount += 1;
          continue;
        }

        final row = _rowsByEmployeeId[employeeId];
        final breakMinutes =
            _parseBreakMinutes(row?.breakController.text ?? '') ??
            _defaultBreakMinutes;

        try {
          await widget.service.upsertDailyAttendanceFromImport(
            companyId: companyId,
            employeeId: employeeId,
            date: _selectedDate,
            checkInTime: _formatTime(rowPreview.checkIn),
            checkOutTime: rowPreview.checkOut == null
                ? null
                : _formatTime(rowPreview.checkOut!),
            breakMinutes: breakMinutes,
          );
          if (rowPreview.status == _ImportPreviewStatus.complete) {
            importedCompleteCount += 1;
          } else {
            importedPendingCount += 1;
          }
        } catch (_) {
          failedCount += 1;
        }
      }

      await _reloadMonthEvents();

      if (!mounted) {
        return;
      }

      final summary = <String>[
        'Completadas: $importedCompleteCount',
        'Pendientes: $importedPendingCount',
        'Sin empleado: $withoutEmployeeCount',
        'Sin marcacion: $withoutClockMarkingCount',
        'Con error: $failedCount',
      ].join(' | ');
      _showInfo('Importacion finalizada. $summary');
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  List<_ImportedClockMark> _extractClockMarks(xl.Sheet sheet) {
    final rows = sheet.rows;
    if (rows.isEmpty) {
      return const [];
    }

    final headers = rows.first;
    var acNoIndex = -1;
    var dateTimeIndex = -1;
    var stateIndex = -1;

    var empNoIndex = -1;
    var nombreIndex = -1;
    var summaryDateIndex = -1;
    var startTimeIndex = -1;
    var endTimeIndex = -1;

    for (var i = 0; i < headers.length; i++) {
      final normalizedHeader = _normalizeHeader(_cellText(headers[i]));
      if (normalizedHeader == 'acno') {
        acNoIndex = i;
      } else if (normalizedHeader == 'fechahora') {
        dateTimeIndex = i;
      } else if (normalizedHeader == 'estado') {
        stateIndex = i;
      } else if (normalizedHeader == 'empno') {
        empNoIndex = i;
      } else if (normalizedHeader == 'nombre') {
        nombreIndex = i;
      } else if (normalizedHeader.contains('fecha')) {
        summaryDateIndex = i;
      } else if (normalizedHeader == 'tieminicio' ||
          (normalizedHeader.contains('inicio') &&
              !normalizedHeader.contains('fecha'))) {
        startTimeIndex = i;
      } else if (normalizedHeader == 'tiemfinal' ||
          (normalizedHeader.contains('final') &&
              !normalizedHeader.contains('fecha'))) {
        endTimeIndex = i;
      }
    }

    // Formato detallado: AC-No. + Fecha/Hora + Estado
    if (acNoIndex >= 0 && dateTimeIndex >= 0 && stateIndex >= 0) {
      final marks = <_ImportedClockMark>[];
      for (var rowIndex = 1; rowIndex < rows.length; rowIndex++) {
        final row = rows[rowIndex];
        final document = _cellText(_cellAt(row, acNoIndex));
        final markDateTime = _cellDateTime(_cellAt(row, dateTimeIndex));
        final state = _cellText(_cellAt(row, stateIndex));

        if (document.isEmpty || markDateTime == null || state.isEmpty) {
          continue;
        }

        marks.add(
          _ImportedClockMark(
            document: document,
            dateTime: markDateTime,
            state: state,
          ),
        );
      }
      return marks;
    }

    // Formato resumen: Emp No/AC-No + Fecha + TiemInicio + TiemFinal
    if (summaryDateIndex < 0) {
      summaryDateIndex = _guessDateColumnIndex(
        rows: rows,
        excludedColumns: <int>{
          empNoIndex,
          acNoIndex,
          nombreIndex,
          startTimeIndex,
          endTimeIndex,
        },
      );
    }

    if (startTimeIndex < 0) {
      for (var i = 0; i < headers.length; i++) {
        if (i == endTimeIndex) {
          continue;
        }
        final normalizedHeader = _normalizeHeader(_cellText(headers[i]));
        if (normalizedHeader.contains('tiem') ||
            normalizedHeader.contains('hora') ||
            normalizedHeader.contains('inicio')) {
          startTimeIndex = i;
          break;
        }
      }
    }

    if (endTimeIndex < 0) {
      for (var i = 0; i < headers.length; i++) {
        if (i == startTimeIndex) {
          continue;
        }
        final normalizedHeader = _normalizeHeader(_cellText(headers[i]));
        if (normalizedHeader.contains('final') ||
            normalizedHeader.contains('salida') ||
            normalizedHeader.contains('fin')) {
          endTimeIndex = i;
          break;
        }
      }
    }

    final documentIndexCandidates = [
      empNoIndex,
      acNoIndex,
      nombreIndex,
    ].where((index) => index >= 0).toList();

    if (documentIndexCandidates.isEmpty ||
        summaryDateIndex < 0 ||
        startTimeIndex < 0) {
      throw ArgumentError(
        'No se encontraron columnas requeridas para importar marcaciones.',
      );
    }

    final marks = <_ImportedClockMark>[];
    for (var rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      final document = _pickDocumentForSummaryRow(
        row: row,
        documentIndexCandidates: documentIndexCandidates,
      );
      final date = _cellDateOnly(_cellAt(row, summaryDateIndex));
      final checkInMinutes = _cellTimeMinutes(_cellAt(row, startTimeIndex));

      if (document.isEmpty || date == null || checkInMinutes == null) {
        continue;
      }

      final checkInDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        checkInMinutes ~/ 60,
        checkInMinutes % 60,
      );
      marks.add(
        _ImportedClockMark(
          document: document,
          dateTime: checkInDateTime,
          state: 'entrada',
        ),
      );

      if (endTimeIndex < 0) {
        continue;
      }

      final checkOutMinutes = _cellTimeMinutes(_cellAt(row, endTimeIndex));
      if (checkOutMinutes == null) {
        continue;
      }

      var checkOutDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        checkOutMinutes ~/ 60,
        checkOutMinutes % 60,
      );
      if (!checkOutDateTime.isAfter(checkInDateTime)) {
        checkOutDateTime = checkOutDateTime.add(const Duration(days: 1));
      }

      marks.add(
        _ImportedClockMark(
          document: document,
          dateTime: checkOutDateTime,
          state: 'salida',
        ),
      );
    }

    return marks;
  }

  String _pickDocumentForSummaryRow({
    required List<xl.Data?> row,
    required List<int> documentIndexCandidates,
  }) {
    for (final index in documentIndexCandidates) {
      final candidate = _normalizeDocumentNumber(
        _cellText(_cellAt(row, index)),
      );
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }
    return '';
  }

  int _guessDateColumnIndex({
    required List<List<xl.Data?>> rows,
    required Set<int> excludedColumns,
  }) {
    if (rows.isEmpty) {
      return -1;
    }

    var maxColumns = 0;
    for (final row in rows) {
      if (row.length > maxColumns) {
        maxColumns = row.length;
      }
    }

    var selectedIndex = -1;
    var selectedScore = 0;
    for (var column = 0; column < maxColumns; column++) {
      if (excludedColumns.contains(column)) {
        continue;
      }

      var score = 0;
      for (
        var rowIndex = 1;
        rowIndex < rows.length && rowIndex <= 40;
        rowIndex++
      ) {
        final row = rows[rowIndex];
        final parsed = _cellDateOnly(_cellAt(row, column));
        if (parsed != null) {
          score += 1;
        }
      }

      if (score > selectedScore) {
        selectedScore = score;
        selectedIndex = column;
      }
    }

    return selectedScore > 0 ? selectedIndex : -1;
  }

  List<_ImportedAttendanceEntry> _buildImportEntriesForSelectedDate(
    List<_ImportedClockMark> marks,
  ) {
    final marksByDocument = <String, List<_ImportedClockMark>>{};
    for (final mark in marks) {
      marksByDocument.putIfAbsent(mark.document, () => []).add(mark);
    }

    final entries = <_ImportedAttendanceEntry>[];
    for (final bucket in marksByDocument.entries) {
      final sortedMarks = [...bucket.value]
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

      DateTime? openEntry;
      final shifts = <_ImportedShift>[];

      for (final mark in sortedMarks) {
        final type = _markType(mark.state);
        if (type == null) {
          continue;
        }

        if (type == _ClockMarkType.entry) {
          if (openEntry != null) {
            shifts.add(_ImportedShift(checkIn: openEntry));
          }
          openEntry = mark.dateTime;
          continue;
        }

        if (openEntry == null) {
          continue;
        }

        if (mark.dateTime.isAfter(openEntry)) {
          shifts.add(
            _ImportedShift(checkIn: openEntry, checkOut: mark.dateTime),
          );
          openEntry = null;
        }
      }

      if (openEntry != null) {
        shifts.add(_ImportedShift(checkIn: openEntry));
      }

      final dayShifts = shifts
          .where((shift) => _isSameDay(shift.checkIn, _selectedDate))
          .toList();

      if (dayShifts.isEmpty) {
        continue;
      }

      final earliestCheckIn = dayShifts
          .map((shift) => shift.checkIn)
          .reduce((a, b) => a.isBefore(b) ? a : b);

      DateTime? latestCheckOut;
      for (final shift in dayShifts) {
        final checkOut = shift.checkOut;
        if (checkOut == null) {
          continue;
        }
        if (latestCheckOut == null || checkOut.isAfter(latestCheckOut)) {
          latestCheckOut = checkOut;
        }
      }

      entries.add(
        _ImportedAttendanceEntry(
          document: bucket.key,
          checkIn: earliestCheckIn,
          checkOut: latestCheckOut,
        ),
      );
    }

    return entries;
  }

  Future<void> _saveRow(
    _EditableAttendanceRow row, {
    bool? sundaySurcharge100Override,
    String? successMessage,
  }) async {
    if (row.isSaving) {
      return;
    }
    if (_isEditionBlockedByLockedPeriod()) {
      return;
    }

    if (_isRowLockedBySpecialAbsence(row)) {
      _showInfo(
        'El registro esta bloqueado por ausencia automatica de ${_selectedSpecialDayLabel() ?? 'dia especial'}.',
      );
      return;
    }

    final eventType = _eventTypeFromAbsenceType(row.absenceType);
    int? breakMinutes;
    if (eventType == null) {
      breakMinutes = _parseBreakMinutes(row.breakController.text);
      if (breakMinutes == null) {
        _showError('El descanso debe ser un numero entero en minutos.');
        return;
      }
    }
    final storedNotes = _buildStoredNotesForRow(
      row: row,
      eventType: eventType,
      sundaySurcharge100Override: sundaySurcharge100Override,
    );

    setState(() {
      row.isSaving = true;
    });

    try {
      await widget.service.upsertDailyAttendance(
        companyId: widget.companyId,
        employeeId: row.employee.id,
        date: _selectedDate,
        checkInTime: row.checkInController.text,
        checkOutTime: row.checkOutController.text,
        breakMinutes: breakMinutes,
        eventType: eventType,
        notes: storedNotes,
      );
      await _reloadMonthEvents();
      if (!mounted) {
        return;
      }
      _showInfo(
        successMessage ??
            'Asistencia guardada para ${employeeDisplayName(row.employee)}.',
      );
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Datos invalidos.');
    } catch (error) {
      _showError('No se pudo guardar la asistencia: $error');
    } finally {
      if (mounted) {
        final currentRow = _rowsByEmployeeId[row.employee.id];
        if (identical(currentRow, row)) {
          setState(() {
            row.isSaving = false;
          });
        }
      }
    }
  }

  bool _canApplySundaySurcharge(_EditableAttendanceRow row) {
    return _isSelectedDateSunday &&
        row.employee.allowOvertime &&
        row.absenceType == _AttendanceAbsenceType.none;
  }

  String? _buildStoredNotesForRow({
    required _EditableAttendanceRow row,
    required String? eventType,
    bool? sundaySurcharge100Override,
  }) {
    final isPresentEvent = eventType == null;
    final sundaySurcharge100Enabled =
        (sundaySurcharge100Override ?? row.sundaySurcharge100Enabled) &&
        isPresentEvent &&
        _canApplySundaySurcharge(row);

    // Siempre devolvemos string para que AttendanceService tome `notes` como
    // input explicito y permita limpiar marcadores/notas cuando corresponda.
    return composeAttendanceNotes(
          detail: row.detailController.text,
          sundaySurcharge100Enabled: sundaySurcharge100Enabled,
        ) ??
        '';
  }

  Future<void> _toggleSundaySurcharge(_EditableAttendanceRow row) async {
    if (row.isSaving || !_canApplySundaySurcharge(row)) {
      return;
    }
    final hasAnyMarking =
        row.checkInController.text.trim().isNotEmpty ||
        row.checkOutController.text.trim().isNotEmpty;
    if (!hasAnyMarking) {
      _showInfo(
        'Registre entrada y/o salida antes de aplicar recargo domingo 100%.',
      );
      return;
    }

    final enableSurcharge = !row.sundaySurcharge100Enabled;
    final actionLabel = enableSurcharge ? 'aplicado' : 'quitado';
    await _saveRow(
      row,
      sundaySurcharge100Override: enableSurcharge,
      successMessage:
          'Recargo domingo 100% $actionLabel para ${employeeDisplayName(row.employee)}.',
    );
  }

  int? _parseBreakMinutes(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return _defaultBreakMinutes;
    }

    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed < 0) {
      return null;
    }

    return parsed;
  }

  Future<void> _autoCompletePendingRowsWithoutClockMarking() async {
    if (_isLoading ||
        _isImporting ||
        _isApplyingSpecialAbsence ||
        _isAutoCompletingWithoutClock) {
      return;
    }
    if (_isEditionBlockedByLockedPeriod()) {
      return;
    }

    final targetRows = _visibleRows()
        .where((row) => _isRowWithoutRecord(row) || _isRowPending(row))
        .toList();
    if (targetRows.isEmpty) {
      _showInfo('No hay pendientes o sin registro para autocompletar.');
      return;
    }

    setState(() {
      _isAutoCompletingWithoutClock = true;
    });

    var completedCount = 0;
    var blockedCount = 0;
    var withoutScheduleCount = 0;
    var failedCount = 0;

    try {
      for (final row in targetRows) {
        if (_isRowLockedBySpecialAbsence(row)) {
          blockedCount += 1;
          continue;
        }

        final schedule = _buildAutoScheduleForRow(row);
        if (schedule == null) {
          withoutScheduleCount += 1;
          continue;
        }

        final currentCheckIn = row.checkInController.text.trim();
        final currentCheckOut = row.checkOutController.text.trim();
        final currentBreakText = row.breakController.text.trim();
        final parsedBreak = _parseBreakMinutes(currentBreakText);
        if (parsedBreak == null) {
          failedCount += 1;
          continue;
        }

        final effectiveCheckIn = currentCheckIn.isNotEmpty
            ? currentCheckIn
            : schedule.checkInTime;
        final effectiveCheckOut = currentCheckOut.isNotEmpty
            ? currentCheckOut
            : schedule.checkOutTime;
        final effectiveBreakMinutes = currentBreakText.isNotEmpty
            ? parsedBreak
            : schedule.breakMinutes;

        try {
          await widget.service.upsertDailyAttendance(
            companyId: widget.companyId,
            employeeId: row.employee.id,
            date: _selectedDate,
            checkInTime: effectiveCheckIn,
            checkOutTime: effectiveCheckOut,
            breakMinutes: effectiveBreakMinutes,
            eventType: 'presente',
            notes: _buildStoredNotesForRow(row: row, eventType: null),
          );
          completedCount += 1;
        } catch (_) {
          failedCount += 1;
        }
      }

      await _reloadMonthEvents();
      if (!mounted) {
        return;
      }

      final summary = <String>[
        'Completados: $completedCount',
        'Sin horario: $withoutScheduleCount',
        'Bloqueados: $blockedCount',
        'Con error: $failedCount',
      ].join(' | ');
      _showInfo('Autocompletado finalizado. $summary');
    } finally {
      if (mounted) {
        setState(() {
          _isAutoCompletingWithoutClock = false;
        });
      }
    }
  }

  _AutoAttendanceSchedule? _buildAutoScheduleForRow(
    _EditableAttendanceRow row,
  ) {
    final employee = row.employee;
    final isSaturday = _selectedDate.weekday == DateTime.saturday;
    if (!employee.allowOvertime && isSaturday) {
      final saturdayStart = _tryParseMinutes(
        employee.workStartTimeSaturday?.trim() ?? '',
      );
      final saturdayEnd = _tryParseMinutes(
        employee.workEndTimeSaturday?.trim() ?? '',
      );
      if (saturdayStart != null && saturdayEnd != null) {
        final saturdayBreak = _effectiveBreakMinutesForSchedule(
          checkInMinutes: saturdayStart,
          checkOutMinutes: saturdayEnd,
          breakMinutes: _defaultBreakMinutes,
        );
        return _AutoAttendanceSchedule(
          checkInTime: _formatMinutesAsTime(saturdayStart),
          checkOutTime: _formatMinutesAsTime(saturdayEnd),
          breakMinutes: saturdayBreak,
        );
      }
    }

    final scheduledStart = _firstScheduledStartMinute(employee);
    if (scheduledStart == null) {
      return null;
    }
    final scheduledEnd = _defaultCheckOutMinuteForStart(scheduledStart);
    final scheduledBreak = _effectiveBreakMinutesForSchedule(
      checkInMinutes: scheduledStart,
      checkOutMinutes: scheduledEnd,
      breakMinutes: _defaultBreakMinutes,
    );

    return _AutoAttendanceSchedule(
      checkInTime: _formatMinutesAsTime(scheduledStart),
      checkOutTime: _formatMinutesAsTime(scheduledEnd),
      breakMinutes: scheduledBreak,
    );
  }

  int? _firstScheduledStartMinute(Employee employee) {
    for (final value in [
      employee.workStartTime1,
      employee.workStartTime2,
      employee.workStartTime3,
    ]) {
      final parsed = _tryParseMinutes(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  int _defaultCheckOutMinuteForStart(int checkInMinutes) {
    var checkOutMinutes = (checkInMinutes + (8 * 60)) % _minutesPerDay;
    final automaticBreak = _effectiveBreakMinutesForSchedule(
      checkInMinutes: checkInMinutes,
      checkOutMinutes: checkOutMinutes,
      breakMinutes: _defaultBreakMinutes,
    );
    if (automaticBreak > 0) {
      checkOutMinutes = (checkOutMinutes + automaticBreak) % _minutesPerDay;
    }
    return checkOutMinutes;
  }

  String _formatMinutesAsTime(int value) {
    final normalized =
        ((value % _minutesPerDay) + _minutesPerDay) % _minutesPerDay;
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _normalizeSearchText(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u00e1]'), 'a')
        .replaceAll(RegExp(r'[\u00e9]'), 'e')
        .replaceAll(RegExp(r'[\u00ed]'), 'i')
        .replaceAll(RegExp(r'[\u00f3]'), 'o')
        .replaceAll(RegExp(r'[\u00fa\u00fc]'), 'u')
        .replaceAll(RegExp(r'[\u00f1]'), 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  List<_EditableAttendanceRow> _visibleRows() {
    final normalizedQuery = _normalizeSearchText(_searchController.text);
    final rows = _rowsByEmployeeId.values.where((row) {
      final employeeName = _normalizeSearchText(
        employeeDisplayName(row.employee),
      );
      final statusOfDay = _normalizeSearchText(_statusLabel(row));
      if (normalizedQuery.isNotEmpty &&
          !employeeName.contains(normalizedQuery) &&
          !statusOfDay.contains(normalizedQuery)) {
        return false;
      }

      return _matchesFilter(row);
    }).toList();

    rows.sort((a, b) {
      final left = employeeDisplayName(a.employee).toLowerCase();
      final right = employeeDisplayName(b.employee).toLowerCase();
      return left.compareTo(right);
    });

    return rows;
  }

  String _formatSelectedDate() {
    final date = _selectedDate;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatSelectedDateLong() {
    final date = _selectedDate;
    final weekday = _capitalize(_weekDayNames[date.weekday - 1]);
    final month = _monthNames[date.month - 1].toLowerCase();
    final holidaySuffix = _isHoliday(date) ? ' - Feriado' : '';
    return '$weekday, ${date.day} de $month de ${date.year}$holidaySuffix';
  }

  bool _isHoliday(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _holidayDates.contains(normalized);
  }

  String _workedHoursLabel(_EditableAttendanceRow row) {
    if (row.absenceType != _AttendanceAbsenceType.none) {
      return '-';
    }

    final preview = _computeHoursFromText(
      employee: row.employee,
      checkInText: row.checkInController.text,
      checkOutText: row.checkOutController.text,
      breakMinutes: _parseBreakMinutes(row.breakController.text),
      date: _selectedDate,
    );

    if (preview != null) {
      return preview.toStringAsFixed(2);
    }

    final eventHours = row.event?.hoursWorked;
    if (eventHours != null) {
      return eventHours.toStringAsFixed(2);
    }

    return '-';
  }

  String _statusLabel(_EditableAttendanceRow row) {
    final absenceEventType = _eventTypeFromAbsenceType(row.absenceType);
    if (absenceEventType != null) {
      if (row.absenceType == _AttendanceAbsenceType.remunerado &&
          _isRowSpecialAbsence(row)) {
        return _selectedSpecialDayLabel() ?? _eventTypeLabel(absenceEventType);
      }
      return _eventTypeLabel(absenceEventType);
    }

    if (_isRowWithoutRecord(row)) {
      return 'Sin registro';
    }

    final event = row.event;
    if (event == null) {
      return 'Pendiente';
    }

    if (event.eventType != 'presente') {
      return _eventTypeLabel(event.eventType);
    }

    final lateMinutes = event.minutesLate ?? 0;
    if (lateMinutes > 0) {
      final completionLabel = _isRowComplete(row) ? 'Completo' : 'Pendiente';
      return 'Tardanza ($lateMinutes min) - $completionLabel';
    }

    if (_isRowComplete(row)) {
      return 'Completo';
    }

    return 'Pendiente';
  }

  String? _selectedSpecialDayLabel() {
    if (!_isSelectedDateSpecial) {
      return null;
    }
    if (_isSelectedDateSunday && _isSelectedDateHoliday) {
      return 'Domingo y feriado';
    }
    if (_isSelectedDateSunday) {
      return 'Domingo';
    }
    return 'Feriado';
  }

  bool _isRowSpecialAbsence(_EditableAttendanceRow row) {
    final specialLabel = _selectedSpecialDayLabel();
    if (specialLabel == null ||
        row.absenceType != _AttendanceAbsenceType.remunerado) {
      return false;
    }

    final sourceText =
        attendanceUserDetailFromNotes(row.event?.notes) ??
        attendanceUserDetailFromNotes(row.detailController.text) ??
        '';
    if (sourceText.isEmpty) {
      return true;
    }

    return sourceText.toLowerCase() == specialLabel.toLowerCase();
  }

  bool _isRowAutoSpecialAbsence(_EditableAttendanceRow row) {
    final specialLabel = _selectedSpecialDayLabel();
    if (specialLabel == null || !_isSelectedDateSpecial) {
      return false;
    }

    final event = row.event;
    if (event == null || event.eventType != 'permiso_remunerado') {
      return false;
    }

    return (attendanceUserDetailFromNotes(event.notes) ?? '')
            .trim()
            .toLowerCase() ==
        specialLabel.toLowerCase();
  }

  bool _isRowLockedBySpecialAbsence(_EditableAttendanceRow row) {
    return !row.employee.allowOvertime && _isRowAutoSpecialAbsence(row);
  }

  bool _hasAppliedSpecialAbsenceForTargets() {
    return _rowsByEmployeeId.values.any(
      (row) => !row.employee.allowOvertime && _isRowLockedBySpecialAbsence(row),
    );
  }

  Future<void> _applySpecialDayAbsence() async {
    if (!_isSelectedDateSpecial ||
        _isLoading ||
        _isImporting ||
        _isApplyingSpecialAbsence) {
      return;
    }
    if (_isEditionBlockedByLockedPeriod()) {
      return;
    }

    final specialLabel = _selectedSpecialDayLabel();
    if (specialLabel == null) {
      return;
    }

    setState(() {
      _isApplyingSpecialAbsence = true;
    });

    try {
      final targetRows = _rowsByEmployeeId.values
          .where((row) => !row.employee.allowOvertime)
          .toList();
      final overtimeRows = _rowsByEmployeeId.values
          .where((row) => row.employee.allowOvertime)
          .toList();
      final overtimeAutoRows = overtimeRows
          .where((row) => _isRowAutoSpecialAbsence(row))
          .toList();
      if (targetRows.isEmpty) {
        for (final row in overtimeAutoRows) {
          await widget.service.upsertDailyAttendance(
            companyId: widget.companyId,
            employeeId: row.employee.id,
            date: _selectedDate,
            checkInTime: row.event?.checkInTime,
            checkOutTime: row.event?.checkOutTime,
            breakMinutes: row.event?.breakMinutes,
            eventType: 'presente',
            notes: null,
          );
        }
        await _reloadMonthEvents();
        if (!mounted) {
          return;
        }
        _showInfo(
          overtimeAutoRows.isNotEmpty
              ? 'Se limpio ausencia automatica en empleados con hora extra.'
              : 'No hay empleados sin hora extra para aplicar ausencia automatica.',
        );
        return;
      }

      final appliedRows = targetRows
          .where((row) => _isRowAutoSpecialAbsence(row))
          .toList();
      final shouldDeactivate = appliedRows.isNotEmpty;

      if (shouldDeactivate) {
        for (final row in appliedRows) {
          await widget.service.upsertDailyAttendance(
            companyId: widget.companyId,
            employeeId: row.employee.id,
            date: _selectedDate,
            checkInTime: null,
            checkOutTime: null,
            breakMinutes: null,
            eventType: 'presente',
            notes: null,
          );
        }
      } else {
        for (final row in targetRows) {
          await widget.service.upsertDailyAttendance(
            companyId: widget.companyId,
            employeeId: row.employee.id,
            date: _selectedDate,
            checkInTime: null,
            checkOutTime: null,
            breakMinutes: null,
            eventType: 'permiso_remunerado',
            notes: specialLabel,
          );
        }
      }

      // Safety cleanup: if older versions auto-applied special absence to
      // overtime-enabled employees, clear it so they can mark/import normally.
      for (final row in overtimeAutoRows) {
        await widget.service.upsertDailyAttendance(
          companyId: widget.companyId,
          employeeId: row.employee.id,
          date: _selectedDate,
          checkInTime: row.event?.checkInTime,
          checkOutTime: row.event?.checkOutTime,
          breakMinutes: row.event?.breakMinutes,
          eventType: 'presente',
          notes: null,
        );
      }

      await _reloadMonthEvents();
      if (!mounted) {
        return;
      }
      if (shouldDeactivate) {
        _showInfo(
          'Ausencia automatica ($specialLabel) desactivada para ${appliedRows.length} empleados.',
        );
      } else {
        _showInfo(
          'Ausencia remunerada ($specialLabel) aplicada para ${targetRows.length} empleados sin hora extra.',
        );
      }
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'Datos invalidos.');
    } catch (error) {
      _showError('No se pudo completar ausencias: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingSpecialAbsence = false;
        });
      }
    }
  }

  _AttendanceAbsenceType _absenceTypeFromEventType(String? eventType) {
    switch (eventType) {
      case 'permiso_remunerado':
        return _AttendanceAbsenceType.remunerado;
      case 'permiso_no_remunerado':
        return _AttendanceAbsenceType.noRemunerado;
      default:
        return _AttendanceAbsenceType.none;
    }
  }

  String? _eventTypeFromAbsenceType(_AttendanceAbsenceType absenceType) {
    switch (absenceType) {
      case _AttendanceAbsenceType.none:
        return null;
      case _AttendanceAbsenceType.remunerado:
        return 'permiso_remunerado';
      case _AttendanceAbsenceType.noRemunerado:
        return 'permiso_no_remunerado';
    }
  }

  bool _matchesFilter(_EditableAttendanceRow row) {
    return _matchesOvertimeFilter(row) && _matchesStatusFilter(row);
  }

  bool _matchesOvertimeFilter(_EditableAttendanceRow row) {
    switch (_selectedOvertimeFilter) {
      case _AttendanceOvertimeFilter.todos:
        return true;
      case _AttendanceOvertimeFilter.sinHoraExtra:
        return !row.employee.allowOvertime;
      case _AttendanceOvertimeFilter.conHoraExtra:
        return row.employee.allowOvertime;
      case _AttendanceOvertimeFilter.sinMarcacion:
        return !row.employee.biometricClockEnabled;
    }
  }

  bool _matchesStatusFilter(_EditableAttendanceRow row) {
    switch (_selectedStatusFilter) {
      case _AttendanceStatusFilter.todos:
        return true;
      case _AttendanceStatusFilter.pendientes:
        return _isRowPending(row);
      case _AttendanceStatusFilter.completados:
        return _isRowComplete(row);
    }
  }

  bool _isRowComplete(_EditableAttendanceRow row) {
    if (row.absenceType != _AttendanceAbsenceType.none) {
      return true;
    }

    final event = row.event;
    if (event == null) {
      return false;
    }

    if (event.eventType != 'presente') {
      return true;
    }

    return _isPresentAttendanceComplete(event, row.employee);
  }

  bool _isRowWithoutRecord(_EditableAttendanceRow row) {
    return row.event == null;
  }

  bool _isRowPending(_EditableAttendanceRow row) {
    if (row.absenceType != _AttendanceAbsenceType.none) {
      return false;
    }

    final event = row.event;
    if (event == null) {
      return true;
    }

    if (event.eventType != 'presente') {
      return false;
    }

    return !_isPresentAttendanceComplete(event, row.employee);
  }

  bool _hasStoredCheckIn(_EditableAttendanceRow row) {
    final event = row.event;
    if (event == null || event.eventType != 'presente') {
      return false;
    }
    final checkIn = event.checkInTime?.trim();
    return checkIn != null && checkIn.isNotEmpty;
  }

  bool _hasStoredCheckOut(_EditableAttendanceRow row) {
    final event = row.event;
    if (event == null || event.eventType != 'presente') {
      return false;
    }
    final checkOut = event.checkOutTime?.trim();
    return checkOut != null && checkOut.isNotEmpty;
  }

  bool _isPresentAttendanceComplete(AttendanceEvent event, Employee employee) {
    final storedHours =
        event.hoursWorked ??
        _computeHoursFromText(
          employee: employee,
          checkInText: event.checkInTime ?? '',
          checkOutText: event.checkOutTime ?? '',
          breakMinutes: event.breakMinutes ?? _defaultBreakMinutes,
          date: event.date,
        );

    return storedHours != null && storedHours > 0;
  }

  double? _computeHoursFromText({
    required Employee employee,
    required String checkInText,
    required String checkOutText,
    required int? breakMinutes,
    required DateTime date,
  }) {
    final checkInMinutes = _tryParseMinutes(checkInText);
    final checkOutMinutes = _tryParseMinutes(checkOutText);

    if (checkInMinutes == null || checkOutMinutes == null) {
      return null;
    }

    var effectiveCheckInMinutes = checkInMinutes;
    final scheduledStart = _pickScheduledStartMinute(
      checkInMinutes: checkInMinutes,
      date: date,
      employee: employee,
    );
    if (scheduledStart != null && checkInMinutes < scheduledStart) {
      effectiveCheckInMinutes = scheduledStart;
    }

    var workedMinutes = checkOutMinutes - effectiveCheckInMinutes;
    if (workedMinutes < 0) {
      workedMinutes += _minutesPerDay;
    }
    if (workedMinutes == 0) {
      return null;
    }

    final effectiveBreakMinutes = _effectiveBreakMinutesForSchedule(
      checkInMinutes: checkInMinutes,
      checkOutMinutes: checkOutMinutes,
      breakMinutes: breakMinutes ?? _defaultBreakMinutes,
    );
    final netMinutes = workedMinutes - effectiveBreakMinutes;
    if (netMinutes <= 0) {
      return null;
    }

    return netMinutes / 60;
  }

  int _effectiveBreakMinutesForSchedule({
    required int checkInMinutes,
    required int checkOutMinutes,
    required int breakMinutes,
  }) {
    final isOvernight = checkOutMinutes <= checkInMinutes;
    if (isOvernight) {
      final normalizedCheckOut = checkOutMinutes + _minutesPerDay;
      return _intervalCrossesMarker(
            start: checkInMinutes,
            end: normalizedCheckOut,
            marker: _overnightBreakMarkerMinutes,
          )
          ? _defaultBreakMinutes
          : 0;
    }

    final normalizedBreak = breakMinutes < 0 ? 0 : breakMinutes;
    if (checkOutMinutes >= _manualBreakWindowStartMinutes &&
        checkOutMinutes <= _manualBreakWindowEndMinutes) {
      return normalizedBreak;
    }

    return _intervalCrossesMarker(
          start: checkInMinutes,
          end: checkOutMinutes,
          marker: _dayBreakMarkerMinutes,
        )
        ? _defaultBreakMinutes
        : 0;
  }

  bool _intervalCrossesMarker({
    required int start,
    required int end,
    required int marker,
  }) {
    return start < marker && end > marker;
  }

  int? _pickScheduledStartMinute({
    required int checkInMinutes,
    required DateTime date,
    required Employee employee,
  }) {
    if (!employee.allowOvertime && date.weekday == DateTime.saturday) {
      final saturday = employee.workStartTimeSaturday?.trim() ?? '';
      final saturdayStart = _tryParseMinutes(saturday);
      if (saturdayStart != null) {
        return saturdayStart;
      }
    }

    final starts = <int>[];
    for (final value in [
      employee.workStartTime1,
      employee.workStartTime2,
      employee.workStartTime3,
    ]) {
      final parsed = _tryParseMinutes(value);
      if (parsed != null && !starts.contains(parsed)) {
        starts.add(parsed);
      }
    }

    if (starts.isEmpty) {
      return null;
    }

    var selected = starts.first;
    var selectedDistance = (selected - checkInMinutes).abs();
    for (final candidate in starts.skip(1)) {
      final distance = (candidate - checkInMinutes).abs();
      if (distance < selectedDistance) {
        selected = candidate;
        selectedDistance = distance;
      }
    }
    return selected;
  }

  int? _tryParseMinutes(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final parsed = _parseTimeParts(trimmed);
    if (parsed == null) {
      return null;
    }

    final hour = parsed.$1;
    final minute = parsed.$2;

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return (hour * 60) + minute;
  }

  (int, int)? _parseTimeParts(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length == 1 || digitsOnly.length == 2) {
      return (int.parse(digitsOnly), 0);
    }

    if (digitsOnly.length == 4) {
      return (
        int.parse(digitsOnly.substring(0, 2)),
        int.parse(digitsOnly.substring(2, 4)),
      );
    }

    if (digitsOnly.length == 3) {
      return (
        int.parse(digitsOnly.substring(0, 1)),
        int.parse(digitsOnly.substring(1, 3)),
      );
    }

    final match = _timeRegExp.firstMatch(value);
    if (match == null) {
      return null;
    }

    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
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
      xl.DateCellValue() => DateFormat('d/M/y').format(value.asDateTimeLocal()),
      xl.TimeCellValue() =>
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      xl.DateTimeCellValue() => DateFormat(
        'd/M/y HH:mm',
      ).format(value.asDateTimeLocal()),
      xl.FormulaCellValue() => value.formula.trim(),
    };
  }

  DateTime? _cellDateTime(xl.Data? cell) {
    final value = cell?.value;
    if (value == null) {
      return null;
    }

    return switch (value) {
      xl.DateTimeCellValue() => value.asDateTimeLocal(),
      xl.DateCellValue() => value.asDateTimeLocal(),
      xl.TextCellValue() => _tryParseDateTimeString(value.value.text ?? ''),
      _ => _tryParseDateTimeString(value.toString()),
    };
  }

  DateTime? _cellDateOnly(xl.Data? cell) {
    final value = cell?.value;
    if (value == null) {
      return null;
    }

    final parsed = switch (value) {
      xl.DateCellValue() => value.asDateTimeLocal(),
      xl.DateTimeCellValue() => value.asDateTimeLocal(),
      xl.TextCellValue() => _tryParseDateTimeString(value.value.text ?? ''),
      xl.TimeCellValue() => null,
      _ => _tryParseDateTimeString(value.toString()),
    };

    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  int? _cellTimeMinutes(xl.Data? cell) {
    final value = cell?.value;
    if (value == null) {
      return null;
    }

    return switch (value) {
      xl.TimeCellValue() => (value.hour * 60) + value.minute,
      xl.DateTimeCellValue() =>
        (value.asDateTimeLocal().hour * 60) + value.asDateTimeLocal().minute,
      xl.TextCellValue() => _tryParseMinutes(value.value.text ?? ''),
      _ => _tryParseMinutes(_cellText(cell)),
    };
  }

  DateTime? _tryParseDateTimeString(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final isoDate = DateTime.tryParse(normalized);
    if (isoDate != null) {
      return isoDate;
    }

    const patterns = [
      'd/M/y',
      'dd/MM/y',
      'M/d/y',
      'MM/dd/y',
      'd/M/y H:mm',
      'd/M/y HH:mm',
      'd/M/y H:mm:ss',
      'd/M/y HH:mm:ss',
      'dd/MM/y HH:mm',
      'dd/MM/y HH:mm:ss',
      'M/d/y H:mm',
      'M/d/y HH:mm',
      'M/d/y H:mm:ss',
      'M/d/y HH:mm:ss',
    ];

    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parseStrict(normalized);
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  _ClockMarkType? _markType(String state) {
    final normalized = state.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z]'),
      '',
    );
    if (normalized.contains('ent')) {
      return _ClockMarkType.entry;
    }
    if (normalized.contains('sal')) {
      return _ClockMarkType.exit;
    }
    return null;
  }

  String _normalizeDocumentNumber(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _normalizeHeader(String raw) {
    final lower = raw.trim().toLowerCase();
    final withoutAccents = lower
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
    return withoutAccents.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

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

  @override
  Widget build(BuildContext context) {
    final years = List<int>.generate(
      8,
      (index) => DateTime.now().year - 3 + index,
    );
    final rows = _visibleRows();
    final selectorBorderColor = _isSelectedDateSpecial
        ? Colors.red.shade400
        : Colors.grey.shade400;
    final selectorAccentColor = _isSelectedDateSpecial
        ? Colors.red.shade700
        : null;
    final selectorBackgroundColor = _isSelectedDateSpecial
        ? Colors.red.shade50
        : null;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isCompactTable = viewportWidth <= 1500;
    final isVeryCompactTable = viewportWidth <= 1320;
    final headerFontSize = isVeryCompactTable
        ? 12.0
        : (isCompactTable ? 13.0 : 14.0);
    final rowFontSize = isVeryCompactTable
        ? 12.0
        : (isCompactTable ? 13.0 : 14.0);
    final inputFontSize = isVeryCompactTable
        ? 12.0
        : (isCompactTable ? 13.0 : 14.0);
    final inputPadding = EdgeInsets.symmetric(
      horizontal: isVeryCompactTable ? 8 : 10,
      vertical: isVeryCompactTable ? 8 : 10,
    );
    final employeeColWidth = isVeryCompactTable
        ? 162.0
        : (isCompactTable ? 178.0 : 196.0);
    final timeColWidth = isVeryCompactTable
        ? 76.0
        : (isCompactTable ? 80.0 : 82.0);
    final breakColWidth = isVeryCompactTable
        ? 78.0
        : (isCompactTable ? 82.0 : 86.0);
    final absenceColWidth = isVeryCompactTable
        ? 136.0
        : (isCompactTable ? 148.0 : 160.0);
    final detailColWidth = isVeryCompactTable
        ? 140.0
        : (isCompactTable ? 156.0 : 176.0);
    final hoursColWidth = isVeryCompactTable ? 48.0 : 56.0;
    final statusColWidth = _isSelectedDateSunday
        ? (isVeryCompactTable ? 76.0 : 84.0)
        : (isVeryCompactTable ? 84.0 : 92.0);
    final buttonColWidth = _isSelectedDateSunday
        ? (isVeryCompactTable ? 176.0 : 192.0)
        : (isVeryCompactTable ? 88.0 : 94.0);
    final tableColumnSpacing = isVeryCompactTable
        ? 8.0
        : (isCompactTable ? 10.0 : 14.0);
    final tableHorizontalMargin = isVeryCompactTable ? 8.0 : 10.0;
    final headingRowHeight = isVeryCompactTable ? 40.0 : 44.0;
    final dataRowMinHeight = isVeryCompactTable ? 48.0 : 52.0;
    final dataRowMaxHeight = isVeryCompactTable ? 52.0 : 56.0;
    final hasSpecialAbsenceApplied =
        _isSelectedDateSpecial && _hasAppliedSpecialAbsenceForTargets();
    final isEditionLocked = _isSelectedPeriodLocked;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatSelectedDateLong(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<int>(
                value: _selectedMonth,
                items: List<DropdownMenuItem<int>>.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(_monthNames[index]),
                  ),
                ),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  _changeMonth(value);
                },
              ),
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
                  _changeYear(value);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: selectorBackgroundColor,
                  border: Border.all(color: selectorBorderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _selectedDay > 1 ? () => _moveDay(-1) : null,
                      icon: Icon(
                        Icons.chevron_left,
                        color: selectorAccentColor,
                      ),
                      tooltip: 'Dia anterior',
                    ),
                    Text(
                      '${_formatSelectedDate()} (${_selectedDay.toString().padLeft(2, '0')}/$_daysInSelectedMonth)',
                      style: TextStyle(color: selectorAccentColor),
                    ),
                    IconButton(
                      onPressed: _selectedDay < _daysInSelectedMonth
                          ? () => _moveDay(1)
                          : null,
                      icon: Icon(
                        Icons.chevron_right,
                        color: selectorAccentColor,
                      ),
                      tooltip: 'Dia siguiente',
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _openCalendarOverview,
                icon: const Icon(Icons.calendar_month),
                label: const Text('Calendario'),
              ),
              OutlinedButton.icon(
                onPressed: _isLoading
                    ? null
                    : _openEmployeeMonthlySummaryDialog,
                icon: const Icon(Icons.badge),
                label: const Text('Resumen por empleado'),
              ),
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar empleado',
                    hintText: 'Nombre, apellido o estado',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.trim().isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar busqueda',
                            onPressed: _searchController.clear,
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ),
              DropdownButton<_AttendanceOvertimeFilter>(
                value: _selectedOvertimeFilter,
                items: _attendanceOvertimeFilterLabels.entries
                    .map(
                      (entry) => DropdownMenuItem<_AttendanceOvertimeFilter>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedOvertimeFilter = value;
                  });
                },
              ),
              DropdownButton<_AttendanceStatusFilter>(
                value: _selectedStatusFilter,
                items: _attendanceStatusFilterLabels.entries
                    .map(
                      (entry) => DropdownMenuItem<_AttendanceStatusFilter>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedStatusFilter = value;
                  });
                },
              ),
              if (widget.canImportClock)
                DropdownButton<_AttendanceImportScope>(
                  value: _selectedImportScope,
                  items: _attendanceImportScopeLabels.entries
                      .map(
                        (entry) => DropdownMenuItem<_AttendanceImportScope>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: _isImporting || _isLoading || isEditionLocked
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedImportScope = value;
                          });
                        },
                ),
              if (widget.canImportClock)
                FilledButton.icon(
                  onPressed: _isImporting || _isLoading || isEditionLocked
                      ? null
                      : _importClockMarks,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _isImporting ? 'Importando...' : 'Importar marcaciones',
                  ),
                ),
              if (_selectedOvertimeFilter ==
                  _AttendanceOvertimeFilter.sinMarcacion)
                FilledButton.icon(
                  onPressed:
                      _isImporting ||
                          _isLoading ||
                          isEditionLocked ||
                          _isApplyingSpecialAbsence ||
                          _isAutoCompletingWithoutClock
                      ? null
                      : _autoCompletePendingRowsWithoutClockMarking,
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(
                    _isAutoCompletingWithoutClock
                        ? 'Autocompletando...'
                        : 'Completar pendientes',
                  ),
                ),
              if (_isSelectedDateSpecial)
                FilledButton.icon(
                  onPressed:
                      _isImporting ||
                          _isLoading ||
                          isEditionLocked ||
                          _isApplyingSpecialAbsence
                      ? null
                      : _applySpecialDayAbsence,
                  icon: Icon(
                    hasSpecialAbsenceApplied
                        ? Icons.event_busy
                        : Icons.event_available,
                  ),
                  label: Text(
                    _isApplyingSpecialAbsence
                        ? 'Procesando...'
                        : hasSpecialAbsenceApplied
                        ? 'Quitar ausencia (${_selectedSpecialDayLabel()})'
                        : 'Completar ausencia (${_selectedSpecialDayLabel()})',
                  ),
                ),
            ],
          ),
          if (isEditionLocked)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Asistencia en modo solo lectura: la liquidacion de ${_selectedPeriodLabel()} esta guardada y bloqueada.',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _activeEmployees.isEmpty
                ? const Center(
                    child: Text('No hay empleados activos para registrar.'),
                  )
                : rows.isEmpty
                ? const Center(
                    child: Text('No hay coincidencias con el filtro aplicado.'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: tableColumnSpacing,
                        horizontalMargin: tableHorizontalMargin,
                        headingRowHeight: headingRowHeight,
                        dataRowMinHeight: dataRowMinHeight,
                        dataRowMaxHeight: dataRowMaxHeight,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Empleado',
                              style: TextStyle(fontSize: headerFontSize),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Entrada (HH:mm)',
                              style: TextStyle(fontSize: headerFontSize),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Salida (HH:mm)',
                              style: TextStyle(fontSize: headerFontSize),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Descanso (min)',
                              style: TextStyle(fontSize: headerFontSize),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Ausencia',
                              style: TextStyle(fontSize: headerFontSize),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Detalle',
                              style: TextStyle(fontSize: headerFontSize),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Horas',
                              style: TextStyle(fontSize: headerFontSize),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Estado del dia',
                              style: TextStyle(fontSize: headerFontSize),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Accion',
                              style: TextStyle(fontSize: headerFontSize),
                            ),
                          ),
                        ],
                        rows: rows.map((row) {
                          final hasStoredCheckIn = _hasStoredCheckIn(row);
                          final hasStoredCheckOut = _hasStoredCheckOut(row);
                          final isSpecialLocked =
                              _isApplyingSpecialAbsence ||
                              _isRowLockedBySpecialAbsence(row);
                          final canEditRow =
                              !row.isSaving &&
                              !isSpecialLocked &&
                              !isEditionLocked;
                          final showSundaySurchargeButton =
                              _isSelectedDateSunday &&
                              row.employee.allowOvertime;
                          final canToggleSundaySurcharge =
                              showSundaySurchargeButton &&
                              canEditRow &&
                              row.absenceType == _AttendanceAbsenceType.none;
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: employeeColWidth,
                                  child: Text(
                                    employeeDisplayName(row.employee),
                                    style: TextStyle(fontSize: rowFontSize),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: timeColWidth,
                                  child: TextField(
                                    controller: row.checkInController,
                                    enabled:
                                        canEditRow &&
                                        row.absenceType ==
                                            _AttendanceAbsenceType.none,
                                    onChanged: (_) => setState(() {}),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9:.,]'),
                                      ),
                                    ],
                                    style: TextStyle(
                                      fontSize: inputFontSize,
                                      fontWeight: hasStoredCheckIn
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '08:00 / 08.00 / 8',
                                      hintStyle: TextStyle(
                                        fontSize: inputFontSize,
                                      ),
                                      contentPadding: inputPadding,
                                      filled: hasStoredCheckIn,
                                      fillColor: Colors.grey.shade300,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: timeColWidth,
                                  child: TextField(
                                    controller: row.checkOutController,
                                    enabled:
                                        canEditRow &&
                                        row.absenceType ==
                                            _AttendanceAbsenceType.none,
                                    onChanged: (_) => setState(() {}),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9:.,]'),
                                      ),
                                    ],
                                    style: TextStyle(
                                      fontSize: inputFontSize,
                                      fontWeight: hasStoredCheckOut
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '17:00 / 17.00 / 6',
                                      hintStyle: TextStyle(
                                        fontSize: inputFontSize,
                                      ),
                                      contentPadding: inputPadding,
                                      filled: hasStoredCheckOut,
                                      fillColor: Colors.grey.shade300,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: breakColWidth,
                                  child: TextField(
                                    controller: row.breakController,
                                    enabled:
                                        canEditRow &&
                                        row.absenceType ==
                                            _AttendanceAbsenceType.none,
                                    onChanged: (_) => setState(() {}),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: TextStyle(fontSize: inputFontSize),
                                    decoration: InputDecoration(
                                      hintText: '60',
                                      hintStyle: TextStyle(
                                        fontSize: inputFontSize,
                                      ),
                                      contentPadding: inputPadding,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: absenceColWidth,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: inputPadding,
                                      border: OutlineInputBorder(),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child:
                                          DropdownButton<
                                            _AttendanceAbsenceType
                                          >(
                                            value: row.absenceType,
                                            isExpanded: true,
                                            style: TextStyle(
                                              fontSize: inputFontSize,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                            items: _attendanceAbsenceTypeLabels
                                                .entries
                                                .map(
                                                  (entry) =>
                                                      DropdownMenuItem<
                                                        _AttendanceAbsenceType
                                                      >(
                                                        value: entry.key,
                                                        child: Text(
                                                          entry.value,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize:
                                                                inputFontSize,
                                                          ),
                                                        ),
                                                      ),
                                                )
                                                .toList(),
                                            onChanged: !canEditRow
                                                ? null
                                                : (value) {
                                                    if (value == null) {
                                                      return;
                                                    }
                                                    setState(() {
                                                      row.absenceType = value;
                                                      if (value !=
                                                          _AttendanceAbsenceType
                                                              .none) {
                                                        row.checkInController
                                                            .clear();
                                                        row.checkOutController
                                                            .clear();
                                                      }
                                                    });
                                                  },
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: detailColWidth,
                                  child: TextField(
                                    controller: row.detailController,
                                    enabled: canEditRow,
                                    style: TextStyle(fontSize: inputFontSize),
                                    decoration: InputDecoration(
                                      hintText: 'Detalle',
                                      hintStyle: TextStyle(
                                        fontSize: inputFontSize,
                                      ),
                                      contentPadding: inputPadding,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: hoursColWidth,
                                  child: Text(
                                    _workedHoursLabel(row),
                                    style: TextStyle(fontSize: rowFontSize),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: statusColWidth,
                                  child: Text(
                                    _statusLabel(row),
                                    style: TextStyle(fontSize: rowFontSize),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: buttonColWidth,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isVeryCompactTable
                                                  ? 6
                                                  : 8,
                                              vertical: isVeryCompactTable
                                                  ? 6
                                                  : 8,
                                            ),
                                            textStyle: TextStyle(
                                              fontSize: inputFontSize,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          onPressed: !canEditRow
                                              ? null
                                              : () => _saveRow(row),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              row.isSaving
                                                  ? 'Guardando...'
                                                  : 'Guardar',
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (showSundaySurchargeButton) ...[
                                        const SizedBox(width: 6),
                                        SizedBox(
                                          width: isVeryCompactTable ? 66 : 74,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isVeryCompactTable
                                                    ? 6
                                                    : 8,
                                                vertical: isVeryCompactTable
                                                    ? 6
                                                    : 8,
                                              ),
                                              textStyle: TextStyle(
                                                fontSize: inputFontSize,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            onPressed: canToggleSundaySurcharge
                                                ? () => _toggleSundaySurcharge(
                                                    row,
                                                  )
                                                : null,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                row.sundaySurcharge100Enabled
                                                    ? 'Quitar 100%'
                                                    : '100% Aplicar',
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EditableAttendanceRow {
  _EditableAttendanceRow({
    required this.employee,
    required this.event,
    required this.checkInController,
    required this.checkOutController,
    required this.breakController,
    required this.absenceType,
    required this.detailController,
    required this.sundaySurcharge100Enabled,
  });

  final Employee employee;
  final AttendanceEvent? event;
  final TextEditingController checkInController;
  final TextEditingController checkOutController;
  final TextEditingController breakController;
  _AttendanceAbsenceType absenceType;
  final TextEditingController detailController;
  bool sundaySurcharge100Enabled;
  bool isSaving = false;

  void dispose() {
    checkInController.dispose();
    checkOutController.dispose();
    breakController.dispose();
    detailController.dispose();
  }
}

class _AutoAttendanceSchedule {
  const _AutoAttendanceSchedule({
    required this.checkInTime,
    required this.checkOutTime,
    required this.breakMinutes,
  });

  final String checkInTime;
  final String checkOutTime;
  final int breakMinutes;
}

enum _AttendanceAbsenceType { none, remunerado, noRemunerado }

enum _ClockMarkType { entry, exit }

class _ImportedClockMark {
  const _ImportedClockMark({
    required this.document,
    required this.dateTime,
    required this.state,
  });

  final String document;
  final DateTime dateTime;
  final String state;
}

class _ImportedShift {
  const _ImportedShift({required this.checkIn, this.checkOut});

  final DateTime checkIn;
  final DateTime? checkOut;
}

class _ImportedAttendanceEntry {
  const _ImportedAttendanceEntry({
    required this.document,
    required this.checkIn,
    required this.checkOut,
  });

  final String document;
  final DateTime checkIn;
  final DateTime? checkOut;
}

enum _ImportPreviewStatus {
  complete,
  pending,
  withoutEmployee,
  withoutClockMarking,
}

class _ImportPreviewRow {
  const _ImportPreviewRow({
    required this.document,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.companyId,
    required this.employeeId,
    required this.employeeName,
  });

  final String document;
  final DateTime checkIn;
  final DateTime? checkOut;
  final _ImportPreviewStatus status;
  final int? companyId;
  final int? employeeId;
  final String? employeeName;
}

class _ImportPreviewDialog extends StatelessWidget {
  const _ImportPreviewDialog({
    required this.rows,
    required this.selectedDate,
    required this.formatTime,
  });

  final List<_ImportPreviewRow> rows;
  final DateTime selectedDate;
  final String Function(DateTime value) formatTime;

  @override
  Widget build(BuildContext context) {
    final importableComplete = rows
        .where((row) => row.status == _ImportPreviewStatus.complete)
        .length;
    final importablePending = rows
        .where((row) => row.status == _ImportPreviewStatus.pending)
        .length;
    final withoutEmployee = rows
        .where((row) => row.status == _ImportPreviewStatus.withoutEmployee)
        .length;
    final withoutClockMarking = rows
        .where((row) => row.status == _ImportPreviewStatus.withoutClockMarking)
        .length;

    return AlertDialog(
      title: const Text('Vista previa de importacion'),
      content: SizedBox(
        width: 1040,
        height: 540,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dia: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
            const SizedBox(height: 8),
            Text(
              'Completas: $importableComplete | Pendientes: $importablePending | Sin empleado: $withoutEmployee | Sin marcacion: $withoutClockMarking',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('AC-No.')),
                      DataColumn(label: Text('Empresa')),
                      DataColumn(label: Text('Empleado')),
                      DataColumn(label: Text('Entrada')),
                      DataColumn(label: Text('Salida')),
                      DataColumn(label: Text('Estado')),
                    ],
                    rows: rows
                        .map(
                          (row) => DataRow(
                            cells: [
                              DataCell(Text(row.document)),
                              DataCell(Text(row.companyId?.toString() ?? '-')),
                              DataCell(Text(row.employeeName ?? '-')),
                              DataCell(Text(formatTime(row.checkIn))),
                              DataCell(
                                Text(
                                  row.checkOut == null
                                      ? '-'
                                      : formatTime(row.checkOut!),
                                ),
                              ),
                              DataCell(
                                Text(_importPreviewStatusLabel(row.status)),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: (importableComplete + importablePending) <= 0
              ? null
              : () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.check),
          label: const Text('Importar'),
        ),
      ],
    );
  }
}

class _AttendanceMonthCalendarDialog extends StatelessWidget {
  const _AttendanceMonthCalendarDialog({
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.daysInMonth,
    required this.completedDays,
  });

  final int year;
  final int month;
  final int selectedDay;
  final int daysInMonth;
  final Set<int> completedDays;

  static const List<String> _weekDays = [
    'Lun',
    'Mar',
    'Mie',
    'Jue',
    'Vie',
    'Sab',
    'Dom',
  ];
  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final firstWeekdayOffset = DateTime(year, month, 1).weekday - 1;
    final slots = List<int?>.filled(firstWeekdayOffset, null, growable: true)
      ..addAll(List<int>.generate(daysInMonth, (index) => index + 1));

    while (slots.length % 7 != 0) {
      slots.add(null);
    }

    return AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calendario de asistencia'),
          const SizedBox(height: 2),
          Text(
            '${_monthNames[month - 1]} $year',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rojo: dia totalmente completado.'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final weekDay in _weekDays)
                  Center(
                    child: Text(
                      weekDay,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                for (final day in slots)
                  if (day == null)
                    const SizedBox.shrink()
                  else
                    _CalendarDayTile(
                      day: day,
                      isSelected: day == selectedDay,
                      isCompleted: completedDays.contains(day),
                      onTap: () => Navigator.of(context).pop(day),
                    ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _CalendarDayTile extends StatelessWidget {
  const _CalendarDayTile({
    required this.day,
    required this.isSelected,
    required this.isCompleted,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedTextStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.primary,
    );

    if (isCompleted) {
      return InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Center(
        child: Text('$day', style: isSelected ? selectedTextStyle : null),
      ),
    );
  }
}

class _EmployeeMonthSummaryRow {
  const _EmployeeMonthSummaryRow({
    required this.day,
    required this.dateLabel,
    required this.weekDayLabel,
    required this.checkIn,
    required this.checkOut,
    required this.breakMinutes,
    required this.absenceLabel,
    required this.detail,
    required this.hoursLabel,
    required this.statusLabel,
    required this.isPending,
  });

  final int day;
  final String dateLabel;
  final String weekDayLabel;
  final String checkIn;
  final String checkOut;
  final String breakMinutes;
  final String absenceLabel;
  final String detail;
  final String hoursLabel;
  final String statusLabel;
  final bool isPending;
}

typedef _BuildRowsForEmployee =
    List<_EmployeeMonthSummaryRow> Function(Employee employee);
typedef _EmployeeSummaryAction =
    Future<void> Function(
      Employee employee,
      List<_EmployeeMonthSummaryRow> rows,
    );

class _EmployeeMonthlySummaryDialog extends StatefulWidget {
  const _EmployeeMonthlySummaryDialog({
    required this.employees,
    required this.companyName,
    required this.year,
    required this.month,
    required this.buildRowsForEmployee,
    required this.onShare,
    required this.onPrint,
  });

  final List<Employee> employees;
  final String companyName;
  final int year;
  final int month;
  final _BuildRowsForEmployee buildRowsForEmployee;
  final _EmployeeSummaryAction onShare;
  final _EmployeeSummaryAction onPrint;

  @override
  State<_EmployeeMonthlySummaryDialog> createState() =>
      _EmployeeMonthlySummaryDialogState();
}

class _EmployeeMonthlySummaryDialogState
    extends State<_EmployeeMonthlySummaryDialog> {
  final TextEditingController _searchController = TextEditingController();

  int? _selectedEmployeeId;
  bool _isSharing = false;
  bool _isPrinting = false;

  List<Employee> get _filteredEmployees {
    final query = _searchController.text.trim().toLowerCase();
    final employees = [...widget.employees]
      ..sort((a, b) {
        final left = employeeDisplayName(a).toLowerCase();
        final right = employeeDisplayName(b).toLowerCase();
        return left.compareTo(right);
      });
    if (query.isEmpty) {
      return employees;
    }

    return employees.where((employee) {
      final name = employeeDisplayName(employee).toLowerCase();
      final document = employee.documentNumber.toLowerCase();
      return name.contains(query) || document.contains(query);
    }).toList();
  }

  Employee? get _selectedEmployee {
    final id = _selectedEmployeeId;
    if (id == null) {
      return null;
    }
    for (final employee in widget.employees) {
      if (employee.id == id) {
        return employee;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedEmployeeId = widget.employees.firstOrNull?.id;
    _searchController.addListener(_syncSelectionWithSearch);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_syncSelectionWithSearch)
      ..dispose();
    super.dispose();
  }

  void _syncSelectionWithSearch() {
    final filtered = _filteredEmployees;
    final selectedId = _selectedEmployeeId;

    if (filtered.isEmpty) {
      if (selectedId != null) {
        setState(() {
          _selectedEmployeeId = null;
        });
      } else {
        setState(() {});
      }
      return;
    }

    if (selectedId == null ||
        !filtered.any((employee) => employee.id == selectedId)) {
      setState(() {
        _selectedEmployeeId = filtered.first.id;
      });
      return;
    }

    setState(() {});
  }

  Future<void> _runAction(_EmployeeSummaryAction action, bool isShare) async {
    final employee = _selectedEmployee;
    if (employee == null) {
      return;
    }
    final rows = widget.buildRowsForEmployee(employee);

    setState(() {
      if (isShare) {
        _isSharing = true;
      } else {
        _isPrinting = true;
      }
    });

    try {
      await action(employee, rows);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isShare
                  ? 'No se pudo compartir resumen: $error'
                  : 'No se pudo imprimir resumen: $error',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          if (isShare) {
            _isSharing = false;
          } else {
            _isPrinting = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = _filteredEmployees;
    final selectedEmployee = _selectedEmployee;
    final rows = selectedEmployee == null
        ? const <_EmployeeMonthSummaryRow>[]
        : widget.buildRowsForEmployee(selectedEmployee);

    return AlertDialog(
      title: const Text('Resumen por empleado'),
      content: SizedBox(
        width: 1180,
        height: 620,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar empleado',
                      hintText: 'Nombre o documento',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 360,
                  child: DropdownButtonFormField<int>(
                    key: ValueKey(
                      'employee-summary-${selectedEmployee?.id ?? 0}-${filteredEmployees.length}',
                    ),
                    initialValue: selectedEmployee?.id,
                    decoration: const InputDecoration(labelText: 'Empleado'),
                    items: filteredEmployees
                        .map(
                          (employee) => DropdownMenuItem<int>(
                            value: employee.id,
                            child: Text(
                              '${employeeDisplayName(employee)} (${employee.documentNumber})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: filteredEmployees.isEmpty
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedEmployeeId = value;
                            });
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (selectedEmployee != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Periodo: ${widget.month.toString().padLeft(2, '0')}/${widget.year} | Empresa: ${widget.companyName} | Empleado: ${employeeDisplayName(selectedEmployee)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredEmployees.isEmpty
                  ? const Center(
                      child: Text('No hay empleados con el filtro actual.'),
                    )
                  : selectedEmployee == null
                  ? const Center(child: Text('Seleccione un empleado.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 16,
                          columns: const [
                            DataColumn(label: Text('Dia')),
                            DataColumn(label: Text('Semana')),
                            DataColumn(label: Text('Entrada')),
                            DataColumn(label: Text('Salida')),
                            DataColumn(label: Text('Desc.')),
                            DataColumn(label: Text('Ausencia')),
                            DataColumn(label: Text('Detalle')),
                            DataColumn(label: Text('Horas')),
                          ],
                          rows: rows
                              .map(
                                (row) => DataRow(
                                  color: row.isPending
                                      ? WidgetStateProperty.all(
                                          Colors.orange.shade50,
                                        )
                                      : null,
                                  cells: [
                                    DataCell(Text('${row.day}')),
                                    DataCell(Text(row.weekDayLabel)),
                                    DataCell(Text(row.checkIn)),
                                    DataCell(Text(row.checkOut)),
                                    DataCell(Text(row.breakMinutes)),
                                    DataCell(Text(row.absenceLabel)),
                                    DataCell(Text(row.detail)),
                                    DataCell(Text(row.hoursLabel)),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        OutlinedButton.icon(
          onPressed: _selectedEmployee == null || _isSharing || _isPrinting
              ? null
              : () => _runAction(widget.onPrint, false),
          icon: const Icon(Icons.print),
          label: Text(_isPrinting ? 'Imprimiendo...' : 'Imprimir'),
        ),
        FilledButton.icon(
          onPressed: _selectedEmployee == null || _isSharing || _isPrinting
              ? null
              : () => _runAction(widget.onShare, true),
          icon: const Icon(Icons.share),
          label: Text(_isSharing ? 'Compartiendo...' : 'Compartir'),
        ),
      ],
    );
  }
}

class _AttendanceEmployeeSummaryPrintPreviewScreen extends StatelessWidget {
  const _AttendanceEmployeeSummaryPrintPreviewScreen({
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

const Map<String, String> _attendanceEventLabels = {
  'presente': 'Presente',
  'ausente': 'Ausente',
  'permiso_remunerado': 'Permiso remunerado',
  'permiso_no_remunerado': 'Permiso no remunerado',
  'vacaciones': 'Vacaciones',
  'paternidad': 'Paternidad',
  'duelo': 'Duelo',
  'reposo': 'Reposo',
  'tardanza': 'Tardanza',
};

String _eventTypeLabel(String eventType) {
  return _attendanceEventLabels[eventType] ?? eventType;
}

String _importPreviewStatusLabel(_ImportPreviewStatus status) {
  switch (status) {
    case _ImportPreviewStatus.complete:
      return 'Completado';
    case _ImportPreviewStatus.pending:
      return 'Pendiente (falta salida)';
    case _ImportPreviewStatus.withoutEmployee:
      return 'Sin empleado asociado';
    case _ImportPreviewStatus.withoutClockMarking:
      return 'Empleado sin marcacion biometrica';
  }
}

enum _AttendanceOvertimeFilter {
  todos,
  sinHoraExtra,
  conHoraExtra,
  sinMarcacion,
}

const Map<_AttendanceOvertimeFilter, String> _attendanceOvertimeFilterLabels = {
  _AttendanceOvertimeFilter.todos: 'Todos',
  _AttendanceOvertimeFilter.sinHoraExtra: 'Sin hora extra',
  _AttendanceOvertimeFilter.conHoraExtra: 'Con hora extra',
  _AttendanceOvertimeFilter.sinMarcacion: 'Sin Marcacion',
};

enum _AttendanceStatusFilter { todos, pendientes, completados }

const Map<_AttendanceStatusFilter, String> _attendanceStatusFilterLabels = {
  _AttendanceStatusFilter.todos: 'Todos',
  _AttendanceStatusFilter.pendientes: 'Pendientes',
  _AttendanceStatusFilter.completados: 'Completados',
};

const Map<_AttendanceAbsenceType, String> _attendanceAbsenceTypeLabels = {
  _AttendanceAbsenceType.none: 'Presente',
  _AttendanceAbsenceType.remunerado: 'Remunerado',
  _AttendanceAbsenceType.noRemunerado: 'No remunerado',
};

enum _AttendanceImportScope { global, activeCompany }

const Map<_AttendanceImportScope, String> _attendanceImportScopeLabels = {
  _AttendanceImportScope.global: 'Global (todas las empresas)',
  _AttendanceImportScope.activeCompany: 'Solo empresa activa',
};

const int _defaultBreakMinutes = 60;
const int _dayBreakMarkerMinutes = 13 * 60;
const int _overnightBreakMarkerMinutes = 25 * 60;
const int _manualBreakWindowStartMinutes = 14 * 60;
const int _manualBreakWindowEndMinutes = (14 * 60) + 30;
const int _minutesPerDay = 24 * 60;
final RegExp _timeRegExp = RegExp(r'^(\d{1,2})[:.,](\d{2})$');
