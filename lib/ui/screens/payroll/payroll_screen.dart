import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../services/payroll_service.dart';
import '../../utils/guarani_currency.dart';
import '../../utils/thousands_separator_input_formatter.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({
    required this.service,
    required this.companyId,
    required this.companyName,
    super.key,
  });

  final PayrollService service;
  final int companyId;
  final String companyName;

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
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

  static const List<String> _reportColumns = [
    'Empleado',
    'Salario base',
    'Dias',
    'Horas extra',
    'Valor horas extra',
    'Recargo noct. ord.',
    'Bruto',
    'Bonif. familiar',
    'IPS empleado',
    'Descuentos',
    'Saldo',
    'Otros desc.',
    'Embargo',
  ];

  List<PayrollItemView> _items = const [];
  final Map<int, TextEditingController> _otherDiscountControllers = {};
  final Set<int> _savingOtherDiscountIds = <int>{};
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  bool _isAutoRegenerating = false;
  bool _isLoading = false;
  bool _isGenerating = false;
  bool _isExportingPdf = false;
  bool _isExportingExcel = false;
  bool _isPrinting = false;
  late int _selectedYear;
  late int _selectedMonth;

  bool get _isOutputBusy => _isExportingPdf || _isExportingExcel || _isPrinting;
  bool get _canGenerate => !_isLoading && !_isGenerating && !_isOutputBusy;
  bool get _canOutput =>
      !_isLoading && !_isGenerating && !_isOutputBusy && _items.isNotEmpty;

  String get _normalizedCompanyName {
    final normalized = widget.companyName.trim();
    return normalized.isEmpty ? 'Empresa' : normalized;
  }

  String get _periodLabel =>
      '${_monthNames[_selectedMonth - 1]} $_selectedYear';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadItems();
  }

  @override
  void didUpdateWidget(covariant PayrollScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _loadItems();
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    for (final controller in _otherDiscountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var items = await widget.service.listPayrollItemsByPeriod(
        companyId: widget.companyId,
        year: _selectedYear,
        month: _selectedMonth,
      );

      if (!_isAutoRegenerating && _hasLegacyInconsistencies(items)) {
        _isAutoRegenerating = true;
        try {
          await widget.service.generatePayroll(
            companyId: widget.companyId,
            year: _selectedYear,
            month: _selectedMonth,
          );
          items = await widget.service.listPayrollItemsByPeriod(
            companyId: widget.companyId,
            year: _selectedYear,
            month: _selectedMonth,
          );
        } finally {
          _isAutoRegenerating = false;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _syncOtherDiscountControllers(items);
        _items = items;
      });
    } catch (_) {
      _showError('No se pudo cargar la liquidacion.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _hasLegacyInconsistencies(List<PayrollItemView> items) {
    // El bruto puede incluir ajustes por jornada nocturna ordinaria sobre
    // salario base, que no se derivan de forma unica desde las columnas
    // persistidas en esta grilla.
    if (items.isEmpty) {
      return false;
    }
    return false;
  }

  void _syncOtherDiscountControllers(List<PayrollItemView> items) {
    final validIds = items.map((item) => item.payrollItem.id).toSet();
    final staleIds = _otherDiscountControllers.keys
        .where((id) => !validIds.contains(id))
        .toList();
    for (final id in staleIds) {
      _otherDiscountControllers.remove(id)?.dispose();
    }
    _savingOtherDiscountIds.removeWhere((id) => !validIds.contains(id));

    for (final item in items) {
      final id = item.payrollItem.id;
      final controller = _otherDiscountControllers.putIfAbsent(
        id,
        () => TextEditingController(),
      );
      final text = item.payrollItem.otherDiscount <= 0
          ? ''
          : GuaraniCurrency.formatPlain(item.payrollItem.otherDiscount);
      if (controller.text != text) {
        controller.text = text;
      }
    }
  }

  Future<void> _saveOtherDiscount(PayrollItemView item) async {
    final id = item.payrollItem.id;
    if (_savingOtherDiscountIds.contains(id)) {
      return;
    }

    final controller = _otherDiscountControllers[id];
    final rawText = controller?.text ?? '';
    final parsed = rawText.trim().isEmpty
        ? 0.0
        : GuaraniCurrency.parse(rawText);
    if (parsed == null || parsed < 0) {
      _showError('Otros descuentos debe ser un monto valido.');
      return;
    }

    setState(() {
      _savingOtherDiscountIds.add(id);
    });

    try {
      await widget.service.updateOtherDiscount(
        payrollItemId: id,
        otherDiscount: parsed,
      );
      await _loadItems();
      if (!mounted) {
        return;
      }
      _showInfo('Otros descuentos guardado para ${item.employeeName}.');
    } catch (error) {
      _showError('No se pudo guardar otros descuentos: $error');
    } finally {
      if (mounted) {
        setState(() {
          _savingOtherDiscountIds.remove(id);
        });
      }
    }
  }

  Future<void> _generatePayroll() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final result = await widget.service.generatePayroll(
        companyId: widget.companyId,
        year: _selectedYear,
        month: _selectedMonth,
      );

      if (!mounted) {
        return;
      }

      await _loadItems();
      if (!mounted) {
        return;
      }
      _showInfo('Liquidacion generada. Items: ${result.itemsGenerated}');
    } catch (_) {
      _showError('No se pudo generar la liquidacion.');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _exportPdf() async {
    if (!_canOutput) {
      return;
    }

    setState(() {
      _isExportingPdf = true;
    });

    try {
      final bytes = await _buildPayrollPdfBytes();
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar liquidacion en PDF',
        fileName: '${_buildReportBaseFileName()}.pdf',
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (savePath == null || savePath.trim().isEmpty) {
        return;
      }

      final resolvedPath = _ensureExtension(savePath, '.pdf');
      await File(resolvedPath).writeAsBytes(bytes, flush: true);
      _showInfo('PDF exportado correctamente.');
    } catch (error) {
      _showError('No se pudo exportar PDF: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
    }
  }

  Future<void> _printPayroll() async {
    if (!_canOutput) {
      return;
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _PayrollPrintPreviewScreen(
            fileName: '${_buildReportBaseFileName()}.pdf',
            buildPdf: (format) => _buildPayrollPdfBytes(pageFormat: format),
          ),
        ),
      );
    } catch (error) {
      _showError('No se pudo imprimir la liquidacion: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  Future<void> _exportExcel() async {
    if (!_canOutput) {
      return;
    }

    setState(() {
      _isExportingExcel = true;
    });

    try {
      final bytes = _buildPayrollExcelBytes();
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar liquidacion en Excel',
        fileName: '${_buildReportBaseFileName()}.xlsx',
        type: FileType.custom,
        allowedExtensions: const ['xlsx', 'xlsm', 'xlms'],
      );
      if (savePath == null || savePath.trim().isEmpty) {
        return;
      }

      var resolvedPath = savePath;
      if (!resolvedPath.toLowerCase().endsWith('.xlsx') &&
          !resolvedPath.toLowerCase().endsWith('.xlsm') &&
          !resolvedPath.toLowerCase().endsWith('.xlms')) {
        resolvedPath = '$resolvedPath.xlsx';
      }

      await File(resolvedPath).writeAsBytes(bytes, flush: true);
      _showInfo('Excel exportado correctamente.');
    } catch (error) {
      _showError('No se pudo exportar Excel: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isExportingExcel = false;
        });
      }
    }
  }

  Uint8List _buildPayrollExcelBytes() {
    final workbook = xl.Excel.createExcel();
    const sheetName = 'Liquidacion';

    final defaultSheet = workbook.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetName) {
      workbook.rename(defaultSheet, sheetName);
    }
    final sheet = workbook[sheetName];
    _setExcelColumnWidths(sheet);

    var rowIndex = 0;
    final titleStart = xl.CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: rowIndex,
    );
    final titleEnd = xl.CellIndex.indexByColumnRow(
      columnIndex: _reportColumns.length - 1,
      rowIndex: rowIndex,
    );
    sheet.cell(titleStart).value = xl.TextCellValue('LIQUIDACION DE SALARIOS');
    sheet.merge(titleStart, titleEnd);
    sheet.setMergedCellStyle(titleStart, _excelTitleStyle());

    rowIndex += 1;

    final companyStart = xl.CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: rowIndex,
    );
    final companyEnd = xl.CellIndex.indexByColumnRow(
      columnIndex: 7,
      rowIndex: rowIndex,
    );
    sheet.cell(companyStart).value = xl.TextCellValue(
      'Empresa: $_normalizedCompanyName',
    );
    sheet.merge(companyStart, companyEnd);
    sheet.setMergedCellStyle(companyStart, _excelMetaStyle());

    final periodStart = xl.CellIndex.indexByColumnRow(
      columnIndex: 8,
      rowIndex: rowIndex,
    );
    final periodEnd = xl.CellIndex.indexByColumnRow(
      columnIndex: _reportColumns.length - 1,
      rowIndex: rowIndex,
    );
    sheet.cell(periodStart).value = xl.TextCellValue('Periodo: $_periodLabel');
    sheet.merge(periodStart, periodEnd);
    sheet.setMergedCellStyle(
      periodStart,
      _excelMetaStyle(horizontalAlign: xl.HorizontalAlign.Right),
    );

    rowIndex += 2;

    _writeExcelRow(
      sheet: sheet,
      rowIndex: rowIndex,
      values: _reportColumns,
      rowType: _ReportRowType.header,
    );
    rowIndex += 1;

    final reportRows = _buildReportRows();
    for (final row in reportRows) {
      _writeExcelRow(
        sheet: sheet,
        rowIndex: rowIndex,
        values: row.cells,
        rowType: row.type,
      );
      rowIndex += 1;
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw StateError('No se pudo generar el archivo Excel.');
    }
    return Uint8List.fromList(bytes);
  }

  Future<Uint8List> _buildPayrollPdfBytes({PdfPageFormat? pageFormat}) async {
    final reportRows = _buildReportRows();
    final document = pw.Document();
    final effectivePageFormat = (pageFormat ?? PdfPageFormat.a4).landscape;

    document.addPage(
      pw.MultiPage(
        pageFormat: effectivePageFormat,
        margin: const pw.EdgeInsets.all(20),
        build: (_) => [
          pw.Text(
            'Liquidacion de Salarios',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Empresa: $_normalizedCompanyName'),
          pw.Text('Periodo: $_periodLabel'),
          pw.SizedBox(height: 2),
          pw.Text(
            'Generado: ${_generatedAtLabel()}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: _reportColumns,
            data: reportRows.map((row) => row.cells).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            textStyleBuilder: (_, cell, rowNum) {
              if (rowNum <= 0) {
                return const pw.TextStyle(fontSize: 7);
              }

              final reportRowIndex = rowNum - 1;
              if (reportRowIndex < 0 || reportRowIndex >= reportRows.length) {
                return const pw.TextStyle(fontSize: 7);
              }

              final type = reportRows[reportRowIndex].type;
              switch (type) {
                case _ReportRowType.subtotal:
                  return const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.blue900,
                  );
                case _ReportRowType.totalGeneral:
                  return const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.red900,
                  );
                case _ReportRowType.header:
                case _ReportRowType.department:
                case _ReportRowType.item:
                  return const pw.TextStyle(fontSize: 7);
              }
            },
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: _pdfCellAlignments(),
            columnWidths: _pdfColumnWidths(),
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
          ),
        ],
      ),
    );

    return document.save();
  }

  Map<int, pw.TableColumnWidth> _pdfColumnWidths() {
    return const {
      0: pw.FlexColumnWidth(2.8),
      1: pw.FlexColumnWidth(1.4),
      2: pw.FlexColumnWidth(0.8),
      3: pw.FlexColumnWidth(0.9),
      4: pw.FlexColumnWidth(1.4),
      5: pw.FlexColumnWidth(1.3),
      6: pw.FlexColumnWidth(1.1),
      7: pw.FlexColumnWidth(1.3),
      8: pw.FlexColumnWidth(1.1),
      9: pw.FlexColumnWidth(1.2),
      10: pw.FlexColumnWidth(1.1),
      11: pw.FlexColumnWidth(1.1),
      12: pw.FlexColumnWidth(1.1),
    };
  }

  Map<int, pw.Alignment> _pdfCellAlignments() {
    return {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.centerRight,
      2: pw.Alignment.centerRight,
      3: pw.Alignment.centerRight,
      4: pw.Alignment.centerRight,
      5: pw.Alignment.centerRight,
      6: pw.Alignment.centerRight,
      7: pw.Alignment.centerRight,
      8: pw.Alignment.centerRight,
      9: pw.Alignment.centerRight,
      10: pw.Alignment.centerRight,
      11: pw.Alignment.centerRight,
      12: pw.Alignment.centerRight,
    };
  }

  void _setExcelColumnWidths(xl.Sheet sheet) {
    const widths = <int, double>{
      0: 34,
      1: 16,
      2: 10,
      3: 11,
      4: 16,
      5: 16,
      6: 14,
      7: 16,
      8: 14,
      9: 14,
      10: 14,
      11: 14,
      12: 14,
    };

    for (final entry in widths.entries) {
      sheet.setColumnWidth(entry.key, entry.value);
    }
  }

  void _writeExcelRow({
    required xl.Sheet sheet,
    required int rowIndex,
    required List<String> values,
    required _ReportRowType rowType,
  }) {
    for (var columnIndex = 0; columnIndex < values.length; columnIndex++) {
      final cell = sheet.cell(
        xl.CellIndex.indexByColumnRow(
          columnIndex: columnIndex,
          rowIndex: rowIndex,
        ),
      );
      cell.value = xl.TextCellValue(values[columnIndex]);
      cell.cellStyle = _excelDataStyle(
        rowType: rowType,
        columnIndex: columnIndex,
      );
    }
  }

  xl.CellStyle _excelTitleStyle() {
    return xl.CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: xl.HorizontalAlign.Center,
      verticalAlign: xl.VerticalAlign.Center,
      fontColorHex: xl.ExcelColor.white,
      backgroundColorHex: xl.ExcelColor.blue,
    );
  }

  xl.CellStyle _excelMetaStyle({
    xl.HorizontalAlign horizontalAlign = xl.HorizontalAlign.Left,
  }) {
    return xl.CellStyle(
      bold: true,
      horizontalAlign: horizontalAlign,
      verticalAlign: xl.VerticalAlign.Center,
    );
  }

  xl.CellStyle _excelDataStyle({
    required _ReportRowType rowType,
    required int columnIndex,
  }) {
    final border = xl.Border(
      borderStyle: xl.BorderStyle.Thin,
      borderColorHex: xl.ExcelColor.grey,
    );

    var background = xl.ExcelColor.none;
    var bold = false;
    switch (rowType) {
      case _ReportRowType.header:
        background = xl.ExcelColor.blue;
        bold = true;
      case _ReportRowType.department:
        background = xl.ExcelColor.lightBlue;
        bold = true;
      case _ReportRowType.subtotal:
        background = xl.ExcelColor.yellow;
        bold = true;
      case _ReportRowType.totalGeneral:
        background = xl.ExcelColor.amber;
        bold = true;
      case _ReportRowType.item:
        break;
    }

    final alignRight =
        rowType != _ReportRowType.department &&
        rowType != _ReportRowType.header &&
        columnIndex >= 1;

    return xl.CellStyle(
      bold: bold,
      horizontalAlign: rowType == _ReportRowType.header
          ? xl.HorizontalAlign.Center
          : alignRight
          ? xl.HorizontalAlign.Right
          : xl.HorizontalAlign.Left,
      verticalAlign: xl.VerticalAlign.Center,
      fontColorHex: rowType == _ReportRowType.header
          ? xl.ExcelColor.white
          : xl.ExcelColor.black,
      backgroundColorHex: background,
      leftBorder: border,
      rightBorder: border,
      topBorder: border,
      bottomBorder: border,
    );
  }

  String _departmentLabel(String? departmentName) {
    final normalized = departmentName?.trim() ?? '';
    return normalized.isEmpty ? 'Sin departamento' : normalized;
  }

  List<_PayrollDepartmentGroup> _buildDepartmentGroups() {
    final groupedByDepartment = <String, List<PayrollItemView>>{};
    for (final item in _items) {
      final key = _departmentLabel(item.departmentName);
      groupedByDepartment.putIfAbsent(key, () => <PayrollItemView>[]).add(item);
    }

    return groupedByDepartment.entries
        .map(
          (entry) => _PayrollDepartmentGroup(
            departmentName: entry.key,
            items: entry.value,
            subtotal: _computeTotals(entry.value),
          ),
        )
        .toList();
  }

  List<_ReportRow> _buildReportRows() {
    final rows = <_ReportRow>[];
    final groups = _buildDepartmentGroups();
    for (final group in groups) {
      rows.add(
        _ReportRow(
          type: _ReportRowType.department,
          cells: _emptyCellsWithLabel(
            'Departamento: ${group.departmentName} (${group.items.length})',
          ),
        ),
      );
      for (final item in group.items) {
        rows.add(
          _ReportRow(type: _ReportRowType.item, cells: _itemValues(item)),
        );
      }
      rows.add(
        _ReportRow(
          type: _ReportRowType.subtotal,
          cells: _summaryValues(
            label: 'Subtotal: ${group.departmentName}',
            totals: group.subtotal,
          ),
        ),
      );
    }

    if (_items.isNotEmpty) {
      rows.add(
        _ReportRow(
          type: _ReportRowType.totalGeneral,
          cells: _summaryValues(
            label: 'Total general',
            totals: _computeTotals(_items),
          ),
        ),
      );
    }

    return rows;
  }

  List<String> _emptyCellsWithLabel(String label) {
    final cells = List<String>.filled(_reportColumns.length, '');
    cells[0] = label;
    return cells;
  }

  List<DataRow> _buildRowsByDepartment() {
    final rows = <DataRow>[];
    final groups = _buildDepartmentGroups();
    for (final group in groups) {
      rows.add(
        _buildDepartmentHeaderRow(group.departmentName, group.items.length),
      );
      rows.addAll(group.items.map(_buildPayrollItemRow));
      rows.add(
        _buildDepartmentSubtotalRow(group.departmentName, group.subtotal),
      );
    }
    if (_items.isNotEmpty) {
      rows.add(_buildTotalGeneralRow(_computeTotals(_items)));
    }
    return rows;
  }

  DataRow _buildDepartmentHeaderRow(String departmentName, int employeeCount) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            'Departamento: $departmentName ($employeeCount)',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
      ],
    );
  }

  DataRow _buildDepartmentSubtotalRow(
    String departmentName,
    _PayrollTotals totals,
  ) {
    return DataRow(
      cells: _buildSummaryCells(
        label: 'Subtotal: $departmentName',
        totals: totals,
      ),
    );
  }

  DataRow _buildTotalGeneralRow(_PayrollTotals totals) {
    return DataRow(
      cells: _buildSummaryCells(label: 'Total general', totals: totals),
    );
  }

  List<DataCell> _buildSummaryCells({
    required String label,
    required _PayrollTotals totals,
  }) {
    const summaryStyle = TextStyle(fontWeight: FontWeight.w700);
    final values = _summaryValuesForGrid(label: label, totals: totals);
    return values
        .map((value) => DataCell(Text(value, style: summaryStyle)))
        .toList();
  }

  List<String> _summaryValuesForGrid({
    required String label,
    required _PayrollTotals totals,
  }) {
    return [
      label,
      '',
      GuaraniCurrency.format(totals.baseSalary),
      totals.workedDays.toStringAsFixed(2),
      totals.workedHours.toStringAsFixed(2),
      totals.overtimeHours.toStringAsFixed(2),
      GuaraniCurrency.format(totals.overtimePay),
      totals.ordinaryNightHours.toStringAsFixed(2),
      GuaraniCurrency.format(totals.ordinaryNightSurchargePay),
      GuaraniCurrency.format(totals.grossPay),
      GuaraniCurrency.format(totals.familyBonus),
      GuaraniCurrency.format(totals.ipsEmployee),
      GuaraniCurrency.format(totals.attendanceDiscount),
      GuaraniCurrency.format(totals.netPay),
      GuaraniCurrency.format(totals.otherDiscount),
      GuaraniCurrency.format(totals.embargoAmount),
    ];
  }

  List<String> _summaryValues({
    required String label,
    required _PayrollTotals totals,
  }) {
    return [
      label,
      GuaraniCurrency.format(totals.baseSalary),
      totals.workedDays.toStringAsFixed(2),
      totals.overtimeHours.toStringAsFixed(2),
      GuaraniCurrency.format(totals.overtimePay),
      GuaraniCurrency.format(totals.ordinaryNightSurchargePay),
      GuaraniCurrency.format(totals.grossPay),
      GuaraniCurrency.format(totals.familyBonus),
      GuaraniCurrency.format(totals.ipsEmployee),
      GuaraniCurrency.format(totals.attendanceDiscount),
      GuaraniCurrency.format(totals.netPay),
      GuaraniCurrency.format(totals.otherDiscount),
      GuaraniCurrency.format(totals.embargoAmount),
    ];
  }

  List<String> _itemValues(PayrollItemView item) {
    return [
      item.employeeName,
      GuaraniCurrency.format(item.payrollItem.baseSalary),
      item.payrollItem.workedDays.toStringAsFixed(2),
      item.payrollItem.overtimeHours.toStringAsFixed(2),
      GuaraniCurrency.format(item.payrollItem.overtimePay),
      GuaraniCurrency.format(item.payrollItem.ordinaryNightSurchargePay),
      GuaraniCurrency.format(item.payrollItem.grossPay),
      GuaraniCurrency.format(item.payrollItem.familyBonus),
      GuaraniCurrency.format(item.payrollItem.ipsEmployee),
      GuaraniCurrency.format(item.payrollItem.attendanceDiscount),
      GuaraniCurrency.format(item.payrollItem.netPay),
      GuaraniCurrency.format(item.payrollItem.otherDiscount),
      item.payrollItem.embargoAmount == null
          ? '-'
          : GuaraniCurrency.format(item.payrollItem.embargoAmount!),
    ];
  }

  _PayrollTotals _computeTotals(Iterable<PayrollItemView> items) {
    var baseSalary = 0.0;
    var workedDays = 0.0;
    var workedHours = 0.0;
    var overtimeHours = 0.0;
    var overtimePay = 0.0;
    var ordinaryNightHours = 0.0;
    var ordinaryNightSurchargePay = 0.0;
    var grossPay = 0.0;
    var familyBonus = 0.0;
    var ipsEmployee = 0.0;
    var attendanceDiscount = 0.0;
    var netPay = 0.0;
    var otherDiscount = 0.0;
    var embargoAmount = 0.0;

    for (final item in items) {
      final payrollItem = item.payrollItem;
      baseSalary += payrollItem.baseSalary;
      workedDays += payrollItem.workedDays;
      workedHours += payrollItem.workedHours;
      overtimeHours += payrollItem.overtimeHours;
      overtimePay += payrollItem.overtimePay;
      ordinaryNightHours += payrollItem.ordinaryNightHours;
      ordinaryNightSurchargePay += payrollItem.ordinaryNightSurchargePay;
      grossPay += payrollItem.grossPay;
      familyBonus += payrollItem.familyBonus;
      ipsEmployee += payrollItem.ipsEmployee;
      attendanceDiscount += payrollItem.attendanceDiscount;
      netPay += payrollItem.netPay;
      otherDiscount += payrollItem.otherDiscount;
      embargoAmount += payrollItem.embargoAmount ?? 0;
    }

    return _PayrollTotals(
      baseSalary: baseSalary,
      workedDays: workedDays,
      workedHours: workedHours,
      overtimeHours: overtimeHours,
      overtimePay: overtimePay,
      ordinaryNightHours: ordinaryNightHours,
      ordinaryNightSurchargePay: ordinaryNightSurchargePay,
      grossPay: grossPay,
      familyBonus: familyBonus,
      ipsEmployee: ipsEmployee,
      attendanceDiscount: attendanceDiscount,
      netPay: netPay,
      otherDiscount: otherDiscount,
      embargoAmount: embargoAmount,
    );
  }

  DataRow _buildPayrollItemRow(PayrollItemView item) {
    return DataRow(
      cells: [
        DataCell(Text(item.employeeName)),
        DataCell(Text(item.payrollItem.employeeType)),
        DataCell(Text(GuaraniCurrency.format(item.payrollItem.baseSalary))),
        DataCell(Text(item.payrollItem.workedDays.toStringAsFixed(2))),
        DataCell(Text(item.payrollItem.workedHours.toStringAsFixed(2))),
        DataCell(Text(item.payrollItem.overtimeHours.toStringAsFixed(2))),
        DataCell(Text(GuaraniCurrency.format(item.payrollItem.overtimePay))),
        DataCell(Text(item.payrollItem.ordinaryNightHours.toStringAsFixed(2))),
        DataCell(
          Text(
            GuaraniCurrency.format(item.payrollItem.ordinaryNightSurchargePay),
          ),
        ),
        DataCell(Text(GuaraniCurrency.format(item.payrollItem.grossPay))),
        DataCell(Text(GuaraniCurrency.format(item.payrollItem.familyBonus))),
        DataCell(Text(GuaraniCurrency.format(item.payrollItem.ipsEmployee))),
        DataCell(
          Text(GuaraniCurrency.format(item.payrollItem.attendanceDiscount)),
        ),
        DataCell(Text(GuaraniCurrency.format(item.payrollItem.netPay))),
        DataCell(
          SizedBox(
            width: 110,
            child: TextField(
              controller: _otherDiscountControllers[item.payrollItem.id],
              enabled: !_savingOtherDiscountIds.contains(item.payrollItem.id),
              keyboardType: TextInputType.number,
              inputFormatters: const [ThousandsSeparatorInputFormatter()],
              decoration: const InputDecoration(
                hintText: '0',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveOtherDiscount(item),
            ),
          ),
        ),
        DataCell(
          Text(
            item.payrollItem.embargoAmount == null
                ? '-'
                : GuaraniCurrency.format(item.payrollItem.embargoAmount!),
          ),
        ),
      ],
    );
  }

  String _buildReportBaseFileName() {
    final companyPart = _sanitizeFileNamePart(_normalizedCompanyName);
    final month = _selectedMonth.toString().padLeft(2, '0');
    return 'liquidacion_${companyPart}_${_selectedYear}_$month';
  }

  String _sanitizeFileNamePart(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .toLowerCase();
  }

  String _generatedAtLabel() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$day/$month/${now.year} $hour:$minute';
  }

  String _ensureExtension(String path, String extension) {
    if (path.toLowerCase().endsWith(extension.toLowerCase())) {
      return path;
    }
    return '$path$extension';
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  setState(() {
                    _selectedMonth = value;
                  });
                  _loadItems();
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
                  setState(() {
                    _selectedYear = value;
                  });
                  _loadItems();
                },
              ),
              FilledButton.icon(
                onPressed: _canGenerate ? _generatePayroll : null,
                icon: const Icon(Icons.calculate),
                label: Text(
                  _isGenerating ? 'Generando...' : 'Generar liquidacion',
                ),
              ),
              OutlinedButton.icon(
                onPressed: _canOutput ? _printPayroll : null,
                icon: const Icon(Icons.print),
                label: Text(_isPrinting ? 'Imprimiendo...' : 'Imprimir'),
              ),
              OutlinedButton.icon(
                onPressed: _canOutput ? _exportPdf : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(
                  _isExportingPdf ? 'Exportando PDF...' : 'Exportar PDF',
                ),
              ),
              OutlinedButton.icon(
                onPressed: _canOutput ? _exportExcel : null,
                icon: const Icon(Icons.table_view),
                label: Text(
                  _isExportingExcel ? 'Exportando Excel...' : 'Exportar Excel',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Empresa: $_normalizedCompanyName | Periodo: $_periodLabel',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? const Center(child: Text('No hay liquidacion generada.'))
                : ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.stylus,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      notificationPredicate: (notification) =>
                          notification.metrics.axis == Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          notificationPredicate: (notification) =>
                              notification.metrics.axis == Axis.vertical,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            child: DataTable(
                              columnSpacing: 28,
                              horizontalMargin: 14,
                              columns: const [
                                DataColumn(label: Text('Empleado')),
                                DataColumn(label: Text('Tipo')),
                                DataColumn(label: Text('Salario base')),
                                DataColumn(label: Text('Dias')),
                                DataColumn(label: Text('Horas')),
                                DataColumn(label: Text('Horas extra')),
                                DataColumn(label: Text('Valor horas extra')),
                                DataColumn(label: Text('Hs noct. ord.')),
                                DataColumn(label: Text('Recargo noct. ord.')),
                                DataColumn(label: Text('Bruto')),
                                DataColumn(label: Text('Bonif. familiar')),
                                DataColumn(label: Text('IPS empleado')),
                                DataColumn(label: Text('Descuentos')),
                                DataColumn(label: Text('Saldo')),
                                DataColumn(label: Text('Otros desc.')),
                                DataColumn(label: Text('Embargo')),
                              ],
                              rows: _buildRowsByDepartment(),
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

class _PayrollDepartmentGroup {
  const _PayrollDepartmentGroup({
    required this.departmentName,
    required this.items,
    required this.subtotal,
  });

  final String departmentName;
  final List<PayrollItemView> items;
  final _PayrollTotals subtotal;
}

class _PayrollTotals {
  const _PayrollTotals({
    required this.baseSalary,
    required this.workedDays,
    required this.workedHours,
    required this.overtimeHours,
    required this.overtimePay,
    required this.ordinaryNightHours,
    required this.ordinaryNightSurchargePay,
    required this.grossPay,
    required this.familyBonus,
    required this.ipsEmployee,
    required this.attendanceDiscount,
    required this.netPay,
    required this.otherDiscount,
    required this.embargoAmount,
  });

  final double baseSalary;
  final double workedDays;
  final double workedHours;
  final double overtimeHours;
  final double overtimePay;
  final double ordinaryNightHours;
  final double ordinaryNightSurchargePay;
  final double grossPay;
  final double familyBonus;
  final double ipsEmployee;
  final double attendanceDiscount;
  final double netPay;
  final double otherDiscount;
  final double embargoAmount;
}

class _ReportRow {
  const _ReportRow({required this.type, required this.cells});

  final _ReportRowType type;
  final List<String> cells;
}

enum _ReportRowType { header, department, item, subtotal, totalGeneral }

class _PayrollPrintPreviewScreen extends StatelessWidget {
  const _PayrollPrintPreviewScreen({
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
        initialPageFormat: PdfPageFormat.a4.landscape,
        canChangeOrientation: false,
        canChangePageFormat: false,
        build: (format) => buildPdf(format.landscape),
      ),
    );
  }
}
