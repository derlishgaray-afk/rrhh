import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../data/database/app_database.dart';
import '../../../services/employee_name_formatter.dart';
import '../../../services/reports_service.dart';
import '../../utils/guarani_currency.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({
    required this.service,
    required this.companyId,
    required this.companyName,
    super.key,
  });

  final ReportsService service;
  final int companyId;
  final String companyName;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const int _allCompaniesValue = 0;

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

  ReportsPeriodSummary? _summary;
  List<Company> _companies = const [];
  List<Employee> _employees = const [];
  List<Department> _departments = const [];
  List<DepartmentSector> _sectors = const [];

  bool _isLoading = false;
  bool _isPrinting = false;
  bool _isExportingPdf = false;
  bool _isExportingXlsm = false;
  bool _isLoadingByCompanyReport = false;
  bool _isPrintingByCompanyReport = false;
  bool _isLoadingByDepartmentReport = false;
  bool _isPrintingByDepartmentReport = false;
  bool _isLoadingBySectorReport = false;
  bool _isPrintingBySectorReport = false;
  bool _isLoadingByEmployeeReport = false;
  bool _isPrintingByEmployeeReport = false;
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _companyReportStartDate;
  late DateTime _companyReportEndDate;
  late DateTime _departmentReportStartDate;
  late DateTime _departmentReportEndDate;
  late DateTime _sectorReportStartDate;
  late DateTime _sectorReportEndDate;
  late DateTime _employeeReportStartDate;
  late DateTime _employeeReportEndDate;
  int? _selectedCompanyId;
  int? _selectedEmployeeId;
  int? _selectedDepartmentId;
  int? _selectedSectorId;
  _ReportViewType _selectedReportView = _ReportViewType.monthly;
  bool _showReportsHome = true;
  List<_CompanyReportRow> _companyReportRows = const [];
  List<_DepartmentReportRow> _departmentReportRows = const [];
  List<_SectorReportRow> _sectorReportRows = const [];
  List<ReportsEmployeeSummary> _employeeReportRows = const [];
  final Map<String, ScrollController> _horizontalTableControllers =
      <String, ScrollController>{};
  final TextEditingController _employeeReportQueryController =
      TextEditingController();
  String _employeeReportQuery = '';

  bool get _isOutputBusy => _isPrinting || _isExportingPdf || _isExportingXlsm;
  bool get _isMonthlyReport => _selectedReportView == _ReportViewType.monthly;

  bool get _canOutput =>
      _isMonthlyReport &&
      !_isLoading &&
      !_isOutputBusy &&
      _summary != null &&
      _companies.isNotEmpty;

  bool get _canPrintByCompany =>
      !_isLoadingByCompanyReport &&
      !_isPrintingByCompanyReport &&
      _companyReportRows.isNotEmpty &&
      _companies.isNotEmpty;

  bool get _canPrintByDepartment =>
      !_isLoadingByDepartmentReport &&
      !_isPrintingByDepartmentReport &&
      _departmentReportRows.isNotEmpty &&
      _companies.isNotEmpty;

  bool get _canPrintBySector =>
      !_isLoadingBySectorReport &&
      !_isPrintingBySectorReport &&
      _sectorReportRows.isNotEmpty &&
      _companies.isNotEmpty;

  bool get _canPrintByEmployee =>
      !_isLoadingByEmployeeReport &&
      !_isPrintingByEmployeeReport &&
      _filteredEmployeeReportRows.isNotEmpty &&
      _companies.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month, now.day);
    _companyReportStartDate = DateTime(now.year, now.month, 1);
    _companyReportEndDate = DateTime(now.year, now.month, now.day);
    _departmentReportStartDate = DateTime(now.year, now.month, 1);
    _departmentReportEndDate = DateTime(now.year, now.month, now.day);
    _sectorReportStartDate = DateTime(now.year, now.month, 1);
    _sectorReportEndDate = DateTime(now.year, now.month, now.day);
    _employeeReportStartDate = DateTime(now.year, now.month, 1);
    _employeeReportEndDate = DateTime(now.year, now.month, now.day);
    _loadContextData(preferredCompanyId: widget.companyId);
  }

  @override
  void dispose() {
    for (final controller in _horizontalTableControllers.values) {
      controller.dispose();
    }
    _employeeReportQueryController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) {
      _loadContextData(preferredCompanyId: widget.companyId);
    }
  }

  Future<void> _loadContextData({
    int? preferredCompanyId,
    bool selectAllCompanies = false,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final companies = await widget.service.listReportCompanies();
      if (companies.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _companies = const [];
          _selectedCompanyId = null;
          _employees = const [];
          _departments = const [];
          _sectors = const [];
          _summary = null;
        });
        return;
      }

      var selectedCompanyId = _selectedCompanyId;
      if (selectAllCompanies) {
        selectedCompanyId = _allCompaniesValue;
      } else if (preferredCompanyId != null &&
          companies.any((company) => company.id == preferredCompanyId)) {
        selectedCompanyId = preferredCompanyId;
      }
      selectedCompanyId ??= companies.first.id;
      if (selectedCompanyId != _allCompaniesValue &&
          !companies.any((company) => company.id == selectedCompanyId)) {
        selectedCompanyId = companies.first.id;
      }

      final companyChanged = selectedCompanyId != _selectedCompanyId;
      if (companyChanged) {
        _selectedDepartmentId = null;
        _selectedSectorId = null;
        _selectedEmployeeId = null;
      }

      final selectedCompanyIds = selectedCompanyId == _allCompaniesValue
          ? companies.map((company) => company.id).toList()
          : <int>[selectedCompanyId];

      final filterData = selectedCompanyId == _allCompaniesValue
          ? await widget.service.getFilterDataForCompanies(
              companyIds: selectedCompanyIds,
            )
          : await widget.service.getFilterData(companyId: selectedCompanyId);

      final departments = filterData.departments.toList()
        ..sort((left, right) => left.name.compareTo(right.name));
      final sectors = filterData.sectors.toList()
        ..sort((left, right) => left.name.compareTo(right.name));
      final employees = filterData.employees.toList()
        ..sort(
          (left, right) => employeeDisplayName(
            left,
          ).toLowerCase().compareTo(employeeDisplayName(right).toLowerCase()),
        );

      _employees = employees;
      _departments = departments;
      _sectors = sectors;
      _selectedCompanyId = selectedCompanyId;
      _sanitizeSelections();

      final summary = selectedCompanyId == _allCompaniesValue
          ? await widget.service.getPeriodSummaryForCompanies(
              companyIds: selectedCompanyIds,
              startDate: _startDate,
              endDate: _endDate,
              employeeId: _selectedEmployeeId,
              departmentIds: _selectedDepartmentIds,
              sectorIds: _selectedSectorIds,
            )
          : await widget.service.getPeriodSummary(
              companyId: selectedCompanyId,
              startDate: _startDate,
              endDate: _endDate,
              employeeId: _selectedEmployeeId,
              departmentIds: _selectedDepartmentIds,
              sectorIds: _selectedSectorIds,
            );

      if (!mounted) {
        return;
      }
      setState(() {
        _companies = companies;
        _selectedCompanyId = selectedCompanyId;
        _employees = employees;
        _departments = departments;
        _sectors = sectors;
        _summary = summary;
      });
      if (!_showReportsHome) {
        if (_selectedReportView == _ReportViewType.byCompany) {
          _loadByCompanyReport();
        } else if (_selectedReportView == _ReportViewType.byDepartment) {
          _loadByDepartmentReport();
        } else if (_selectedReportView == _ReportViewType.bySector) {
          _loadBySectorReport();
        } else if (_selectedReportView == _ReportViewType.byEmployee) {
          _loadByEmployeeReport();
        }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('No se pudo cargar informes: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSummary() async {
    final selectedCompanyId = _selectedCompanyId;
    if (selectedCompanyId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedCompanyIds = selectedCompanyId == _allCompaniesValue
          ? _companies.map((company) => company.id).toList()
          : <int>[selectedCompanyId];
      final summary = selectedCompanyId == _allCompaniesValue
          ? await widget.service.getPeriodSummaryForCompanies(
              companyIds: selectedCompanyIds,
              startDate: _startDate,
              endDate: _endDate,
              employeeId: _selectedEmployeeId,
              departmentIds: _selectedDepartmentIds,
              sectorIds: _selectedSectorIds,
            )
          : await widget.service.getPeriodSummary(
              companyId: selectedCompanyId,
              startDate: _startDate,
              endDate: _endDate,
              employeeId: _selectedEmployeeId,
              departmentIds: _selectedDepartmentIds,
              sectorIds: _selectedSectorIds,
            );
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = summary;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('No se pudo cargar informes: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sanitizeSelections() {
    final availableDepartmentValues = _departmentOptions
        .map((item) => item.value)
        .toSet();
    if (_selectedDepartmentId != null &&
        !availableDepartmentValues.contains(_selectedDepartmentId)) {
      _selectedDepartmentId = null;
    }

    final availableSectorIds = _sectorOptions.map((item) => item.value).toSet();
    if (_selectedSectorId != null &&
        !availableSectorIds.contains(_selectedSectorId)) {
      _selectedSectorId = null;
    }

    final availableEmployeeIds = _availableEmployees
        .map((item) => item.id)
        .toSet();
    if (_selectedEmployeeId != null &&
        !availableEmployeeIds.contains(_selectedEmployeeId)) {
      _selectedEmployeeId = null;
    }
  }

  Set<int> get _selectedDepartmentIds {
    final selectedValue = _selectedDepartmentId;
    if (selectedValue == null) {
      return const <int>{};
    }
    for (final option in _departmentOptions) {
      if (option.value == selectedValue) {
        return option.ids;
      }
    }
    return const <int>{};
  }

  Set<int> get _selectedSectorIds {
    final selectedValue = _selectedSectorId;
    if (selectedValue == null) {
      return const <int>{};
    }
    for (final option in _sectorOptions) {
      if (option.value == selectedValue) {
        return option.ids;
      }
    }
    return const <int>{};
  }

  List<_FilterOptionGroup> get _departmentOptions {
    return _buildDepartmentOptionsFrom(_departments);
  }

  List<_FilterOptionGroup> _buildDepartmentOptionsFrom(
    List<Department> departments,
  ) {
    final groupedByKey = <String, _MutableFilterOptionGroup>{};
    for (final department in departments) {
      final label = department.name.trim();
      if (label.isEmpty) {
        continue;
      }
      final key = label.toLowerCase();
      final current = groupedByKey.putIfAbsent(
        key,
        () => _MutableFilterOptionGroup(label: label),
      );
      current.ids.add(department.id);
    }

    final options = groupedByKey.values
        .map(
          (item) => _FilterOptionGroup(
            value: item.ids.reduce(
              (left, right) => left < right ? left : right,
            ),
            label: item.label,
            ids: item.ids,
          ),
        )
        .toList();
    options.sort(
      (left, right) =>
          left.label.toLowerCase().compareTo(right.label.toLowerCase()),
    );
    return options;
  }

  List<_FilterOptionGroup> get _sectorOptions {
    return _buildSectorOptionsFrom(
      _sectors,
      departments: _departments,
      departmentIds: _selectedDepartmentIds,
    );
  }

  List<_FilterOptionGroup> _buildSectorOptionsFrom(
    List<DepartmentSector> sectors, {
    required List<Department> departments,
    required Set<int> departmentIds,
  }) {
    final departmentNameById = {
      for (final department in departments) department.id: department.name,
    };
    final groupedByKey = <String, _MutableFilterOptionGroup>{};

    for (final sector in sectors) {
      if (departmentIds.isNotEmpty &&
          !departmentIds.contains(sector.departmentId)) {
        continue;
      }

      final departmentName = (departmentNameById[sector.departmentId] ?? '')
          .trim();
      final sectorName = sector.name.trim();
      if (sectorName.isEmpty) {
        continue;
      }

      final showDepartmentPrefix = departmentIds.isEmpty;
      final label = showDepartmentPrefix && departmentName.isNotEmpty
          ? '$departmentName / $sectorName'
          : sectorName;
      final key = showDepartmentPrefix
          ? '${departmentName.toLowerCase()}|${sectorName.toLowerCase()}'
          : sectorName.toLowerCase();

      final current = groupedByKey.putIfAbsent(
        key,
        () => _MutableFilterOptionGroup(label: label),
      );
      current.ids.add(sector.id);
    }

    final options = groupedByKey.values
        .map(
          (item) => _FilterOptionGroup(
            value: item.ids.reduce(
              (left, right) => left < right ? left : right,
            ),
            label: item.label,
            ids: item.ids,
          ),
        )
        .toList();
    options.sort(
      (left, right) =>
          left.label.toLowerCase().compareTo(right.label.toLowerCase()),
    );
    return options;
  }

  List<Employee> get _availableEmployees {
    final departmentIds = _selectedDepartmentIds;
    final sectorIds = _selectedSectorIds;
    return _employees.where((employee) {
      if (departmentIds.isNotEmpty &&
          !departmentIds.contains(employee.departmentId)) {
        return false;
      }
      if (sectorIds.isNotEmpty && !sectorIds.contains(employee.sectorId)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<DateTime?> _showSpanishDatePicker({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      locale: const Locale('es', 'PY'),
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  void _clearEmployeeReportSearch() {
    if (_employeeReportQuery.trim().isEmpty) {
      return;
    }
    _employeeReportQueryController.clear();
    setState(() {
      _employeeReportQuery = '';
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _startDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day);
      if (_startDate.isAfter(_endDate)) {
        _endDate = _startDate;
      }
    });
    _loadSummary();
  }

  Future<void> _pickEndDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _endDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _endDate = DateTime(picked.year, picked.month, picked.day);
      if (_endDate.isBefore(_startDate)) {
        _startDate = _endDate;
      }
    });
    _loadSummary();
  }

  Future<void> _pickByCompanyStartDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _companyReportStartDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _companyReportStartDate = DateTime(picked.year, picked.month, picked.day);
      if (_companyReportStartDate.isAfter(_companyReportEndDate)) {
        _companyReportEndDate = _companyReportStartDate;
      }
    });
    _loadByCompanyReport();
  }

  Future<void> _pickByCompanyEndDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _companyReportEndDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _companyReportEndDate = DateTime(picked.year, picked.month, picked.day);
      if (_companyReportEndDate.isBefore(_companyReportStartDate)) {
        _companyReportStartDate = _companyReportEndDate;
      }
    });
    _loadByCompanyReport();
  }

  Future<void> _loadByCompanyReport() async {
    if (_companies.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _companyReportRows = const [];
      });
      return;
    }

    setState(() {
      _isLoadingByCompanyReport = true;
    });

    try {
      final rows = await Future.wait(
        _companies.map((company) async {
          final summary = await widget.service.getPeriodSummary(
            companyId: company.id,
            startDate: _companyReportStartDate,
            endDate: _companyReportEndDate,
          );
          final total = summary.payrollGrandTotal;
          return _CompanyReportRow(
            companyId: company.id,
            companyName: company.name,
            salaryBase: total.salaryBase,
            extraCompensation: total.extraCompensation,
            otherIncome: total.otherIncome,
            gross: total.gross,
            familyBonus: total.familyBonus,
            ipsEmployee: total.ipsEmployee,
            discounts: total.discounts,
            embargo: total.embargo,
            balance: total.balance,
          );
        }),
      );

      rows.sort(
        (left, right) => left.companyName.toLowerCase().compareTo(
          right.companyName.toLowerCase(),
        ),
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _companyReportRows = rows;
      });
    } catch (error) {
      _showError('No se pudo cargar el informe por empresas: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingByCompanyReport = false;
        });
      }
    }
  }

  Future<void> _pickByDepartmentStartDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _departmentReportStartDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _departmentReportStartDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
      );
      if (_departmentReportStartDate.isAfter(_departmentReportEndDate)) {
        _departmentReportEndDate = _departmentReportStartDate;
      }
    });
    _loadByDepartmentReport();
  }

  Future<void> _pickByDepartmentEndDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _departmentReportEndDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _departmentReportEndDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
      );
      if (_departmentReportEndDate.isBefore(_departmentReportStartDate)) {
        _departmentReportStartDate = _departmentReportEndDate;
      }
    });
    _loadByDepartmentReport();
  }

  Future<void> _loadByDepartmentReport() async {
    if (_companies.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _departmentReportRows = const [];
      });
      return;
    }

    setState(() {
      _isLoadingByDepartmentReport = true;
    });

    try {
      final companyIds = _companies.map((company) => company.id).toList();
      final filterData = await widget.service.getFilterDataForCompanies(
        companyIds: companyIds,
      );
      final departmentGroups = _buildDepartmentOptionsFrom(
        filterData.departments,
      );
      if (departmentGroups.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _departmentReportRows = const [];
        });
        return;
      }

      final rows = await Future.wait(
        departmentGroups.map((group) async {
          final summary = await widget.service.getPeriodSummaryForCompanies(
            companyIds: companyIds,
            startDate: _departmentReportStartDate,
            endDate: _departmentReportEndDate,
            departmentIds: group.ids,
          );
          final total = summary.payrollGrandTotal;
          return _DepartmentReportRow(
            departmentName: group.label,
            salaryBase: total.salaryBase,
            extraCompensation: total.extraCompensation,
            otherIncome: total.otherIncome,
            gross: total.gross,
            familyBonus: total.familyBonus,
            ipsEmployee: total.ipsEmployee,
            discounts: total.discounts,
            embargo: total.embargo,
            balance: total.balance,
          );
        }),
      );

      rows.sort(
        (left, right) => left.departmentName.toLowerCase().compareTo(
          right.departmentName.toLowerCase(),
        ),
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _departmentReportRows = rows;
      });
    } catch (error) {
      _showError('No se pudo cargar el informe por departamentos: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingByDepartmentReport = false;
        });
      }
    }
  }

  Future<void> _pickBySectorStartDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _sectorReportStartDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _sectorReportStartDate = DateTime(picked.year, picked.month, picked.day);
      if (_sectorReportStartDate.isAfter(_sectorReportEndDate)) {
        _sectorReportEndDate = _sectorReportStartDate;
      }
    });
    _loadBySectorReport();
  }

  Future<void> _pickBySectorEndDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _sectorReportEndDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _sectorReportEndDate = DateTime(picked.year, picked.month, picked.day);
      if (_sectorReportEndDate.isBefore(_sectorReportStartDate)) {
        _sectorReportStartDate = _sectorReportEndDate;
      }
    });
    _loadBySectorReport();
  }

  Future<void> _loadBySectorReport() async {
    if (_companies.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sectorReportRows = const [];
      });
      return;
    }

    setState(() {
      _isLoadingBySectorReport = true;
    });

    try {
      final companyIds = _companies.map((company) => company.id).toList();
      final filterData = await widget.service.getFilterDataForCompanies(
        companyIds: companyIds,
      );
      final sectorGroups = _buildSectorOptionsFrom(
        filterData.sectors,
        departments: filterData.departments,
        departmentIds: const <int>{},
      );
      if (sectorGroups.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _sectorReportRows = const [];
        });
        return;
      }

      final rows = await Future.wait(
        sectorGroups.map((group) async {
          final summary = await widget.service.getPeriodSummaryForCompanies(
            companyIds: companyIds,
            startDate: _sectorReportStartDate,
            endDate: _sectorReportEndDate,
            sectorIds: group.ids,
          );
          final total = summary.payrollGrandTotal;
          return _SectorReportRow(
            sectorName: group.label,
            salaryBase: total.salaryBase,
            extraCompensation: total.extraCompensation,
            otherIncome: total.otherIncome,
            gross: total.gross,
            familyBonus: total.familyBonus,
            ipsEmployee: total.ipsEmployee,
            discounts: total.discounts,
            embargo: total.embargo,
            balance: total.balance,
          );
        }),
      );

      rows.sort(
        (left, right) => left.sectorName.toLowerCase().compareTo(
          right.sectorName.toLowerCase(),
        ),
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _sectorReportRows = rows;
      });
    } catch (error) {
      _showError('No se pudo cargar el informe por sectores: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBySectorReport = false;
        });
      }
    }
  }

  Future<void> _pickByEmployeeStartDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _employeeReportStartDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _employeeReportStartDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
      );
      if (_employeeReportStartDate.isAfter(_employeeReportEndDate)) {
        _employeeReportEndDate = _employeeReportStartDate;
      }
    });
    _loadByEmployeeReport();
  }

  Future<void> _pickByEmployeeEndDate() async {
    final picked = await _showSpanishDatePicker(
      initialDate: _employeeReportEndDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2200, 12, 31),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _employeeReportEndDate = DateTime(picked.year, picked.month, picked.day);
      if (_employeeReportEndDate.isBefore(_employeeReportStartDate)) {
        _employeeReportStartDate = _employeeReportEndDate;
      }
    });
    _loadByEmployeeReport();
  }

  Future<void> _loadByEmployeeReport() async {
    if (_companies.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _employeeReportRows = const [];
      });
      return;
    }

    setState(() {
      _isLoadingByEmployeeReport = true;
    });

    try {
      final companyIds = _companies.map((company) => company.id).toList();
      final rows = await widget.service.getEmployeeSummaryForCompanies(
        companyIds: companyIds,
        startDate: _employeeReportStartDate,
        endDate: _employeeReportEndDate,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _employeeReportRows = rows;
      });
    } catch (error) {
      _showError('No se pudo cargar el informe por empleados: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingByEmployeeReport = false;
        });
      }
    }
  }

  void _resetFilters() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month, now.day);
      _selectedEmployeeId = null;
      _selectedDepartmentId = null;
      _selectedSectorId = null;
    });
    _loadSummary();
  }

  Future<void> _openEmployeePicker(List<Employee> availableEmployees) async {
    final searchController = TextEditingController();
    var query = '';

    try {
      final result = await showDialog<_EmployeePickerResult>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final normalizedQuery = query.trim().toLowerCase();
              final filteredEmployees = availableEmployees.where((employee) {
                if (normalizedQuery.isEmpty) {
                  return true;
                }
                final name = employeeDisplayName(employee).toLowerCase();
                final document = employee.documentNumber.toLowerCase();
                return name.contains(normalizedQuery) ||
                    document.contains(normalizedQuery);
              }).toList();

              return AlertDialog(
                title: const Text('Seleccionar empleado'),
                content: SizedBox(
                  width: 520,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: searchController,
                        autofocus: true,
                        onChanged: (value) {
                          setDialogState(() {
                            query = value;
                          });
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Buscar por nombre o documento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Resultados: ${filteredEmployees.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 360),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              dense: true,
                              leading: Icon(
                                _selectedEmployeeId == null
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                              ),
                              title: const Text('Todos los empleados'),
                              onTap: () {
                                Navigator.of(context).pop(
                                  const _EmployeePickerResult(confirmed: true),
                                );
                              },
                            ),
                            if (filteredEmployees.isEmpty)
                              const ListTile(
                                dense: true,
                                title: Text('Sin resultados'),
                              )
                            else
                              ...filteredEmployees.map((employee) {
                                final isSelected =
                                    _selectedEmployeeId == employee.id;
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                  ),
                                  title: Text(employeeDisplayName(employee)),
                                  subtitle: Text(
                                    'Doc: ${employee.documentNumber}',
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop(
                                      _EmployeePickerResult(
                                        confirmed: true,
                                        employeeId: employee.id,
                                      ),
                                    );
                                  },
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(const _EmployeePickerResult(confirmed: false));
                    },
                    child: const Text('Cancelar'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted || result == null || !result.confirmed) {
        return;
      }

      setState(() {
        _selectedEmployeeId = result.employeeId;
      });
      _loadSummary();
    } finally {
      searchController.dispose();
    }
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  String _monthLabel(int year, int month) {
    if (month < 1 || month > 12) {
      return '$month/$year';
    }
    return '${_monthNames[month - 1]} $year';
  }

  String _companyLabel(int? companyId) {
    if (companyId == null) {
      return widget.companyName;
    }
    if (companyId == _allCompaniesValue) {
      return 'Todas las empresas';
    }
    for (final company in _companies) {
      if (company.id == companyId) {
        return company.name;
      }
    }
    return widget.companyName;
  }

  String _departmentLabel(int? departmentId) {
    if (departmentId == null) {
      return 'Todos los departamentos';
    }
    for (final option in _departmentOptions) {
      if (option.value == departmentId) {
        return option.label;
      }
    }
    return 'Departamento';
  }

  String _sectorLabel(int? sectorId) {
    if (sectorId == null) {
      return 'Todos los sectores';
    }
    for (final option in _sectorOptions) {
      if (option.value == sectorId) {
        return option.label;
      }
    }
    return 'Sector';
  }

  String _employeeLabel(int? employeeId) {
    if (employeeId == null) {
      return 'Todos los empleados';
    }
    for (final employee in _employees) {
      if (employee.id == employeeId) {
        return employeeDisplayName(employee);
      }
    }
    return 'Empleado';
  }

  TextStyle _totalRowCellTextStyle() {
    return TextStyle(fontWeight: FontWeight.w700, color: Colors.red.shade700);
  }

  TextStyle _primaryDimensionCellTextStyle() {
    return TextStyle(fontWeight: FontWeight.w700, color: Colors.blue.shade800);
  }

  TextStyle? _dimensionCellTextStyle({required bool isTotal}) {
    if (isTotal) {
      return _totalRowCellTextStyle();
    }
    return _primaryDimensionCellTextStyle();
  }

  TextStyle? _amountCellTextStyle({
    required bool isTotal,
    bool emphasize = false,
  }) {
    if (isTotal) {
      return _totalRowCellTextStyle();
    }
    if (emphasize) {
      return const TextStyle(fontWeight: FontWeight.w700);
    }
    return null;
  }

  pw.TextStyle _buildPdfCellTextStyle({
    required int columnIndex,
    required int rowNum,
    required int dataLength,
    required int primaryColumnIndex,
    required int grossColumnIndex,
    required int balanceColumnIndex,
  }) {
    const baseStyle = pw.TextStyle(fontSize: 7);
    if (rowNum <= 0) {
      return baseStyle;
    }

    final dataIndex = rowNum - 1;
    final isTotalRow = dataIndex == dataLength - 1;
    if (isTotalRow) {
      return pw.TextStyle(
        fontSize: 7,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.red900,
      );
    }

    if (columnIndex == primaryColumnIndex) {
      return pw.TextStyle(
        fontSize: 7,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
      );
    }

    if (columnIndex == grossColumnIndex || columnIndex == balanceColumnIndex) {
      return pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold);
    }

    return baseStyle;
  }

  Widget _buildScrollableDataTable({
    required String tableId,
    required List<DataColumn> columns,
    required List<DataRow> rows,
  }) {
    final controller = _horizontalTableControllers.putIfAbsent(
      tableId,
      ScrollController.new,
    );

    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      interactive: true,
      trackVisibility: true,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          if (!controller.hasClients) {
            return;
          }
          final target = (controller.offset - details.delta.dx).clamp(
            0.0,
            controller.position.maxScrollExtent,
          );
          controller.jumpTo(target);
        },
        child: SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          child: DataTable(columnSpacing: 18, columns: columns, rows: rows),
        ),
      ),
    );
  }

  DataRow _buildPlanillaRow(
    ReportsPayrollMonthlySubtotal subtotal, {
    required bool isTotal,
  }) {
    final primaryStyle = _dimensionCellTextStyle(isTotal: isTotal);
    final monthText = isTotal
        ? 'TOTAL GENERAL'
        : _monthLabel(subtotal.year, subtotal.month);
    final missingLockedPayroll = !isTotal && !subtotal.hasLockedPayroll;

    if (missingLockedPayroll) {
      final messageStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.orange.shade900,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
      );

      return DataRow(
        cells: [
          DataCell(Text(monthText, style: primaryStyle)),
          DataCell(
            Text(
              subtotal.rowMessage ?? 'Sin liquidacion guardada',
              style: messageStyle,
            ),
          ),
          const DataCell(Text('-')),
          const DataCell(Text('-')),
          const DataCell(Text('-')),
          const DataCell(Text('-')),
          const DataCell(Text('-')),
          const DataCell(Text('-')),
          const DataCell(Text('-')),
          const DataCell(Text('-')),
        ],
      );
    }

    return DataRow(
      cells: [
        DataCell(Text(monthText, style: primaryStyle)),
        DataCell(
          Text(
            GuaraniCurrency.format(subtotal.salaryBase),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(subtotal.extraCompensation),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(subtotal.otherIncome),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(subtotal.gross),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(subtotal.familyBonus),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(subtotal.ipsEmployee),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(subtotal.discounts),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(subtotal.embargo),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(subtotal.balance),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
      ],
    );
  }

  List<List<String>> _buildPlanillaExportRows(ReportsPeriodSummary summary) {
    final rows = <List<String>>[];
    for (final subtotal in summary.payrollMonthlySubtotals) {
      final monthText = _monthLabel(subtotal.year, subtotal.month);
      if (!subtotal.hasLockedPayroll) {
        rows.add([
          monthText,
          subtotal.rowMessage ?? 'Sin liquidacion guardada',
          '-',
          '-',
          '-',
          '-',
          '-',
          '-',
          '-',
          '-',
        ]);
        continue;
      }
      rows.add([
        monthText,
        GuaraniCurrency.format(subtotal.salaryBase),
        GuaraniCurrency.format(subtotal.extraCompensation),
        GuaraniCurrency.format(subtotal.otherIncome),
        GuaraniCurrency.format(subtotal.gross),
        GuaraniCurrency.format(subtotal.familyBonus),
        GuaraniCurrency.format(subtotal.ipsEmployee),
        GuaraniCurrency.format(subtotal.discounts),
        GuaraniCurrency.format(subtotal.embargo),
        GuaraniCurrency.format(subtotal.balance),
      ]);
    }

    final total = summary.payrollGrandTotal;
    rows.add([
      'TOTAL GENERAL',
      GuaraniCurrency.format(total.salaryBase),
      GuaraniCurrency.format(total.extraCompensation),
      GuaraniCurrency.format(total.otherIncome),
      GuaraniCurrency.format(total.gross),
      GuaraniCurrency.format(total.familyBonus),
      GuaraniCurrency.format(total.ipsEmployee),
      GuaraniCurrency.format(total.discounts),
      GuaraniCurrency.format(total.embargo),
      GuaraniCurrency.format(total.balance),
    ]);

    return rows;
  }

  _CompanyReportRow _buildByCompanyGrandTotal() {
    var salaryBase = 0.0;
    var extraCompensation = 0.0;
    var otherIncome = 0.0;
    var gross = 0.0;
    var familyBonus = 0.0;
    var ipsEmployee = 0.0;
    var discounts = 0.0;
    var embargo = 0.0;
    var balance = 0.0;

    for (final row in _companyReportRows) {
      salaryBase += row.salaryBase;
      extraCompensation += row.extraCompensation;
      otherIncome += row.otherIncome;
      gross += row.gross;
      familyBonus += row.familyBonus;
      ipsEmployee += row.ipsEmployee;
      discounts += row.discounts;
      embargo += row.embargo;
      balance += row.balance;
    }

    return _CompanyReportRow(
      companyId: 0,
      companyName: 'TOTAL GENERAL',
      salaryBase: salaryBase,
      extraCompensation: extraCompensation,
      otherIncome: otherIncome,
      gross: gross,
      familyBonus: familyBonus,
      ipsEmployee: ipsEmployee,
      discounts: discounts,
      embargo: embargo,
      balance: balance,
    );
  }

  DataRow _buildByCompanyDataRow(
    _CompanyReportRow row, {
    required bool isTotal,
  }) {
    final primaryStyle = _dimensionCellTextStyle(isTotal: isTotal);

    return DataRow(
      cells: [
        DataCell(Text(row.companyName, style: primaryStyle)),
        DataCell(
          Text(
            GuaraniCurrency.format(row.salaryBase),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.extraCompensation),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.otherIncome),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.gross),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.familyBonus),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.ipsEmployee),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.discounts),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.embargo),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.balance),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
      ],
    );
  }

  List<List<String>> _buildByCompanyExportRows() {
    final rows = _companyReportRows
        .map(
          (row) => <String>[
            row.companyName,
            GuaraniCurrency.format(row.salaryBase),
            GuaraniCurrency.format(row.extraCompensation),
            GuaraniCurrency.format(row.otherIncome),
            GuaraniCurrency.format(row.gross),
            GuaraniCurrency.format(row.familyBonus),
            GuaraniCurrency.format(row.ipsEmployee),
            GuaraniCurrency.format(row.discounts),
            GuaraniCurrency.format(row.embargo),
            GuaraniCurrency.format(row.balance),
          ],
        )
        .toList();

    if (_companyReportRows.isNotEmpty) {
      final total = _buildByCompanyGrandTotal();
      rows.add([
        total.companyName,
        GuaraniCurrency.format(total.salaryBase),
        GuaraniCurrency.format(total.extraCompensation),
        GuaraniCurrency.format(total.otherIncome),
        GuaraniCurrency.format(total.gross),
        GuaraniCurrency.format(total.familyBonus),
        GuaraniCurrency.format(total.ipsEmployee),
        GuaraniCurrency.format(total.discounts),
        GuaraniCurrency.format(total.embargo),
        GuaraniCurrency.format(total.balance),
      ]);
    }

    return rows;
  }

  Future<Uint8List> _buildByCompanyReportPdfBytes({
    PdfPageFormat? pageFormat,
  }) async {
    if (_companyReportRows.isEmpty) {
      throw StateError('No hay datos para imprimir.');
    }

    final headers = const <String>[
      'Empresa',
      'Salario Base',
      'Gs. Extras',
      'Otros Ingresos',
      'Bruto',
      'Bonif. Familiar',
      'IPS Empleado',
      'Gs. Descuentos',
      'Embargo',
      'Saldo',
    ];
    final data = _buildByCompanyExportRows();
    final document = pw.Document();
    final effectivePageFormat = pageFormat ?? PdfPageFormat.a4.landscape;

    document.addPage(
      pw.MultiPage(
        pageFormat: effectivePageFormat,
        margin: const pw.EdgeInsets.fromLTRB(14, 16, 14, 16),
        build: (_) => [
          pw.Text(
            'Informe por Empresas',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Periodo: ${_formatDate(_companyReportStartDate)} - ${_formatDate(_companyReportEndDate)}',
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            textStyleBuilder: (columnIndex, _, rowNum) {
              return _buildPdfCellTextStyle(
                columnIndex: columnIndex,
                rowNum: rowNum,
                dataLength: data.length,
                primaryColumnIndex: 0,
                grossColumnIndex: 4,
                balanceColumnIndex: 9,
              );
            },
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
          ),
        ],
      ),
    );

    return document.save();
  }

  _DepartmentReportRow _buildByDepartmentGrandTotal() {
    var salaryBase = 0.0;
    var extraCompensation = 0.0;
    var otherIncome = 0.0;
    var gross = 0.0;
    var familyBonus = 0.0;
    var ipsEmployee = 0.0;
    var discounts = 0.0;
    var embargo = 0.0;
    var balance = 0.0;

    for (final row in _departmentReportRows) {
      salaryBase += row.salaryBase;
      extraCompensation += row.extraCompensation;
      otherIncome += row.otherIncome;
      gross += row.gross;
      familyBonus += row.familyBonus;
      ipsEmployee += row.ipsEmployee;
      discounts += row.discounts;
      embargo += row.embargo;
      balance += row.balance;
    }

    return _DepartmentReportRow(
      departmentName: 'TOTAL GENERAL',
      salaryBase: salaryBase,
      extraCompensation: extraCompensation,
      otherIncome: otherIncome,
      gross: gross,
      familyBonus: familyBonus,
      ipsEmployee: ipsEmployee,
      discounts: discounts,
      embargo: embargo,
      balance: balance,
    );
  }

  DataRow _buildByDepartmentDataRow(
    _DepartmentReportRow row, {
    required bool isTotal,
  }) {
    final primaryStyle = _dimensionCellTextStyle(isTotal: isTotal);

    return DataRow(
      cells: [
        DataCell(Text(row.departmentName, style: primaryStyle)),
        DataCell(
          Text(
            GuaraniCurrency.format(row.salaryBase),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.extraCompensation),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.otherIncome),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.gross),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.familyBonus),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.ipsEmployee),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.discounts),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.embargo),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.balance),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
      ],
    );
  }

  List<List<String>> _buildByDepartmentExportRows() {
    final rows = _departmentReportRows
        .map(
          (row) => <String>[
            row.departmentName,
            GuaraniCurrency.format(row.salaryBase),
            GuaraniCurrency.format(row.extraCompensation),
            GuaraniCurrency.format(row.otherIncome),
            GuaraniCurrency.format(row.gross),
            GuaraniCurrency.format(row.familyBonus),
            GuaraniCurrency.format(row.ipsEmployee),
            GuaraniCurrency.format(row.discounts),
            GuaraniCurrency.format(row.embargo),
            GuaraniCurrency.format(row.balance),
          ],
        )
        .toList();

    if (_departmentReportRows.isNotEmpty) {
      final total = _buildByDepartmentGrandTotal();
      rows.add([
        total.departmentName,
        GuaraniCurrency.format(total.salaryBase),
        GuaraniCurrency.format(total.extraCompensation),
        GuaraniCurrency.format(total.otherIncome),
        GuaraniCurrency.format(total.gross),
        GuaraniCurrency.format(total.familyBonus),
        GuaraniCurrency.format(total.ipsEmployee),
        GuaraniCurrency.format(total.discounts),
        GuaraniCurrency.format(total.embargo),
        GuaraniCurrency.format(total.balance),
      ]);
    }

    return rows;
  }

  Future<Uint8List> _buildByDepartmentReportPdfBytes({
    PdfPageFormat? pageFormat,
  }) async {
    if (_departmentReportRows.isEmpty) {
      throw StateError('No hay datos para imprimir.');
    }

    final headers = const <String>[
      'Departamento',
      'Salario Base',
      'Gs. Extras',
      'Otros Ingresos',
      'Bruto',
      'Bonif. Familiar',
      'IPS Empleado',
      'Gs. Descuentos',
      'Embargo',
      'Saldo',
    ];
    final data = _buildByDepartmentExportRows();
    final document = pw.Document();
    final effectivePageFormat = pageFormat ?? PdfPageFormat.a4.landscape;

    document.addPage(
      pw.MultiPage(
        pageFormat: effectivePageFormat,
        margin: const pw.EdgeInsets.fromLTRB(14, 16, 14, 16),
        build: (_) => [
          pw.Text(
            'Informe por Departamentos',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Periodo: ${_formatDate(_departmentReportStartDate)} - ${_formatDate(_departmentReportEndDate)}',
          ),
          pw.Text(
            'Alcance: Todas las empresas de la holding',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            textStyleBuilder: (columnIndex, _, rowNum) {
              return _buildPdfCellTextStyle(
                columnIndex: columnIndex,
                rowNum: rowNum,
                dataLength: data.length,
                primaryColumnIndex: 0,
                grossColumnIndex: 4,
                balanceColumnIndex: 9,
              );
            },
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
          ),
        ],
      ),
    );

    return document.save();
  }

  _SectorReportRow _buildBySectorGrandTotal() {
    var salaryBase = 0.0;
    var extraCompensation = 0.0;
    var otherIncome = 0.0;
    var gross = 0.0;
    var familyBonus = 0.0;
    var ipsEmployee = 0.0;
    var discounts = 0.0;
    var embargo = 0.0;
    var balance = 0.0;

    for (final row in _sectorReportRows) {
      salaryBase += row.salaryBase;
      extraCompensation += row.extraCompensation;
      otherIncome += row.otherIncome;
      gross += row.gross;
      familyBonus += row.familyBonus;
      ipsEmployee += row.ipsEmployee;
      discounts += row.discounts;
      embargo += row.embargo;
      balance += row.balance;
    }

    return _SectorReportRow(
      sectorName: 'TOTAL GENERAL',
      salaryBase: salaryBase,
      extraCompensation: extraCompensation,
      otherIncome: otherIncome,
      gross: gross,
      familyBonus: familyBonus,
      ipsEmployee: ipsEmployee,
      discounts: discounts,
      embargo: embargo,
      balance: balance,
    );
  }

  DataRow _buildBySectorDataRow(_SectorReportRow row, {required bool isTotal}) {
    final primaryStyle = _dimensionCellTextStyle(isTotal: isTotal);

    return DataRow(
      cells: [
        DataCell(Text(row.sectorName, style: primaryStyle)),
        DataCell(
          Text(
            GuaraniCurrency.format(row.salaryBase),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.extraCompensation),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.otherIncome),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.gross),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.familyBonus),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.ipsEmployee),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.discounts),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.embargo),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.balance),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
      ],
    );
  }

  List<List<String>> _buildBySectorExportRows() {
    final rows = _sectorReportRows
        .map(
          (row) => <String>[
            row.sectorName,
            GuaraniCurrency.format(row.salaryBase),
            GuaraniCurrency.format(row.extraCompensation),
            GuaraniCurrency.format(row.otherIncome),
            GuaraniCurrency.format(row.gross),
            GuaraniCurrency.format(row.familyBonus),
            GuaraniCurrency.format(row.ipsEmployee),
            GuaraniCurrency.format(row.discounts),
            GuaraniCurrency.format(row.embargo),
            GuaraniCurrency.format(row.balance),
          ],
        )
        .toList();

    if (_sectorReportRows.isNotEmpty) {
      final total = _buildBySectorGrandTotal();
      rows.add([
        total.sectorName,
        GuaraniCurrency.format(total.salaryBase),
        GuaraniCurrency.format(total.extraCompensation),
        GuaraniCurrency.format(total.otherIncome),
        GuaraniCurrency.format(total.gross),
        GuaraniCurrency.format(total.familyBonus),
        GuaraniCurrency.format(total.ipsEmployee),
        GuaraniCurrency.format(total.discounts),
        GuaraniCurrency.format(total.embargo),
        GuaraniCurrency.format(total.balance),
      ]);
    }

    return rows;
  }

  Future<Uint8List> _buildBySectorReportPdfBytes({
    PdfPageFormat? pageFormat,
  }) async {
    if (_sectorReportRows.isEmpty) {
      throw StateError('No hay datos para imprimir.');
    }

    final headers = const <String>[
      'Sector',
      'Salario Base',
      'Gs. Extras',
      'Otros Ingresos',
      'Bruto',
      'Bonif. Familiar',
      'IPS Empleado',
      'Gs. Descuentos',
      'Embargo',
      'Saldo',
    ];
    final data = _buildBySectorExportRows();
    final document = pw.Document();
    final effectivePageFormat = pageFormat ?? PdfPageFormat.a4.landscape;

    document.addPage(
      pw.MultiPage(
        pageFormat: effectivePageFormat,
        margin: const pw.EdgeInsets.fromLTRB(14, 16, 14, 16),
        build: (_) => [
          pw.Text(
            'Informe por Sectores',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Periodo: ${_formatDate(_sectorReportStartDate)} - ${_formatDate(_sectorReportEndDate)}',
          ),
          pw.Text(
            'Alcance: Todas las empresas de la holding',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            textStyleBuilder: (columnIndex, _, rowNum) {
              return _buildPdfCellTextStyle(
                columnIndex: columnIndex,
                rowNum: rowNum,
                dataLength: data.length,
                primaryColumnIndex: 0,
                grossColumnIndex: 4,
                balanceColumnIndex: 9,
              );
            },
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
          ),
        ],
      ),
    );

    return document.save();
  }

  ReportsEmployeeSummary _buildByEmployeeGrandTotal(
    List<ReportsEmployeeSummary> rows,
  ) {
    var salaryBase = 0.0;
    var extraCompensation = 0.0;
    var otherIncome = 0.0;
    var gross = 0.0;
    var familyBonus = 0.0;
    var ipsEmployee = 0.0;
    var discounts = 0.0;
    var embargo = 0.0;
    var balance = 0.0;

    for (final row in rows) {
      salaryBase += row.salaryBase;
      extraCompensation += row.extraCompensation;
      otherIncome += row.otherIncome;
      gross += row.gross;
      familyBonus += row.familyBonus;
      ipsEmployee += row.ipsEmployee;
      discounts += row.discounts;
      embargo += row.embargo;
      balance += row.balance;
    }

    return ReportsEmployeeSummary(
      employeeId: 0,
      employeeName: 'TOTAL GENERAL',
      documentNumber: '',
      companyId: 0,
      companyName: '-',
      salaryBase: salaryBase,
      extraCompensation: extraCompensation,
      otherIncome: otherIncome,
      gross: gross,
      familyBonus: familyBonus,
      ipsEmployee: ipsEmployee,
      discounts: discounts,
      embargo: embargo,
      balance: balance,
    );
  }

  DataRow _buildByEmployeeDataRow(
    ReportsEmployeeSummary row, {
    required bool isTotal,
  }) {
    final primaryStyle = _dimensionCellTextStyle(isTotal: isTotal);
    return DataRow(
      cells: [
        DataCell(Text(row.employeeName, style: primaryStyle)),
        DataCell(
          Text(row.companyName, style: _amountCellTextStyle(isTotal: isTotal)),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.salaryBase),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.extraCompensation),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.otherIncome),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.gross),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.familyBonus),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.ipsEmployee),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.discounts),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.embargo),
            style: _amountCellTextStyle(isTotal: isTotal),
          ),
        ),
        DataCell(
          Text(
            GuaraniCurrency.format(row.balance),
            style: _amountCellTextStyle(isTotal: isTotal, emphasize: true),
          ),
        ),
      ],
    );
  }

  List<List<String>> _buildByEmployeeExportRows(
    List<ReportsEmployeeSummary> rows,
  ) {
    final data = rows
        .map(
          (row) => <String>[
            row.employeeName,
            row.companyName,
            GuaraniCurrency.format(row.salaryBase),
            GuaraniCurrency.format(row.extraCompensation),
            GuaraniCurrency.format(row.otherIncome),
            GuaraniCurrency.format(row.gross),
            GuaraniCurrency.format(row.familyBonus),
            GuaraniCurrency.format(row.ipsEmployee),
            GuaraniCurrency.format(row.discounts),
            GuaraniCurrency.format(row.embargo),
            GuaraniCurrency.format(row.balance),
          ],
        )
        .toList();
    if (rows.isNotEmpty) {
      final total = _buildByEmployeeGrandTotal(rows);
      data.add([
        total.employeeName,
        total.companyName,
        GuaraniCurrency.format(total.salaryBase),
        GuaraniCurrency.format(total.extraCompensation),
        GuaraniCurrency.format(total.otherIncome),
        GuaraniCurrency.format(total.gross),
        GuaraniCurrency.format(total.familyBonus),
        GuaraniCurrency.format(total.ipsEmployee),
        GuaraniCurrency.format(total.discounts),
        GuaraniCurrency.format(total.embargo),
        GuaraniCurrency.format(total.balance),
      ]);
    }
    return data;
  }

  Future<Uint8List> _buildByEmployeeReportPdfBytes({
    PdfPageFormat? pageFormat,
    required List<ReportsEmployeeSummary> rows,
  }) async {
    if (rows.isEmpty) {
      throw StateError('No hay datos para imprimir.');
    }
    final headers = const <String>[
      'Nombre',
      'Empresa',
      'Salario Base',
      'Gs. Extras',
      'Otros Ingresos',
      'Bruto',
      'Bonif. Familiar',
      'IPS Empleado',
      'Gs. Descuentos',
      'Embargo',
      'Saldo',
    ];
    final data = _buildByEmployeeExportRows(rows);
    final document = pw.Document();
    final effectivePageFormat = pageFormat ?? PdfPageFormat.a4.landscape;

    document.addPage(
      pw.MultiPage(
        pageFormat: effectivePageFormat,
        margin: const pw.EdgeInsets.fromLTRB(14, 16, 14, 16),
        build: (_) => [
          pw.Text(
            'Informe por Empleados',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Periodo: ${_formatDate(_employeeReportStartDate)} - ${_formatDate(_employeeReportEndDate)}',
          ),
          pw.Text(
            'Alcance: Todas las empresas de la holding',
            style: const pw.TextStyle(fontSize: 9),
          ),
          if (_employeeReportQuery.trim().isNotEmpty)
            pw.Text(
              'Busqueda: ${_employeeReportQuery.trim()}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            textStyleBuilder: (columnIndex, _, rowNum) {
              return _buildPdfCellTextStyle(
                columnIndex: columnIndex,
                rowNum: rowNum,
                dataLength: data.length,
                primaryColumnIndex: 0,
                grossColumnIndex: 5,
                balanceColumnIndex: 10,
              );
            },
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
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<Uint8List> _buildReportPdfBytes({PdfPageFormat? pageFormat}) async {
    final summary = _summary;
    if (summary == null) {
      throw StateError('No hay datos para exportar.');
    }

    final headers = const <String>[
      'Mes',
      'Salario Base',
      'Gs. Extras',
      'Otros Ingresos',
      'Bruto',
      'Bonif. Familiar',
      'IPS Empleado',
      'Gs. Descuentos',
      'Embargo',
      'Saldo',
    ];
    final data = _buildPlanillaExportRows(summary);
    final document = pw.Document();
    final effectivePageFormat = pageFormat ?? PdfPageFormat.a4.landscape;

    document.addPage(
      pw.MultiPage(
        pageFormat: effectivePageFormat,
        margin: const pw.EdgeInsets.fromLTRB(14, 16, 14, 16),
        build: (_) => [
          pw.Text(
            'Informe de Planilla por Mes',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Periodo: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
          ),
          pw.Text('Empresa: ${_companyLabel(_selectedCompanyId)}'),
          pw.Text(
            'Departamento: ${_departmentLabel(_selectedDepartmentId)} | Sector: ${_sectorLabel(_selectedSectorId)} | Empleado: ${_employeeLabel(_selectedEmployeeId)}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 7),
            textStyleBuilder: (columnIndex, _, rowNum) {
              return _buildPdfCellTextStyle(
                columnIndex: columnIndex,
                rowNum: rowNum,
                dataLength: data.length,
                primaryColumnIndex: 0,
                grossColumnIndex: 4,
                balanceColumnIndex: 9,
              );
            },
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
          ),
        ],
      ),
    );

    return document.save();
  }

  Uint8List _buildReportExcelBytes() {
    final summary = _summary;
    if (summary == null) {
      throw StateError('No hay datos para exportar.');
    }

    final workbook = xl.Excel.createExcel();
    const sheetName = 'Informes';
    final defaultSheet = workbook.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetName) {
      workbook.rename(defaultSheet, sheetName);
    }
    final sheet = workbook[sheetName];

    var rowIndex = 0;
    void writeRow(List<String> values) {
      for (var col = 0; col < values.length; col++) {
        final cell = xl.CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: rowIndex,
        );
        sheet.cell(cell).value = xl.TextCellValue(values[col]);
      }
      rowIndex += 1;
    }

    writeRow(const ['INFORME DE PLANILLA POR MES']);
    rowIndex += 1;
    writeRow([
      'Periodo',
      '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
    ]);
    writeRow(['Empresa', _companyLabel(_selectedCompanyId)]);
    writeRow(['Departamento', _departmentLabel(_selectedDepartmentId)]);
    writeRow(['Sector', _sectorLabel(_selectedSectorId)]);
    writeRow(['Empleado', _employeeLabel(_selectedEmployeeId)]);
    rowIndex += 1;
    writeRow(const [
      'Mes',
      'Salario Base',
      'Gs. Extras',
      'Otros Ingresos',
      'Bruto',
      'Bonif. Familiar',
      'IPS Empleado',
      'Gs. Descuentos',
      'Embargo',
      'Saldo',
    ]);
    for (final row in _buildPlanillaExportRows(summary)) {
      writeRow(row);
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw StateError('No se pudo generar el archivo XLSM.');
    }
    return Uint8List.fromList(bytes);
  }

  Future<void> _printReport() async {
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
          builder: (_) => _ReportsPrintPreviewScreen(
            fileName: '${_buildReportBaseFileName()}.pdf',
            initialPageFormat: PdfPageFormat.a4.landscape,
            buildPdf: (format) => _buildReportPdfBytes(pageFormat: format),
          ),
        ),
      );
    } catch (error) {
      _showError('No se pudo imprimir el informe: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  Future<void> _printByCompanyReport() async {
    if (!_canPrintByCompany) {
      return;
    }
    setState(() {
      _isPrintingByCompanyReport = true;
    });
    try {
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ReportsPrintPreviewScreen(
            fileName:
                'informe_empresas_${_formatDate(_companyReportStartDate).replaceAll('/', '')}_${_formatDate(_companyReportEndDate).replaceAll('/', '')}.pdf',
            initialPageFormat: PdfPageFormat.a4.landscape,
            buildPdf: (format) =>
                _buildByCompanyReportPdfBytes(pageFormat: format),
          ),
        ),
      );
    } catch (error) {
      _showError('No se pudo imprimir el informe por empresas: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPrintingByCompanyReport = false;
        });
      }
    }
  }

  Future<void> _printByDepartmentReport() async {
    if (!_canPrintByDepartment) {
      return;
    }
    setState(() {
      _isPrintingByDepartmentReport = true;
    });
    try {
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ReportsPrintPreviewScreen(
            fileName:
                'informe_departamentos_${_formatDate(_departmentReportStartDate).replaceAll('/', '')}_${_formatDate(_departmentReportEndDate).replaceAll('/', '')}.pdf',
            initialPageFormat: PdfPageFormat.a4.landscape,
            buildPdf: (format) =>
                _buildByDepartmentReportPdfBytes(pageFormat: format),
          ),
        ),
      );
    } catch (error) {
      _showError('No se pudo imprimir el informe por departamentos: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPrintingByDepartmentReport = false;
        });
      }
    }
  }

  Future<void> _printBySectorReport() async {
    if (!_canPrintBySector) {
      return;
    }
    setState(() {
      _isPrintingBySectorReport = true;
    });
    try {
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ReportsPrintPreviewScreen(
            fileName:
                'informe_sectores_${_formatDate(_sectorReportStartDate).replaceAll('/', '')}_${_formatDate(_sectorReportEndDate).replaceAll('/', '')}.pdf',
            initialPageFormat: PdfPageFormat.a4.landscape,
            buildPdf: (format) =>
                _buildBySectorReportPdfBytes(pageFormat: format),
          ),
        ),
      );
    } catch (error) {
      _showError('No se pudo imprimir el informe por sectores: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPrintingBySectorReport = false;
        });
      }
    }
  }

  Future<void> _printByEmployeeReport() async {
    if (!_canPrintByEmployee) {
      return;
    }
    final rows = _filteredEmployeeReportRows;
    setState(() {
      _isPrintingByEmployeeReport = true;
    });
    try {
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ReportsPrintPreviewScreen(
            fileName:
                'informe_empleados_${_formatDate(_employeeReportStartDate).replaceAll('/', '')}_${_formatDate(_employeeReportEndDate).replaceAll('/', '')}.pdf',
            initialPageFormat: PdfPageFormat.a4.landscape,
            buildPdf: (format) =>
                _buildByEmployeeReportPdfBytes(pageFormat: format, rows: rows),
          ),
        ),
      );
    } catch (error) {
      _showError('No se pudo imprimir el informe por empleados: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPrintingByEmployeeReport = false;
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
      final bytes = await _buildReportPdfBytes();
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar informe en PDF',
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

  Future<void> _exportXlsm() async {
    if (!_canOutput) {
      return;
    }
    setState(() {
      _isExportingXlsm = true;
    });
    try {
      final bytes = _buildReportExcelBytes();
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar informe en XLSM',
        fileName: '${_buildReportBaseFileName()}.xlsm',
        type: FileType.custom,
        allowedExtensions: const ['xlsm', 'xlsx', 'xlms'],
      );
      if (savePath == null || savePath.trim().isEmpty) {
        return;
      }
      var resolvedPath = savePath;
      final lower = resolvedPath.toLowerCase();
      if (!lower.endsWith('.xlsm') &&
          !lower.endsWith('.xlsx') &&
          !lower.endsWith('.xlms')) {
        resolvedPath = '$resolvedPath.xlsm';
      }
      await File(resolvedPath).writeAsBytes(bytes, flush: true);
      _showInfo('XLSM exportado correctamente.');
    } catch (error) {
      _showError('No se pudo exportar XLSM: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isExportingXlsm = false;
        });
      }
    }
  }

  String _buildReportBaseFileName() {
    final companyPart = _sanitizeFileNamePart(
      _companyLabel(_selectedCompanyId),
    );
    final fromPart = _formatDate(_startDate).replaceAll('/', '');
    final toPart = _formatDate(_endDate).replaceAll('/', '');
    return 'informes_planilla_${companyPart}_${fromPart}_$toPart';
  }

  String _sanitizeFileNamePart(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
  }

  String _ensureExtension(String path, String extension) {
    if (path.toLowerCase().endsWith(extension.toLowerCase())) {
      return path;
    }
    return '$path$extension';
  }

  List<_ReportViewOption> get _reportViewOptions => const [
    _ReportViewOption(
      type: _ReportViewType.monthly,
      title: 'Informe Mensual',
      subtitle: 'Resumen por mes y total general.',
      icon: Icons.calendar_month,
    ),
    _ReportViewOption(
      type: _ReportViewType.byCompany,
      title: 'Informe por Empresas',
      subtitle: 'Comparativo por empresa.',
      icon: Icons.business,
    ),
    _ReportViewOption(
      type: _ReportViewType.byDepartment,
      title: 'Informe por Departamentos',
      subtitle: 'Consolidado por departamento.',
      icon: Icons.apartment,
    ),
    _ReportViewOption(
      type: _ReportViewType.bySector,
      title: 'Informe por Sectores',
      subtitle: 'Consolidado por sector.',
      icon: Icons.account_tree,
    ),
    _ReportViewOption(
      type: _ReportViewType.byEmployee,
      title: 'Informe por Empleados',
      subtitle: 'Consolidado por empleado.',
      icon: Icons.badge,
    ),
  ];

  Widget _buildReportTypeCard(_ReportViewOption option) {
    final isSelected = _selectedReportView == option.type;
    final scheme = Theme.of(context).colorScheme;
    final selectedBackground = scheme.primary.withValues(alpha: 0.08);
    final selectedBorder = scheme.primary;
    final idleBorder = scheme.outline.withValues(alpha: 0.45);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _openReportView(option.type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? selectedBorder : idleBorder),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: isSelected
                  ? scheme.primary
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? scheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _pendingReportMessage() {
    switch (_selectedReportView) {
      case _ReportViewType.byDepartment:
        return '';
      case _ReportViewType.bySector:
        return '';
      case _ReportViewType.byEmployee:
        return '';
      case _ReportViewType.byCompany:
      case _ReportViewType.monthly:
        return '';
    }
  }

  void _openReportView(_ReportViewType type) {
    setState(() {
      _selectedReportView = type;
      _showReportsHome = false;
    });
    if (type == _ReportViewType.byCompany) {
      _loadByCompanyReport();
    } else if (type == _ReportViewType.byDepartment) {
      _loadByDepartmentReport();
    } else if (type == _ReportViewType.bySector) {
      _loadBySectorReport();
    } else if (type == _ReportViewType.byEmployee) {
      _loadByEmployeeReport();
    }
  }

  void _goToReportsHome() {
    setState(() {
      _showReportsHome = true;
    });
  }

  String _reportTitle(_ReportViewType type) {
    for (final option in _reportViewOptions) {
      if (option.type == type) {
        return option.title;
      }
    }
    return 'Informes';
  }

  List<ReportsEmployeeSummary> get _filteredEmployeeReportRows {
    final query = _employeeReportQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _employeeReportRows;
    }
    return _employeeReportRows.where((row) {
      final name = row.employeeName.toLowerCase();
      final document = row.documentNumber.toLowerCase();
      final company = row.companyName.toLowerCase();
      return name.contains(query) ||
          document.contains(query) ||
          company.contains(query);
    }).toList();
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
    final summary = _summary;
    final selectedCompanyId = _selectedCompanyId;
    final departmentOptions = _departmentOptions;
    final sectorOptions = _sectorOptions;
    final availableEmployees = _availableEmployees;
    final planillaRows = <DataRow>[];
    final byCompanyRows = <DataRow>[];
    final byDepartmentRows = <DataRow>[];
    final bySectorRows = <DataRow>[];
    final filteredEmployeeRows = _filteredEmployeeReportRows;
    final byEmployeeRows = <DataRow>[];
    if (summary != null) {
      for (final monthly in summary.payrollMonthlySubtotals) {
        planillaRows.add(_buildPlanillaRow(monthly, isTotal: false));
      }
      planillaRows.add(
        _buildPlanillaRow(summary.payrollGrandTotal, isTotal: true),
      );
    }
    if (_companyReportRows.isNotEmpty) {
      for (final row in _companyReportRows) {
        byCompanyRows.add(_buildByCompanyDataRow(row, isTotal: false));
      }
      byCompanyRows.add(
        _buildByCompanyDataRow(_buildByCompanyGrandTotal(), isTotal: true),
      );
    }
    if (_departmentReportRows.isNotEmpty) {
      for (final row in _departmentReportRows) {
        byDepartmentRows.add(_buildByDepartmentDataRow(row, isTotal: false));
      }
      byDepartmentRows.add(
        _buildByDepartmentDataRow(
          _buildByDepartmentGrandTotal(),
          isTotal: true,
        ),
      );
    }
    if (_sectorReportRows.isNotEmpty) {
      for (final row in _sectorReportRows) {
        bySectorRows.add(_buildBySectorDataRow(row, isTotal: false));
      }
      bySectorRows.add(
        _buildBySectorDataRow(_buildBySectorGrandTotal(), isTotal: true),
      );
    }
    if (filteredEmployeeRows.isNotEmpty) {
      for (final row in filteredEmployeeRows) {
        byEmployeeRows.add(_buildByEmployeeDataRow(row, isTotal: false));
      }
      byEmployeeRows.add(
        _buildByEmployeeDataRow(
          _buildByEmployeeGrandTotal(filteredEmployeeRows),
          isTotal: true,
        ),
      );
    }

    if (_showReportsHome) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipos de informe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _reportViewOptions
                          .map((option) => _buildReportTypeCard(option))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ] else if (_companies.isEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No tiene empresas con permiso para Informes.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: _goToReportsHome,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
              const SizedBox(width: 8),
              Text(
                _reportTitle(_selectedReportView),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (_isMonthlyReport) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros del informe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 300,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Empresa',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value:
                                    (selectedCompanyId != null &&
                                        (selectedCompanyId ==
                                                _allCompaniesValue ||
                                            _companies.any(
                                              (company) =>
                                                  company.id ==
                                                  selectedCompanyId,
                                            )))
                                    ? selectedCompanyId
                                    : null,
                                hint: const Text('Seleccionar empresa'),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: _allCompaniesValue,
                                    child: Text('Todas las empresas'),
                                  ),
                                  ..._companies.map(
                                    (company) => DropdownMenuItem<int>(
                                      value: company.id,
                                      child: Text(company.name),
                                    ),
                                  ),
                                ],
                                onChanged: _isLoading
                                    ? null
                                    : (value) {
                                        if (value == null ||
                                            value == _selectedCompanyId) {
                                          return;
                                        }
                                        setState(() {
                                          _selectedCompanyId = value;
                                          _selectedDepartmentId = null;
                                          _selectedSectorId = null;
                                          _selectedEmployeeId = null;
                                        });
                                        _loadContextData(
                                          preferredCompanyId:
                                              value == _allCompaniesValue
                                              ? null
                                              : value,
                                          selectAllCompanies:
                                              value == _allCompaniesValue,
                                        );
                                      },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Departamento',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int?>(
                                isExpanded: true,
                                value: _selectedDepartmentId,
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('Todos los departamentos'),
                                  ),
                                  ...departmentOptions.map(
                                    (option) => DropdownMenuItem<int?>(
                                      value: option.value,
                                      child: Text(option.label),
                                    ),
                                  ),
                                ],
                                onChanged: _isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedDepartmentId = value;
                                          _sanitizeSelections();
                                        });
                                        _loadSummary();
                                      },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Sector',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int?>(
                                isExpanded: true,
                                value: _selectedSectorId,
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('Todos los sectores'),
                                  ),
                                  ...sectorOptions.map(
                                    (option) => DropdownMenuItem<int?>(
                                      value: option.value,
                                      child: Text(option.label),
                                    ),
                                  ),
                                ],
                                onChanged: _isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedSectorId = value;
                                          _sanitizeSelections();
                                        });
                                        _loadSummary();
                                      },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 320,
                          child: InkWell(
                            onTap: _isLoading
                                ? null
                                : () => _openEmployeePicker(availableEmployees),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Empleado',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _employeeLabel(_selectedEmployeeId),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_selectedEmployeeId != null &&
                                      !_isLoading)
                                    IconButton(
                                      tooltip: 'Limpiar empleado',
                                      constraints: const BoxConstraints(
                                        minHeight: 20,
                                        minWidth: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        setState(() {
                                          _selectedEmployeeId = null;
                                        });
                                        _loadSummary();
                                      },
                                      icon: const Icon(Icons.clear, size: 18),
                                    ),
                                  const Icon(Icons.search, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _pickStartDate,
                          icon: const Icon(Icons.event),
                          label: Text('Desde: ${_formatDate(_startDate)}'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _pickEndDate,
                          icon: const Icon(Icons.event_available),
                          label: Text('Hasta: ${_formatDate(_endDate)}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _resetFilters,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpiar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _loadContextData(
                                  preferredCompanyId:
                                      _selectedCompanyId == _allCompaniesValue
                                      ? null
                                      : _selectedCompanyId,
                                  selectAllCompanies:
                                      _selectedCompanyId == _allCompaniesValue,
                                ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Recargar catalogos'),
                        ),
                        if (_isMonthlyReport) ...[
                          OutlinedButton.icon(
                            onPressed: _canOutput ? _printReport : null,
                            icon: const Icon(Icons.print),
                            label: Text(
                              _isPrinting ? 'Imprimiendo...' : 'Imprimir',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _canOutput ? _exportPdf : null,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: Text(
                              _isExportingPdf
                                  ? 'Exportando PDF...'
                                  : 'Exportar PDF',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _canOutput ? _exportXlsm : null,
                            icon: const Icon(Icons.table_view),
                            label: Text(
                              _isExportingXlsm
                                  ? 'Exportando XLSM...'
                                  : 'Exportar XLSM',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Periodo: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Empresa: ${_companyLabel(_selectedCompanyId)} | Departamento: ${_departmentLabel(_selectedDepartmentId)} | Sector: ${_sectorLabel(_selectedSectorId)} | Empleado: ${_employeeLabel(_selectedEmployeeId)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (_selectedReportView == _ReportViewType.byCompany) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros del informe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isLoadingByCompanyReport
                              ? null
                              : _pickByCompanyStartDate,
                          icon: const Icon(Icons.event),
                          label: Text(
                            'Desde: ${_formatDate(_companyReportStartDate)}',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isLoadingByCompanyReport
                              ? null
                              : _pickByCompanyEndDate,
                          icon: const Icon(Icons.event_available),
                          label: Text(
                            'Hasta: ${_formatDate(_companyReportEndDate)}',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _canPrintByCompany
                              ? _printByCompanyReport
                              : null,
                          icon: const Icon(Icons.print),
                          label: Text(
                            _isPrintingByCompanyReport
                                ? 'Imprimiendo...'
                                : 'Imprimir',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Periodo: ${_formatDate(_companyReportStartDate)} - ${_formatDate(_companyReportEndDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
          if (_selectedReportView == _ReportViewType.byDepartment) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros del informe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isLoadingByDepartmentReport
                              ? null
                              : _pickByDepartmentStartDate,
                          icon: const Icon(Icons.event),
                          label: Text(
                            'Desde: ${_formatDate(_departmentReportStartDate)}',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isLoadingByDepartmentReport
                              ? null
                              : _pickByDepartmentEndDate,
                          icon: const Icon(Icons.event_available),
                          label: Text(
                            'Hasta: ${_formatDate(_departmentReportEndDate)}',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _canPrintByDepartment
                              ? _printByDepartmentReport
                              : null,
                          icon: const Icon(Icons.print),
                          label: Text(
                            _isPrintingByDepartmentReport
                                ? 'Imprimiendo...'
                                : 'Imprimir',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Periodo: ${_formatDate(_departmentReportStartDate)} - ${_formatDate(_departmentReportEndDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Alcance: todas las empresas de la holding.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (_selectedReportView == _ReportViewType.bySector) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros del informe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isLoadingBySectorReport
                              ? null
                              : _pickBySectorStartDate,
                          icon: const Icon(Icons.event),
                          label: Text(
                            'Desde: ${_formatDate(_sectorReportStartDate)}',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isLoadingBySectorReport
                              ? null
                              : _pickBySectorEndDate,
                          icon: const Icon(Icons.event_available),
                          label: Text(
                            'Hasta: ${_formatDate(_sectorReportEndDate)}',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _canPrintBySector
                              ? _printBySectorReport
                              : null,
                          icon: const Icon(Icons.print),
                          label: Text(
                            _isPrintingBySectorReport
                                ? 'Imprimiendo...'
                                : 'Imprimir',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Periodo: ${_formatDate(_sectorReportStartDate)} - ${_formatDate(_sectorReportEndDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Alcance: todas las empresas de la holding.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (_selectedReportView == _ReportViewType.byEmployee) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros del informe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isLoadingByEmployeeReport
                              ? null
                              : _pickByEmployeeStartDate,
                          icon: const Icon(Icons.event),
                          label: Text(
                            'Desde: ${_formatDate(_employeeReportStartDate)}',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isLoadingByEmployeeReport
                              ? null
                              : _pickByEmployeeEndDate,
                          icon: const Icon(Icons.event_available),
                          label: Text(
                            'Hasta: ${_formatDate(_employeeReportEndDate)}',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _canPrintByEmployee
                              ? _printByEmployeeReport
                              : null,
                          icon: const Icon(Icons.print),
                          label: Text(
                            _isPrintingByEmployeeReport
                                ? 'Imprimiendo...'
                                : 'Imprimir',
                          ),
                        ),
                        SizedBox(
                          width: 360,
                          child: TextField(
                            controller: _employeeReportQueryController,
                            enabled: !_isLoadingByEmployeeReport,
                            onChanged: (value) {
                              setState(() {
                                _employeeReportQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText:
                                  'Buscar por nombre, empresa o documento',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _employeeReportQuery.trim().isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Limpiar búsqueda',
                                      onPressed: _isLoadingByEmployeeReport
                                          ? null
                                          : _clearEmployeeReportSearch,
                                      icon: const Icon(Icons.close),
                                    ),
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              _isLoadingByEmployeeReport ||
                                  _employeeReportQuery.trim().isEmpty
                              ? null
                              : _clearEmployeeReportSearch,
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar búsqueda'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Periodo: ${_formatDate(_employeeReportStartDate)} - ${_formatDate(_employeeReportEndDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Alcance: todas las empresas de la holding.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          if (_companies.isEmpty && !_isLoading)
            Expanded(
              child: Center(
                child: Text(
                  'No tiene empresas con permiso para Informes.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          else
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedReportView == _ReportViewType.byCompany
                  ? _isLoadingByCompanyReport
                        ? const Center(child: CircularProgressIndicator())
                        : byCompanyRows.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin datos para el informe por empresas.',
                            ),
                          )
                        : ListView(
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Resumen por empresas (${_companyReportRows.length} empresa(s))',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildScrollableDataTable(
                                        tableId: 'by_company',
                                        columns: const [
                                          DataColumn(label: Text('Empresa')),
                                          DataColumn(
                                            label: Text('Salario Base'),
                                          ),
                                          DataColumn(label: Text('Gs. Extras')),
                                          DataColumn(
                                            label: Text('Otros Ingresos'),
                                          ),
                                          DataColumn(label: Text('Bruto')),
                                          DataColumn(
                                            label: Text('Bonif. Familiar'),
                                          ),
                                          DataColumn(
                                            label: Text('IPS Empleado'),
                                          ),
                                          DataColumn(
                                            label: Text('Gs. Descuentos'),
                                          ),
                                          DataColumn(label: Text('Embargo')),
                                          DataColumn(label: Text('Saldo')),
                                        ],
                                        rows: byCompanyRows,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                  : _selectedReportView == _ReportViewType.byDepartment
                  ? _isLoadingByDepartmentReport
                        ? const Center(child: CircularProgressIndicator())
                        : byDepartmentRows.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin datos para el informe por departamentos.',
                            ),
                          )
                        : ListView(
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Resumen por departamentos de todas las empresas (${_departmentReportRows.length} departamento(s))',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildScrollableDataTable(
                                        tableId: 'by_department',
                                        columns: const [
                                          DataColumn(
                                            label: Text('Departamento'),
                                          ),
                                          DataColumn(
                                            label: Text('Salario Base'),
                                          ),
                                          DataColumn(label: Text('Gs. Extras')),
                                          DataColumn(
                                            label: Text('Otros Ingresos'),
                                          ),
                                          DataColumn(label: Text('Bruto')),
                                          DataColumn(
                                            label: Text('Bonif. Familiar'),
                                          ),
                                          DataColumn(
                                            label: Text('IPS Empleado'),
                                          ),
                                          DataColumn(
                                            label: Text('Gs. Descuentos'),
                                          ),
                                          DataColumn(label: Text('Embargo')),
                                          DataColumn(label: Text('Saldo')),
                                        ],
                                        rows: byDepartmentRows,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                  : _selectedReportView == _ReportViewType.bySector
                  ? _isLoadingBySectorReport
                        ? const Center(child: CircularProgressIndicator())
                        : bySectorRows.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin datos para el informe por sectores.',
                            ),
                          )
                        : ListView(
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Resumen por sectores de todas las empresas (${_sectorReportRows.length} sector(es))',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildScrollableDataTable(
                                        tableId: 'by_sector',
                                        columns: const [
                                          DataColumn(label: Text('Sector')),
                                          DataColumn(
                                            label: Text('Salario Base'),
                                          ),
                                          DataColumn(label: Text('Gs. Extras')),
                                          DataColumn(
                                            label: Text('Otros Ingresos'),
                                          ),
                                          DataColumn(label: Text('Bruto')),
                                          DataColumn(
                                            label: Text('Bonif. Familiar'),
                                          ),
                                          DataColumn(
                                            label: Text('IPS Empleado'),
                                          ),
                                          DataColumn(
                                            label: Text('Gs. Descuentos'),
                                          ),
                                          DataColumn(label: Text('Embargo')),
                                          DataColumn(label: Text('Saldo')),
                                        ],
                                        rows: bySectorRows,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                  : _selectedReportView == _ReportViewType.byEmployee
                  ? _isLoadingByEmployeeReport
                        ? const Center(child: CircularProgressIndicator())
                        : byEmployeeRows.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin datos para el informe por empleados.',
                            ),
                          )
                        : ListView(
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Resumen por empleados de todas las empresas (${filteredEmployeeRows.length} empleado(s))',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildScrollableDataTable(
                                        tableId: 'by_employee',
                                        columns: const [
                                          DataColumn(label: Text('Nombre')),
                                          DataColumn(label: Text('Empresa')),
                                          DataColumn(
                                            label: Text('Salario Base'),
                                          ),
                                          DataColumn(label: Text('Gs. Extras')),
                                          DataColumn(
                                            label: Text('Otros Ingresos'),
                                          ),
                                          DataColumn(label: Text('Bruto')),
                                          DataColumn(
                                            label: Text('Bonif. Familiar'),
                                          ),
                                          DataColumn(
                                            label: Text('IPS Empleado'),
                                          ),
                                          DataColumn(
                                            label: Text('Gs. Descuentos'),
                                          ),
                                          DataColumn(label: Text('Embargo')),
                                          DataColumn(label: Text('Saldo')),
                                        ],
                                        rows: byEmployeeRows,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                  : !_isMonthlyReport
                  ? ListView(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _pendingReportMessage(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ],
                    )
                  : summary == null
                  ? const Center(child: Text('Sin datos de informes.'))
                  : ListView(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Planilla de resumen con subtotales por mes (${summary.payrollMonthsConsidered} mes(es))',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (summary.payrollMonthlySubtotals.isEmpty)
                                  const Text(
                                    'No hay meses en el rango seleccionado.',
                                  )
                                else
                                  _buildScrollableDataTable(
                                    tableId: 'monthly',
                                    columns: const [
                                      DataColumn(label: Text('Mes')),
                                      DataColumn(label: Text('Salario Base')),
                                      DataColumn(label: Text('Gs. Extras')),
                                      DataColumn(label: Text('Otros Ingresos')),
                                      DataColumn(label: Text('Bruto')),
                                      DataColumn(
                                        label: Text('Bonif. Familiar'),
                                      ),
                                      DataColumn(label: Text('IPS Empleado')),
                                      DataColumn(label: Text('Gs. Descuentos')),
                                      DataColumn(label: Text('Embargo')),
                                      DataColumn(label: Text('Saldo')),
                                    ],
                                    rows: planillaRows,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

class _CompanyReportRow {
  const _CompanyReportRow({
    required this.companyId,
    required this.companyName,
    required this.salaryBase,
    required this.extraCompensation,
    required this.otherIncome,
    required this.gross,
    required this.familyBonus,
    required this.ipsEmployee,
    required this.discounts,
    required this.embargo,
    required this.balance,
  });

  final int companyId;
  final String companyName;
  final double salaryBase;
  final double extraCompensation;
  final double otherIncome;
  final double gross;
  final double familyBonus;
  final double ipsEmployee;
  final double discounts;
  final double embargo;
  final double balance;
}

class _DepartmentReportRow {
  const _DepartmentReportRow({
    required this.departmentName,
    required this.salaryBase,
    required this.extraCompensation,
    required this.otherIncome,
    required this.gross,
    required this.familyBonus,
    required this.ipsEmployee,
    required this.discounts,
    required this.embargo,
    required this.balance,
  });

  final String departmentName;
  final double salaryBase;
  final double extraCompensation;
  final double otherIncome;
  final double gross;
  final double familyBonus;
  final double ipsEmployee;
  final double discounts;
  final double embargo;
  final double balance;
}

class _SectorReportRow {
  const _SectorReportRow({
    required this.sectorName,
    required this.salaryBase,
    required this.extraCompensation,
    required this.otherIncome,
    required this.gross,
    required this.familyBonus,
    required this.ipsEmployee,
    required this.discounts,
    required this.embargo,
    required this.balance,
  });

  final String sectorName;
  final double salaryBase;
  final double extraCompensation;
  final double otherIncome;
  final double gross;
  final double familyBonus;
  final double ipsEmployee;
  final double discounts;
  final double embargo;
  final double balance;
}

enum _ReportViewType { monthly, byCompany, byDepartment, bySector, byEmployee }

class _ReportViewOption {
  const _ReportViewOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final _ReportViewType type;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _EmployeePickerResult {
  const _EmployeePickerResult({required this.confirmed, this.employeeId});

  final bool confirmed;
  final int? employeeId;
}

class _FilterOptionGroup {
  const _FilterOptionGroup({
    required this.value,
    required this.label,
    required this.ids,
  });

  final int value;
  final String label;
  final Set<int> ids;
}

class _MutableFilterOptionGroup {
  _MutableFilterOptionGroup({required this.label});

  final String label;
  final Set<int> ids = <int>{};
}

class _ReportsPrintPreviewScreen extends StatelessWidget {
  const _ReportsPrintPreviewScreen({
    required this.fileName,
    required this.initialPageFormat,
    required this.buildPdf,
  });

  final String fileName;
  final PdfPageFormat initialPageFormat;
  final Future<Uint8List> Function(PdfPageFormat pageFormat) buildPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa de impresion')),
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
