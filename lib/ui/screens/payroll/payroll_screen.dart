import 'dart:io';
import 'dart:math' as math;
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
    required this.companyMjtEmployerNumber,
    required this.companyLogoPng,
    required this.canGeneratePayroll,
    required this.canLockPayroll,
    required this.canUnlockPayroll,
    required this.canPrintPayroll,
    required this.canExportPayroll,
    super.key,
  });

  final PayrollService service;
  final int companyId;
  final String companyName;
  final String? companyMjtEmployerNumber;
  final Uint8List? companyLogoPng;
  final bool canGeneratePayroll;
  final bool canLockPayroll;
  final bool canUnlockPayroll;
  final bool canPrintPayroll;
  final bool canExportPayroll;

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  static const int _gridColumnsCount = 17;
  static const Color _employeeNameColor = Color(0xFF123A73);
  static const Color _selectedRowColor = Color(0xFFE8F1FF);
  static const Color _activeEmployeeColor = Color(0xFFC62828);
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
    'Otros ingresos',
    'Bruto',
    'Bonif. familiar',
    'IPS empleado',
    'Descuentos',
    'Otros desc.',
    'Embargo',
    'Saldo',
  ];

  List<PayrollItemView> _items = const [];
  final TextEditingController _searchController = TextEditingController();
  final Map<int, TextEditingController> _otherIncomeControllers = {};
  final Map<int, TextEditingController> _otherDiscountControllers = {};
  final Set<int> _savingOtherIncomeIds = <int>{};
  final Set<int> _savingOtherDiscountIds = <int>{};
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  bool _isAutoRegenerating = false;
  bool _isLoading = false;
  bool _isGenerating = false;
  bool _isLocking = false;
  bool _isUnlocking = false;
  bool _isExportingPdf = false;
  bool _isExportingExcel = false;
  bool _isPrinting = false;
  bool _isPrintingReceipt = false;
  PayrollPeriodStatus _periodStatus = const PayrollPeriodStatus(run: null);
  int? _selectedPayrollItemId;
  String? _activeEditingEmployeeName;
  late int _selectedYear;
  late int _selectedMonth;

  bool get _isLocked => _periodStatus.isLocked;
  bool get _hasRun => _periodStatus.hasRun;
  bool get _isOutputBusy =>
      _isExportingPdf || _isExportingExcel || _isPrinting || _isPrintingReceipt;
  bool get _isActionBusy =>
      _isGenerating || _isLocking || _isUnlocking || _isOutputBusy;
  bool get _canGenerate =>
      widget.canGeneratePayroll && !_isLoading && !_isActionBusy && !_isLocked;
  bool get _canLock =>
      widget.canLockPayroll &&
      !_isLoading &&
      !_isActionBusy &&
      _hasRun &&
      !_isLocked;
  bool get _canUnlock =>
      widget.canUnlockPayroll && !_isLoading && !_isActionBusy && _isLocked;
  bool get _canEditRows =>
      widget.canGeneratePayroll && !_isLoading && !_isActionBusy && !_isLocked;
  bool get _canOutput =>
      widget.canExportPayroll &&
      !_isLoading &&
      !_isActionBusy &&
      _items.isNotEmpty;
  bool get _canPrint =>
      widget.canPrintPayroll &&
      !_isLoading &&
      !_isActionBusy &&
      _items.isNotEmpty;
  bool get _canPrintReceipt =>
      widget.canPrintPayroll &&
      !_isLoading &&
      !_isActionBusy &&
      _receiptItemsForDuplicate().isNotEmpty;

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
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
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
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    for (final controller in _otherIncomeControllers.values) {
      controller.dispose();
    }
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
      final periodStatusFuture = widget.service.getPayrollPeriodStatus(
        companyId: widget.companyId,
        year: _selectedYear,
        month: _selectedMonth,
      );
      var items = await widget.service.listPayrollItemsByPeriod(
        companyId: widget.companyId,
        year: _selectedYear,
        month: _selectedMonth,
      );
      var periodStatus = await periodStatusFuture;

      if (!_isAutoRegenerating &&
          !periodStatus.isLocked &&
          _hasLegacyInconsistencies(items)) {
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
          periodStatus = await widget.service.getPayrollPeriodStatus(
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

      final validIds = items.map((item) => item.payrollItem.id).toSet();
      final isSelectedStillValid =
          _selectedPayrollItemId != null &&
          validIds.contains(_selectedPayrollItemId);

      setState(() {
        _syncOtherIncomeControllers(items);
        _syncOtherDiscountControllers(items);
        _items = items;
        _periodStatus = periodStatus;
        if (!isSelectedStillValid) {
          _selectedPayrollItemId = null;
          _activeEditingEmployeeName = null;
        }
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

  List<PayrollItemView> _filteredItems() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _items;
    }
    return _items
        .where((item) => item.employeeName.toLowerCase().contains(query))
        .toList();
  }

  List<PayrollItemView> _receiptItemsForDuplicate() {
    final filteredItems = _filteredItems();
    if (filteredItems.length == 1) {
      final filteredItem = filteredItems.first;
      if (!filteredItem.ipsEnabled) {
        return const [];
      }
      return [filteredItem];
    }
    return _items.where((item) => item.ipsEnabled).toList();
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

  void _syncOtherIncomeControllers(List<PayrollItemView> items) {
    final validIds = items.map((item) => item.payrollItem.id).toSet();
    final staleIds = _otherIncomeControllers.keys
        .where((id) => !validIds.contains(id))
        .toList();
    for (final id in staleIds) {
      _otherIncomeControllers.remove(id)?.dispose();
    }
    _savingOtherIncomeIds.removeWhere((id) => !validIds.contains(id));

    for (final item in items) {
      final id = item.payrollItem.id;
      final controller = _otherIncomeControllers.putIfAbsent(
        id,
        () => TextEditingController(),
      );
      final text = item.payrollItem.advancesTotal <= 0
          ? ''
          : GuaraniCurrency.formatPlain(item.payrollItem.advancesTotal);
      if (controller.text != text) {
        controller.text = text;
      }
    }
  }

  Future<void> _saveOtherIncome(PayrollItemView item) async {
    if (!_canEditRows) {
      _showError(
        'La liquidacion esta guardada o no tiene permiso para editar.',
      );
      return;
    }
    final id = item.payrollItem.id;
    if (_savingOtherIncomeIds.contains(id)) {
      return;
    }

    final controller = _otherIncomeControllers[id];
    final rawText = controller?.text ?? '';
    final parsed = rawText.trim().isEmpty
        ? 0.0
        : GuaraniCurrency.parse(rawText);
    if (parsed == null || parsed < 0) {
      _showError('Otros ingresos debe ser un monto valido.');
      return;
    }

    setState(() {
      _savingOtherIncomeIds.add(id);
    });

    try {
      await widget.service.updateOtherIncome(
        payrollItemId: id,
        otherIncome: parsed,
      );
      await _loadItems();
      if (!mounted) {
        return;
      }
      _showInfo('Otros ingresos guardado para ${item.employeeName}.');
    } catch (error) {
      _showError('No se pudo guardar otros ingresos: $error');
    } finally {
      if (mounted) {
        setState(() {
          _savingOtherIncomeIds.remove(id);
        });
      }
    }
  }

  Future<void> _saveOtherDiscount(PayrollItemView item) async {
    if (!_canEditRows) {
      _showError(
        'La liquidacion esta guardada o no tiene permiso para editar.',
      );
      return;
    }
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
    if (!_canGenerate) {
      return;
    }
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
    } catch (error) {
      _showError('No se pudo generar la liquidacion: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _lockPayroll() async {
    if (!_canLock) {
      return;
    }

    setState(() {
      _isLocking = true;
    });

    try {
      await widget.service.lockPayrollRun(
        companyId: widget.companyId,
        year: _selectedYear,
        month: _selectedMonth,
      );
      await _loadItems();
      if (!mounted) {
        return;
      }
      _showInfo('Liquidacion guardada y bloqueada.');
    } catch (error) {
      _showError('No se pudo guardar la liquidacion: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLocking = false;
        });
      }
    }
  }

  Future<void> _unlockPayroll() async {
    if (!_canUnlock) {
      return;
    }

    final password = await _showUnlockPasswordDialog();
    if (password == null) {
      return;
    }

    setState(() {
      _isUnlocking = true;
    });

    try {
      await widget.service.unlockPayrollRun(
        companyId: widget.companyId,
        year: _selectedYear,
        month: _selectedMonth,
        password: password,
      );
      await _loadItems();
      if (!mounted) {
        return;
      }
      _showInfo('Liquidacion desbloqueada.');
    } catch (error) {
      _showError('No se pudo desbloquear la liquidacion: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
        });
      }
    }
  }

  Future<String?> _showUnlockPasswordDialog() {
    return showDialog<String>(
      context: context,
      builder: (_) => const _UnlockPayrollDialog(),
    );
  }

  void _activateEmployeeContext(PayrollItemView item) {
    final id = item.payrollItem.id;
    final name = item.employeeName;
    if (_selectedPayrollItemId == id && _activeEditingEmployeeName == name) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedPayrollItemId = id;
      _activeEditingEmployeeName = name;
    });
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
    if (!_canPrint) {
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
            initialPageFormat: PdfPageFormat.a4.landscape,
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

  Future<void> _printDuplicateReceipt() async {
    if (!_canPrintReceipt) {
      return;
    }

    final targetItems = _receiptItemsForDuplicate();
    if (targetItems.isEmpty) {
      final filteredItems = _filteredItems();
      if (filteredItems.length == 1 && !filteredItems.first.ipsEnabled) {
        _showError('El empleado filtrado no tiene IPS activo.');
        return;
      }
      _showError('No hay empleados con IPS activo para imprimir boleta.');
      return;
    }

    final isSingleTarget = targetItems.length == 1;
    final previewTitle = isSingleTarget
        ? 'Vista previa boleta de pago'
        : 'Vista previa boleta de pago (${targetItems.length} empleados)';
    final fileName = isSingleTarget
        ? '${_buildReportBaseFileName()}_boleta_${_sanitizeFileNamePart(targetItems.first.employeeName)}.pdf'
        : '${_buildReportBaseFileName()}_boletas_ips_activado.pdf';

    setState(() {
      _isPrintingReceipt = true;
    });

    try {
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _PayrollPrintPreviewScreen(
            title: previewTitle,
            fileName: fileName,
            initialPageFormat: PdfPageFormat.a4,
            buildPdf: (format) => _buildDuplicateReceiptPdfBytes(
              targetItems,
              pageFormat: format,
            ),
          ),
        ),
      );
    } catch (error) {
      _showError('No se pudo imprimir la boleta: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPrintingReceipt = false;
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
    final reportRows = _buildReportRows();
    final excelData = reportRows
        .map((row) => row.cells.map(_sanitizeExportValue).toList())
        .toList();

    final defaultSheet = workbook.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetName) {
      workbook.rename(defaultSheet, sheetName);
    }
    final sheet = workbook[sheetName];
    _setExcelColumnWidths(sheet, headers: _reportColumns, rows: excelData);

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

    for (var index = 0; index < reportRows.length; index++) {
      final row = reportRows[index];
      _writeExcelRow(
        sheet: sheet,
        rowIndex: rowIndex,
        values: excelData[index],
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
    final pdfData = reportRows
        .map((row) => row.cells.map(_sanitizeExportValue).toList())
        .toList();
    final document = pw.Document();
    final effectivePageFormat = PdfPageFormat.a4.landscape;
    const pageMargin = pw.EdgeInsets.fromLTRB(12, 16, 12, 16);

    document.addPage(
      pw.MultiPage(
        pageFormat: effectivePageFormat,
        margin: pageMargin,
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
            data: pdfData,
            headerStyle: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 6.3),
            headerPadding: const pw.EdgeInsets.symmetric(
              horizontal: 3,
              vertical: 3,
            ),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 2.2,
              vertical: 2,
            ),
            textStyleBuilder: (_, cell, rowNum) {
              if (rowNum <= 0) {
                return const pw.TextStyle(fontSize: 6.3);
              }

              final reportRowIndex = rowNum - 1;
              if (reportRowIndex < 0 || reportRowIndex >= reportRows.length) {
                return const pw.TextStyle(fontSize: 6.3);
              }

              final type = reportRows[reportRowIndex].type;
              switch (type) {
                case _ReportRowType.subtotal:
                  return const pw.TextStyle(
                    fontSize: 6.3,
                    color: PdfColors.blue900,
                  );
                case _ReportRowType.totalGeneral:
                  return const pw.TextStyle(
                    fontSize: 6.3,
                    color: PdfColors.red900,
                  );
                case _ReportRowType.header:
                case _ReportRowType.department:
                case _ReportRowType.item:
                  return const pw.TextStyle(fontSize: 6.3);
              }
            },
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: _pdfCellAlignments(),
            columnWidths: _pdfColumnWidths(
              headers: _reportColumns,
              rows: pdfData,
              pageFormat: effectivePageFormat,
              horizontalMargin: pageMargin.left + pageMargin.right,
            ),
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

  Future<Uint8List> _buildDuplicateReceiptPdfBytes(
    List<PayrollItemView> items, {
    PdfPageFormat? pageFormat,
  }) async {
    final document = pw.Document();
    final effectivePageFormat = pageFormat ?? PdfPageFormat.a4;
    const pageMargin = pw.EdgeInsets.fromLTRB(24, 22, 24, 22);

    for (final item in items) {
      document.addPage(
        pw.Page(
          pageFormat: effectivePageFormat,
          margin: pageMargin,
          build: (_) => pw.Column(
            children: [
              pw.Expanded(
                child: _buildReceiptCopy(item, copyLabel: 'ORIGINAL'),
              ),
              pw.SizedBox(height: 14),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        height: 1,
                        color: PdfColors.grey500,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12),
                      child: pw.Text(
                        'CORTE',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        height: 1,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Expanded(
                child: _buildReceiptCopy(item, copyLabel: 'DUPLICADO'),
              ),
            ],
          ),
        ),
      );
    }

    return document.save();
  }

  pw.Widget _buildReceiptCopy(
    PayrollItemView item, {
    required String copyLabel,
  }) {
    final logoBytes = widget.companyLogoPng;
    final logoImage = (logoBytes != null && logoBytes.isNotEmpty)
        ? pw.MemoryImage(logoBytes)
        : null;
    final payrollItem = item.payrollItem;
    final overtimeAndNightSurchargeTotal =
        payrollItem.overtimePay + payrollItem.ordinaryNightSurchargePay;
    final subtotalBase = math.max(
      0.0,
      payrollItem.grossPay -
          payrollItem.overtimePay -
          payrollItem.ordinaryNightSurchargePay,
    );
    final totalSalary =
        payrollItem.grossPay +
        payrollItem.familyBonus +
        payrollItem.advancesTotal;
    final otherDiscounts =
        payrollItem.attendanceDiscount +
        payrollItem.otherDiscount +
        (payrollItem.embargoAmount ?? 0);
    final totalDiscounts = payrollItem.ipsEmployee + otherDiscounts;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500, width: 0.8),
      ),
      padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 120,
                height: 44,
                child: logoImage == null
                    ? pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.grey500,
                            width: 0.6,
                          ),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'LOGO',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ),
                      )
                    : pw.Image(logoImage, fit: pw.BoxFit.contain),
              ),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'LIQUIDACI\u00d3N DE SALARIO',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '(Art. 236 del C\u00f3d. del Trabajo)',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(
                width: 90,
                child: pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text(
                    copyLabel,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            children: [
              pw.SizedBox(width: 120),
              pw.Expanded(
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'SERIE A',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'L.S.',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 90),
            ],
          ),
          pw.SizedBox(height: 8),
          _buildReceiptLine(
            label: 'EMPLEADOR',
            value: _normalizedCompanyName.toUpperCase(),
            rightLabel: 'N\u00b0 PATRONAL MJT',
            rightValue: (widget.companyMjtEmployerNumber ?? '').trim().isEmpty
                ? '-'
                : widget.companyMjtEmployerNumber!.trim(),
          ),
          pw.SizedBox(height: 6),
          _buildReceiptLine(
            label: 'APELLIDO Y NOMBRE DEL TRABAJADOR',
            value: item.employeeNameLastFirst.toUpperCase(),
          ),
          pw.SizedBox(height: 6),
          _buildReceiptLine(
            label: 'PER\u00cdODO DE PAGO',
            value: _payrollPeriodRangeLabel(),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.6),
            columnWidths: const {
              0: pw.FixedColumnWidth(26),
              1: pw.FixedColumnWidth(63),
              2: pw.FixedColumnWidth(63),
              3: pw.FixedColumnWidth(56),
              4: pw.FixedColumnWidth(62),
              5: pw.FixedColumnWidth(62),
              6: pw.FixedColumnWidth(66),
              7: pw.FixedColumnWidth(56),
              8: pw.FixedColumnWidth(56),
              9: pw.FixedColumnWidth(56),
              10: pw.FixedColumnWidth(62),
            },
            children: [
              _receiptHeaderRow(),
              _receiptValueRow(
                values: [
                  _formatFixed0(payrollItem.workedDays),
                  GuaraniCurrency.formatPlain(payrollItem.baseSalary),
                  GuaraniCurrency.formatPlain(subtotalBase),
                  GuaraniCurrency.formatPlain(overtimeAndNightSurchargeTotal),
                  GuaraniCurrency.formatPlain(payrollItem.familyBonus),
                  GuaraniCurrency.formatPlain(payrollItem.advancesTotal),
                  GuaraniCurrency.formatPlain(totalSalary),
                  GuaraniCurrency.formatPlain(payrollItem.ipsEmployee),
                  GuaraniCurrency.formatPlain(otherDiscounts),
                  GuaraniCurrency.formatPlain(totalDiscounts),
                  GuaraniCurrency.formatPlain(payrollItem.netPay),
                ],
              ),
            ],
          ),
          pw.Spacer(),
          pw.Row(
            children: [
              _signatureBlock(title: _receiptDateLabel(), subtitle: 'Fecha'),
              pw.SizedBox(width: 18),
              _signatureBlock(title: '', subtitle: 'Firma del empleador'),
              pw.SizedBox(width: 18),
              _signatureBlock(title: '', subtitle: 'Firma de empleado'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReceiptLine({
    required String label,
    required String value,
    String? rightLabel,
    String? rightValue,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 1),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.6),
              ),
            ),
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
          ),
        ),
        if (rightLabel != null && rightValue != null) ...[
          pw.SizedBox(width: 8),
          pw.Text(
            '$rightLabel: ',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(
            width: 90,
            child: pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 1),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey500, width: 0.6),
                ),
              ),
              child: pw.Text(
                rightValue,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ),
        ],
      ],
    );
  }

  pw.TableRow _receiptHeaderRow() {
    pw.Widget headerCell(String text) {
      return pw.Container(
        color: PdfColors.grey300,
        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        alignment: pw.Alignment.center,
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
      );
    }

    return pw.TableRow(
      children: [
        headerCell('D.T.'),
        headerCell('Salario\nB\u00e1sico'),
        headerCell('Sub total'),
        headerCell('Horas\nextras'),
        headerCell('Bonif.\nfamiliar'),
        headerCell('Otros\nIngresos'),
        headerCell('Total\nSalario'),
        headerCell('IPS'),
        headerCell('Otros\ndesc.'),
        headerCell('Total\ndesc.'),
        headerCell('Saldo a\nCobrar'),
      ],
    );
  }

  pw.TableRow _receiptValueRow({required List<String> values}) {
    return pw.TableRow(
      children: values
          .map(
            (value) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 4,
              ),
              alignment: pw.Alignment.centerRight,
              child: pw.Text(value, style: const pw.TextStyle(fontSize: 8.5)),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _signatureBlock({required String title, required String subtitle}) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.Container(
            height: 18,
            alignment: pw.Alignment.bottomCenter,
            child: pw.Text(
              title,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 4),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey500, width: 0.6),
              ),
            ),
            padding: const pw.EdgeInsets.only(top: 3),
            alignment: pw.Alignment.center,
            child: pw.Text(subtitle, style: const pw.TextStyle(fontSize: 8.5)),
          ),
        ],
      ),
    );
  }

  String _payrollPeriodRangeLabel() {
    final lastDay = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final dayTo = lastDay.toString().padLeft(2, '0');
    return 'del 01 al $dayTo de ${_monthNames[_selectedMonth - 1].toLowerCase()} de $_selectedYear';
  }

  String _receiptDateLabel() {
    final date = DateTime(_selectedYear, _selectedMonth + 1, 0);
    return '${date.day} de ${_monthNames[_selectedMonth - 1].toLowerCase()} de $_selectedYear';
  }

  String _formatFixed0(double value) {
    return value.toStringAsFixed(0);
  }

  Map<int, pw.TableColumnWidth> _pdfColumnWidths({
    required List<String> headers,
    required List<List<String>> rows,
    required PdfPageFormat pageFormat,
    required double horizontalMargin,
  }) {
    final columnCount = headers.length;
    final availableWidth = pageFormat.availableWidth - horizontalMargin;
    final widths = <double>[];

    for (var column = 0; column < headers.length; column++) {
      var maxLen = _cellLengthForPdf(headers[column]);
      for (final row in rows) {
        if (column >= row.length) {
          continue;
        }
        final len = _cellLengthForPdf(row[column]);
        if (len > maxLen) {
          maxLen = len;
        }
      }

      var estimatedWidth = (maxLen * 3.95) + 9;
      if (column == 0) {
        estimatedWidth = estimatedWidth.clamp(138.0, 210.0);
      } else {
        estimatedWidth = estimatedWidth.clamp(52.0, 88.0);
      }
      widths.add(estimatedWidth);
    }

    var total = widths.fold<double>(0, (sum, value) => sum + value);
    if (total > availableWidth) {
      final minWidths = List<double>.generate(
        columnCount,
        (index) => index == 0 ? 120.0 : 44.0,
      );
      final shrinkable = List<double>.generate(
        columnCount,
        (index) => math.max(0, widths[index] - minWidths[index]),
      );
      final totalShrinkable = shrinkable.fold<double>(
        0,
        (sum, value) => sum + value,
      );
      final overflow = total - availableWidth;
      if (overflow > 0 && totalShrinkable > 0) {
        for (var index = 0; index < columnCount; index++) {
          final reduction = overflow * (shrinkable[index] / totalShrinkable);
          widths[index] = math.max(minWidths[index], widths[index] - reduction);
        }
      }
      total = widths.fold<double>(0, (sum, value) => sum + value);
    }

    if (total < availableWidth && widths.isNotEmpty) {
      final extra = availableWidth - total;
      widths[0] += extra * 0.35;
      final spread = widths.length - 1;
      if (spread > 0) {
        final byColumn = (extra * 0.65) / spread;
        for (var index = 1; index < widths.length; index++) {
          widths[index] += byColumn;
        }
      }
    }

    final result = <int, pw.TableColumnWidth>{};
    for (var index = 0; index < widths.length; index++) {
      result[index] = pw.FixedColumnWidth(widths[index]);
    }
    return result;
  }

  int _cellLengthForPdf(String value) {
    final normalized = value.replaceAll('\n', ' ').trim();
    return math.max(1, normalized.length);
  }

  String _sanitizeExportValue(String value) {
    return value.replaceAll(RegExp(r'\s*Gs\.\s*', caseSensitive: false), '');
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
      13: pw.Alignment.centerRight,
    };
  }

  void _setExcelColumnWidths(
    xl.Sheet sheet, {
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    for (var column = 0; column < headers.length; column++) {
      var maxLen = _excelCellLength(headers[column]);
      for (final row in rows) {
        if (column >= row.length) {
          continue;
        }
        final len = _excelCellLength(row[column]);
        if (len > maxLen) {
          maxLen = len;
        }
      }

      final minWidth = column == 0 ? 20.0 : 10.0;
      final maxWidth = column == 0 ? 48.0 : 24.0;
      final width = ((maxLen + 2) * 1.1).clamp(minWidth, maxWidth).toDouble();
      sheet.setColumnWidth(column, width);
    }
  }

  int _excelCellLength(String value) {
    final normalized = value.replaceAll('\n', ' ').trim();
    return math.max(1, normalized.length);
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

  List<_PayrollDepartmentGroup> _buildDepartmentGroups(
    Iterable<PayrollItemView> sourceItems,
  ) {
    final groupedByDepartment = <String, List<PayrollItemView>>{};
    for (final item in sourceItems) {
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
    final groups = _buildDepartmentGroups(_items);
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

  List<DataRow> _buildRowsByDepartment(List<PayrollItemView> sourceItems) {
    final rows = <DataRow>[];
    final groups = _buildDepartmentGroups(sourceItems);
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
      rows.add(_buildTotalGeneralRow(_computeTotals(sourceItems)));
    }
    return rows;
  }

  DataRow _buildDepartmentHeaderRow(String departmentName, int employeeCount) {
    final empty = const DataCell(Text(''));
    final cells = List<DataCell>.generate(
      _gridColumnsCount,
      (index) => index == 0
          ? DataCell(
              Text(
                'Departamento: $departmentName ($employeeCount)',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : empty,
    );
    return DataRow(cells: cells);
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
      GuaraniCurrency.format(totals.otherIncome),
      GuaraniCurrency.format(totals.grossPay),
      GuaraniCurrency.format(totals.familyBonus),
      GuaraniCurrency.format(totals.ipsEmployee),
      GuaraniCurrency.format(totals.attendanceDiscount),
      GuaraniCurrency.format(totals.otherDiscount),
      GuaraniCurrency.format(totals.embargoAmount),
      GuaraniCurrency.format(totals.netPay),
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
      GuaraniCurrency.format(totals.otherIncome),
      GuaraniCurrency.format(totals.grossPay),
      GuaraniCurrency.format(totals.familyBonus),
      GuaraniCurrency.format(totals.ipsEmployee),
      GuaraniCurrency.format(totals.attendanceDiscount),
      GuaraniCurrency.format(totals.otherDiscount),
      GuaraniCurrency.format(totals.embargoAmount),
      GuaraniCurrency.format(totals.netPay),
    ];
  }

  List<String> _itemValues(PayrollItemView item) {
    final grossWithOtherIncome = _grossWithOtherIncomeValues(
      item.payrollItem.grossPay,
      item.payrollItem.advancesTotal,
    );
    return [
      item.employeeName,
      GuaraniCurrency.format(item.payrollItem.baseSalary),
      item.payrollItem.workedDays.toStringAsFixed(2),
      item.payrollItem.overtimeHours.toStringAsFixed(2),
      GuaraniCurrency.format(item.payrollItem.overtimePay),
      GuaraniCurrency.format(item.payrollItem.ordinaryNightSurchargePay),
      GuaraniCurrency.format(item.payrollItem.advancesTotal),
      GuaraniCurrency.format(grossWithOtherIncome),
      GuaraniCurrency.format(item.payrollItem.familyBonus),
      GuaraniCurrency.format(item.payrollItem.ipsEmployee),
      GuaraniCurrency.format(item.payrollItem.attendanceDiscount),
      GuaraniCurrency.format(item.payrollItem.otherDiscount),
      item.payrollItem.embargoAmount == null
          ? '-'
          : GuaraniCurrency.format(item.payrollItem.embargoAmount!),
      GuaraniCurrency.format(item.payrollItem.netPay),
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
    var otherIncome = 0.0;
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
      grossPay += _grossWithOtherIncomeValues(
        payrollItem.grossPay,
        payrollItem.advancesTotal,
      );
      otherIncome += payrollItem.advancesTotal;
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
      otherIncome: otherIncome,
      familyBonus: familyBonus,
      ipsEmployee: ipsEmployee,
      attendanceDiscount: attendanceDiscount,
      netPay: netPay,
      otherDiscount: otherDiscount,
      embargoAmount: embargoAmount,
    );
  }

  DataRow _buildPayrollItemRow(PayrollItemView item) {
    final grossWithOtherIncome = _grossWithOtherIncomeValues(
      item.payrollItem.grossPay,
      item.payrollItem.advancesTotal,
    );
    return DataRow(
      selected: _selectedPayrollItemId == item.payrollItem.id,
      onSelectChanged: (_) => _activateEmployeeContext(item),
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (_selectedPayrollItemId == item.payrollItem.id) {
          return _selectedRowColor;
        }
        return null;
      }),
      cells: [
        DataCell(
          Text(
            item.employeeName,
            style: const TextStyle(
              color: _employeeNameColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
        DataCell(
          SizedBox(
            width: 110,
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  _activateEmployeeContext(item);
                }
              },
              child: TextField(
                controller: _otherIncomeControllers[item.payrollItem.id],
                enabled:
                    _canEditRows &&
                    !_savingOtherIncomeIds.contains(item.payrollItem.id),
                keyboardType: TextInputType.number,
                inputFormatters: const [ThousandsSeparatorInputFormatter()],
                decoration: const InputDecoration(
                  hintText: '0',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onTap: () => _activateEmployeeContext(item),
                onSubmitted: (_) => _saveOtherIncome(item),
              ),
            ),
          ),
        ),
        DataCell(Text(GuaraniCurrency.format(grossWithOtherIncome))),
        DataCell(Text(GuaraniCurrency.format(item.payrollItem.familyBonus))),
        DataCell(Text(GuaraniCurrency.format(item.payrollItem.ipsEmployee))),
        DataCell(
          Text(GuaraniCurrency.format(item.payrollItem.attendanceDiscount)),
        ),
        DataCell(
          SizedBox(
            width: 110,
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  _activateEmployeeContext(item);
                }
              },
              child: TextField(
                controller: _otherDiscountControllers[item.payrollItem.id],
                enabled:
                    _canEditRows &&
                    !_savingOtherDiscountIds.contains(item.payrollItem.id),
                keyboardType: TextInputType.number,
                inputFormatters: const [ThousandsSeparatorInputFormatter()],
                decoration: const InputDecoration(
                  hintText: '0',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onTap: () => _activateEmployeeContext(item),
                onSubmitted: (_) => _saveOtherDiscount(item),
              ),
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
        DataCell(Text(GuaraniCurrency.format(item.payrollItem.netPay))),
      ],
    );
  }

  String _buildReportBaseFileName() {
    final companyPart = _sanitizeFileNamePart(_normalizedCompanyName);
    final month = _selectedMonth.toString().padLeft(2, '0');
    return 'liquidacion_${companyPart}_${_selectedYear}_$month';
  }

  double _grossWithOtherIncomeValues(double grossPay, double otherIncome) {
    return grossPay + otherIncome;
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
    final visibleItems = _filteredItems();

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
              if (widget.canGeneratePayroll)
                FilledButton.icon(
                  onPressed: _canGenerate ? _generatePayroll : null,
                  icon: const Icon(Icons.calculate),
                  label: Text(
                    _isGenerating ? 'Generando...' : 'Generar liquidacion',
                  ),
                ),
              if (widget.canLockPayroll)
                FilledButton.icon(
                  onPressed: _canLock ? _lockPayroll : null,
                  icon: const Icon(Icons.lock),
                  label: Text(
                    _isLocking ? 'Guardando...' : 'Guardar liquidacion',
                  ),
                ),
              if (widget.canUnlockPayroll)
                OutlinedButton.icon(
                  onPressed: _canUnlock ? _unlockPayroll : null,
                  icon: const Icon(Icons.lock_open),
                  label: Text(
                    _isUnlocking
                        ? 'Desbloqueando...'
                        : 'Desbloquear liquidacion',
                  ),
                ),
              if (widget.canPrintPayroll) ...[
                OutlinedButton.icon(
                  onPressed: _canPrintReceipt ? _printDuplicateReceipt : null,
                  icon: const Icon(Icons.receipt_long),
                  label: Text(
                    _isPrintingReceipt
                        ? 'Imprimiendo boleta...'
                        : 'Boleta duplicado',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _canPrint ? _printPayroll : null,
                  icon: const Icon(Icons.print),
                  label: Text(_isPrinting ? 'Imprimiendo...' : 'Imprimir'),
                ),
              ],
              if (widget.canExportPayroll) ...[
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
                    _isExportingExcel
                        ? 'Exportando Excel...'
                        : 'Exportar Excel',
                  ),
                ),
              ],
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar empleado',
                    hintText: 'Nombre o apellido',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.trim().isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                  ),
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                avatar: Icon(
                  _isLocked ? Icons.lock : Icons.lock_open,
                  size: 18,
                ),
                label: Text(
                  _isLocked ? 'Liquidacion guardada' : 'Liquidacion editable',
                ),
              ),
              if (_isLocked && !widget.canUnlockPayroll)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: const Text(
                      'La liquidacion esta guardada. Solicite el desbloqueo al Administrador.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
          if (_activeEditingEmployeeName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Empleado activo: $_activeEditingEmployeeName',
              style: const TextStyle(
                color: _activeEmployeeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? Center(
                    child: Text(
                      _hasRun
                          ? 'Liquidacion generada sin items para este periodo.'
                          : 'No hay liquidacion generada.',
                    ),
                  )
                : visibleItems.isEmpty
                ? const Center(
                    child: Text(
                      'No hay coincidencias para el empleado buscado.',
                    ),
                  )
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
                              showCheckboxColumn: false,
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
                                DataColumn(label: Text('Otros Ingresos')),
                                DataColumn(label: Text('Bruto')),
                                DataColumn(label: Text('Bonif. familiar')),
                                DataColumn(label: Text('IPS empleado')),
                                DataColumn(label: Text('Descuentos')),
                                DataColumn(label: Text('Otros desc.')),
                                DataColumn(label: Text('Embargo')),
                                DataColumn(label: Text('Saldo')),
                              ],
                              rows: _buildRowsByDepartment(visibleItems),
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

class _UnlockPayrollDialog extends StatefulWidget {
  const _UnlockPayrollDialog();

  @override
  State<_UnlockPayrollDialog> createState() => _UnlockPayrollDialogState();
}

class _UnlockPayrollDialogState extends State<_UnlockPayrollDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Desbloquear liquidacion'),
      content: SizedBox(
        width: 360,
        child: TextField(
          controller: _passwordController,
          autofocus: true,
          obscureText: _obscureText,
          onSubmitted: (_) =>
              Navigator.of(context).pop(_passwordController.text),
          decoration: InputDecoration(
            labelText: 'Contrasena del usuario autorizado',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_passwordController.text);
          },
          child: const Text('Desbloquear'),
        ),
      ],
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
    required this.otherIncome,
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
  final double otherIncome;
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
    this.title = 'Vista previa de impresion',
    required this.fileName,
    required this.initialPageFormat,
    required this.buildPdf,
  });

  final String title;
  final String fileName;
  final PdfPageFormat initialPageFormat;
  final Future<Uint8List> Function(PdfPageFormat pageFormat) buildPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        pdfFileName: fileName,
        initialPageFormat: initialPageFormat,
        canChangeOrientation: false,
        canChangePageFormat: false,
        build: (format) => buildPdf(format),
      ),
    );
  }
}

