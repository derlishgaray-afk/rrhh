import '../data/database/app_database.dart';
import '../security/security_constants.dart';
import 'authorization_service.dart';

class ReportsFilterData {
  const ReportsFilterData({
    required this.employees,
    required this.departments,
    required this.sectors,
  });

  final List<Employee> employees;
  final List<Department> departments;
  final List<DepartmentSector> sectors;
}

class ReportsPayrollMonthlySubtotal {
  const ReportsPayrollMonthlySubtotal({
    required this.year,
    required this.month,
    required this.hasLockedPayroll,
    required this.rowMessage,
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

  final int year;
  final int month;
  final bool hasLockedPayroll;
  final String? rowMessage;
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

class ReportsPeriodSummary {
  const ReportsPeriodSummary({
    required this.companyId,
    required this.startDate,
    required this.endDate,
    required this.totalEmployees,
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.attendanceRecords,
    required this.totalWorkedHours,
    required this.totalOvertimeHours,
    required this.attendanceByEventType,
    required this.payrollMonthsConsidered,
    required this.payrollRunsCount,
    required this.payrollLockedRunsCount,
    required this.payrollLastGeneratedAt,
    required this.payrollEmployees,
    required this.payrollGrossTotal,
    required this.payrollNetTotal,
    required this.payrollIpsTotal,
    required this.payrollAttendanceDiscountTotal,
    required this.payrollOtherDiscountTotal,
    required this.payrollEmbargoTotal,
    required this.payrollMonthlySubtotals,
    required this.payrollGrandTotal,
  });

  final int companyId;
  final DateTime startDate;
  final DateTime endDate;

  final int totalEmployees;
  final int activeEmployees;
  final int inactiveEmployees;

  final int attendanceRecords;
  final double totalWorkedHours;
  final double totalOvertimeHours;
  final Map<String, int> attendanceByEventType;

  final int payrollMonthsConsidered;
  final int payrollRunsCount;
  final int payrollLockedRunsCount;
  final DateTime? payrollLastGeneratedAt;
  final int payrollEmployees;
  final double payrollGrossTotal;
  final double payrollNetTotal;
  final double payrollIpsTotal;
  final double payrollAttendanceDiscountTotal;
  final double payrollOtherDiscountTotal;
  final double payrollEmbargoTotal;
  final List<ReportsPayrollMonthlySubtotal> payrollMonthlySubtotals;
  final ReportsPayrollMonthlySubtotal payrollGrandTotal;

  bool get hasPayrollRuns => payrollRunsCount > 0;

  double get payrollTotalDiscounts =>
      payrollIpsTotal +
      payrollAttendanceDiscountTotal +
      payrollOtherDiscountTotal +
      payrollEmbargoTotal;
}

class ReportsEmployeeSummary {
  const ReportsEmployeeSummary({
    required this.employeeId,
    required this.employeeName,
    required this.documentNumber,
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

  final int employeeId;
  final String employeeName;
  final String documentNumber;
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

class ReportsService {
  ReportsService(
    this._employeesDao,
    this._departmentsDao,
    this._attendanceDao,
    this._payrollDao,
    this._authorizationService,
  );

  final EmployeesDao _employeesDao;
  final DepartmentsDao _departmentsDao;
  final AttendanceDao _attendanceDao;
  final PayrollDao _payrollDao;
  final AuthorizationService _authorizationService;

  Future<List<Company>> listReportCompanies() async {
    final accessibleCompanies = await _authorizationService
        .listAccessibleCompanies();
    if (accessibleCompanies.isEmpty) {
      return const [];
    }

    final reportCompanies = <Company>[];
    for (final company in accessibleCompanies) {
      final canReadReports = await _authorizationService.hasPermission(
        PermissionKeys.reportsRead,
        companyId: company.id,
      );
      if (canReadReports) {
        reportCompanies.add(company);
      }
    }

    reportCompanies.sort(
      (left, right) =>
          left.name.toLowerCase().compareTo(right.name.toLowerCase()),
    );
    return reportCompanies;
  }

  Future<ReportsFilterData> getFilterDataForCompanies({
    required List<int> companyIds,
  }) async {
    final normalizedCompanyIds =
        companyIds.where((id) => id > 0).toSet().toList()..sort();
    if (normalizedCompanyIds.isEmpty) {
      return const ReportsFilterData(
        employees: [],
        departments: [],
        sectors: [],
      );
    }

    final employeesById = <int, Employee>{};
    final departmentsById = <int, Department>{};
    final sectorsById = <int, DepartmentSector>{};

    for (final companyId in normalizedCompanyIds) {
      final filterData = await getFilterData(companyId: companyId);
      for (final employee in filterData.employees) {
        employeesById[employee.id] = employee;
      }
      for (final department in filterData.departments) {
        departmentsById[department.id] = department;
      }
      for (final sector in filterData.sectors) {
        sectorsById[sector.id] = sector;
      }
    }

    return ReportsFilterData(
      employees: employeesById.values.toList(),
      departments: departmentsById.values.toList(),
      sectors: sectorsById.values.toList(),
    );
  }

  Future<ReportsFilterData> getFilterData({required int companyId}) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.reportsRead,
      companyId: companyId,
    );
    _validateCompanyId(companyId);

    final employeesFuture = _employeesDao.getEmployeesByCompany(companyId);
    final departmentsFuture = _departmentsDao.getDepartmentsByCompany(
      companyId,
    );

    final employees = await employeesFuture;
    final departments = await departmentsFuture;

    final sectors = <DepartmentSector>[];
    for (final department in departments) {
      final byDepartment = await _departmentsDao.getSectorsByDepartment(
        department.id,
      );
      sectors.addAll(byDepartment);
    }

    return ReportsFilterData(
      employees: employees,
      departments: departments,
      sectors: sectors,
    );
  }

  Future<ReportsPeriodSummary> getPeriodSummary({
    required int companyId,
    required DateTime startDate,
    required DateTime endDate,
    int? employeeId,
    Set<int>? departmentIds,
    Set<int>? sectorIds,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.reportsRead,
      companyId: companyId,
    );
    _validateCompanyId(companyId);

    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    _validateDateRange(startDate: normalizedStart, endDate: normalizedEnd);

    final employees = await _employeesDao.getEmployeesByCompany(companyId);

    final filteredEmployees = _filterEmployees(
      employees: employees,
      employeeId: employeeId,
      departmentIds: departmentIds,
      sectorIds: sectorIds,
    );
    final filteredEmployeeIds = filteredEmployees
        .map((employee) => employee.id)
        .toSet();

    final attendance = await _attendanceDao.getAttendanceByDateRange(
      companyId: companyId,
      startDate: normalizedStart,
      endDate: normalizedEnd,
    );

    var activeEmployees = 0;
    for (final employee in filteredEmployees) {
      if (employee.active) {
        activeEmployees += 1;
      }
    }
    final inactiveEmployees = filteredEmployees.length - activeEmployees;

    final attendanceByEventType = <String, int>{};
    var workedHours = 0.0;
    var overtimeHours = 0.0;
    for (final event in attendance) {
      if (!filteredEmployeeIds.contains(event.employeeId)) {
        continue;
      }
      attendanceByEventType[event.eventType] =
          (attendanceByEventType[event.eventType] ?? 0) + 1;
      workedHours += event.hoursWorked ?? 0.0;
      overtimeHours += event.overtimeHours ?? 0.0;
    }

    final monthsInRange = _monthPeriodsInRange(
      startDate: normalizedStart,
      endDate: normalizedEnd,
    );
    var payrollRunsCount = 0;
    var payrollLockedRunsCount = 0;
    DateTime? payrollLastGeneratedAt;
    var payrollGrossTotal = 0.0;
    var payrollNetTotal = 0.0;
    var payrollIpsTotal = 0.0;
    var payrollAttendanceDiscountTotal = 0.0;
    var payrollOtherDiscountTotal = 0.0;
    var payrollEmbargoTotal = 0.0;
    final payrollEmployeeIds = <int>{};
    final payrollMonthlySubtotals = <ReportsPayrollMonthlySubtotal>[];
    var grandSalaryBase = 0.0;
    var grandExtraCompensation = 0.0;
    var grandOtherIncome = 0.0;
    var grandGross = 0.0;
    var grandFamilyBonus = 0.0;
    var grandIpsEmployee = 0.0;
    var grandDiscounts = 0.0;
    var grandEmbargo = 0.0;
    var grandBalance = 0.0;

    for (final period in monthsInRange) {
      final payrollRun = await _payrollDao.getPayrollRunByPeriod(
        companyId: companyId,
        year: period.year,
        month: period.month,
      );
      if (payrollRun != null) {
        payrollRunsCount += 1;
        if (payrollRun.isLocked) {
          payrollLockedRunsCount += 1;
        }
        if (payrollLastGeneratedAt == null ||
            payrollRun.generatedAt.isAfter(payrollLastGeneratedAt)) {
          payrollLastGeneratedAt = payrollRun.generatedAt;
        }
      }

      if (payrollRun == null || !payrollRun.isLocked) {
        payrollMonthlySubtotals.add(
          ReportsPayrollMonthlySubtotal(
            year: period.year,
            month: period.month,
            hasLockedPayroll: false,
            rowMessage: 'Sin liquidacion guardada',
            salaryBase: 0,
            extraCompensation: 0,
            otherIncome: 0,
            gross: 0,
            familyBonus: 0,
            ipsEmployee: 0,
            discounts: 0,
            embargo: 0,
            balance: 0,
          ),
        );
        continue;
      }

      final payrollItems = await _payrollDao.getPayrollItemsByPeriod(
        companyId: companyId,
        year: period.year,
        month: period.month,
      );

      var monthSalaryBase = 0.0;
      var monthExtraCompensation = 0.0;
      var monthOtherIncome = 0.0;
      var monthGross = 0.0;
      var monthFamilyBonus = 0.0;
      var monthIpsEmployee = 0.0;
      var monthDiscounts = 0.0;
      var monthEmbargo = 0.0;
      var monthBalance = 0.0;

      for (final record in payrollItems) {
        final item = record.item;
        if (!filteredEmployeeIds.contains(item.employeeId)) {
          continue;
        }

        final itemExtraCompensation =
            item.overtimePay + item.ordinaryNightSurchargePay;
        final itemDiscounts = item.attendanceDiscount + item.otherDiscount;
        final itemEmbargo = item.embargoAmount ?? 0.0;
        final itemGross = item.grossPay + item.advancesTotal;

        payrollEmployeeIds.add(item.employeeId);

        monthSalaryBase += item.baseSalary;
        monthExtraCompensation += itemExtraCompensation;
        monthOtherIncome += item.advancesTotal;
        monthGross += itemGross;
        monthFamilyBonus += item.familyBonus;
        monthIpsEmployee += item.ipsEmployee;
        monthDiscounts += itemDiscounts;
        monthEmbargo += itemEmbargo;
        monthBalance += item.netPay;

        payrollGrossTotal += item.grossPay;
        payrollNetTotal += item.netPay;
        payrollIpsTotal += item.ipsEmployee;
        payrollAttendanceDiscountTotal += item.attendanceDiscount;
        payrollOtherDiscountTotal += item.otherDiscount;
        payrollEmbargoTotal += itemEmbargo;
      }

      payrollMonthlySubtotals.add(
        ReportsPayrollMonthlySubtotal(
          year: period.year,
          month: period.month,
          hasLockedPayroll: true,
          rowMessage: null,
          salaryBase: monthSalaryBase,
          extraCompensation: monthExtraCompensation,
          otherIncome: monthOtherIncome,
          gross: monthGross,
          familyBonus: monthFamilyBonus,
          ipsEmployee: monthIpsEmployee,
          discounts: monthDiscounts,
          embargo: monthEmbargo,
          balance: monthBalance,
        ),
      );

      grandSalaryBase += monthSalaryBase;
      grandExtraCompensation += monthExtraCompensation;
      grandOtherIncome += monthOtherIncome;
      grandGross += monthGross;
      grandFamilyBonus += monthFamilyBonus;
      grandIpsEmployee += monthIpsEmployee;
      grandDiscounts += monthDiscounts;
      grandEmbargo += monthEmbargo;
      grandBalance += monthBalance;
    }

    final payrollGrandTotal = ReportsPayrollMonthlySubtotal(
      year: 0,
      month: 0,
      hasLockedPayroll: true,
      rowMessage: null,
      salaryBase: grandSalaryBase,
      extraCompensation: grandExtraCompensation,
      otherIncome: grandOtherIncome,
      gross: grandGross,
      familyBonus: grandFamilyBonus,
      ipsEmployee: grandIpsEmployee,
      discounts: grandDiscounts,
      embargo: grandEmbargo,
      balance: grandBalance,
    );

    return ReportsPeriodSummary(
      companyId: companyId,
      startDate: normalizedStart,
      endDate: normalizedEnd,
      totalEmployees: filteredEmployees.length,
      activeEmployees: activeEmployees,
      inactiveEmployees: inactiveEmployees,
      attendanceRecords: attendanceByEventType.values.fold<int>(
        0,
        (sum, value) => sum + value,
      ),
      totalWorkedHours: workedHours,
      totalOvertimeHours: overtimeHours,
      attendanceByEventType: attendanceByEventType,
      payrollMonthsConsidered: monthsInRange.length,
      payrollRunsCount: payrollRunsCount,
      payrollLockedRunsCount: payrollLockedRunsCount,
      payrollLastGeneratedAt: payrollLastGeneratedAt,
      payrollEmployees: payrollEmployeeIds.length,
      payrollGrossTotal: payrollGrossTotal,
      payrollNetTotal: payrollNetTotal,
      payrollIpsTotal: payrollIpsTotal,
      payrollAttendanceDiscountTotal: payrollAttendanceDiscountTotal,
      payrollOtherDiscountTotal: payrollOtherDiscountTotal,
      payrollEmbargoTotal: payrollEmbargoTotal,
      payrollMonthlySubtotals: payrollMonthlySubtotals,
      payrollGrandTotal: payrollGrandTotal,
    );
  }

  Future<ReportsPeriodSummary> getPeriodSummaryForCompanies({
    required List<int> companyIds,
    required DateTime startDate,
    required DateTime endDate,
    int? employeeId,
    Set<int>? departmentIds,
    Set<int>? sectorIds,
  }) async {
    final normalizedCompanyIds =
        companyIds.where((id) => id > 0).toSet().toList()..sort();
    if (normalizedCompanyIds.isEmpty) {
      throw ArgumentError('Debe seleccionar al menos una empresa.');
    }

    final summaries = <ReportsPeriodSummary>[];
    for (final companyId in normalizedCompanyIds) {
      final summary = await getPeriodSummary(
        companyId: companyId,
        startDate: startDate,
        endDate: endDate,
        employeeId: employeeId,
        departmentIds: departmentIds,
        sectorIds: sectorIds,
      );
      summaries.add(summary);
    }

    final reference = summaries.first;
    final attendanceByEventType = <String, int>{};
    var totalEmployees = 0;
    var activeEmployees = 0;
    var inactiveEmployees = 0;
    var attendanceRecords = 0;
    var totalWorkedHours = 0.0;
    var totalOvertimeHours = 0.0;
    var payrollRunsCount = 0;
    var payrollLockedRunsCount = 0;
    DateTime? payrollLastGeneratedAt;
    var payrollEmployees = 0;
    var payrollGrossTotal = 0.0;
    var payrollNetTotal = 0.0;
    var payrollIpsTotal = 0.0;
    var payrollAttendanceDiscountTotal = 0.0;
    var payrollOtherDiscountTotal = 0.0;
    var payrollEmbargoTotal = 0.0;

    final monthlyAccumulators = <int, _MonthlySubtotalAccumulator>{};

    for (final summary in summaries) {
      totalEmployees += summary.totalEmployees;
      activeEmployees += summary.activeEmployees;
      inactiveEmployees += summary.inactiveEmployees;
      attendanceRecords += summary.attendanceRecords;
      totalWorkedHours += summary.totalWorkedHours;
      totalOvertimeHours += summary.totalOvertimeHours;
      payrollRunsCount += summary.payrollRunsCount;
      payrollLockedRunsCount += summary.payrollLockedRunsCount;
      payrollEmployees += summary.payrollEmployees;
      payrollGrossTotal += summary.payrollGrossTotal;
      payrollNetTotal += summary.payrollNetTotal;
      payrollIpsTotal += summary.payrollIpsTotal;
      payrollAttendanceDiscountTotal += summary.payrollAttendanceDiscountTotal;
      payrollOtherDiscountTotal += summary.payrollOtherDiscountTotal;
      payrollEmbargoTotal += summary.payrollEmbargoTotal;

      if (summary.payrollLastGeneratedAt != null &&
          (payrollLastGeneratedAt == null ||
              summary.payrollLastGeneratedAt!.isAfter(
                payrollLastGeneratedAt,
              ))) {
        payrollLastGeneratedAt = summary.payrollLastGeneratedAt;
      }

      for (final entry in summary.attendanceByEventType.entries) {
        attendanceByEventType[entry.key] =
            (attendanceByEventType[entry.key] ?? 0) + entry.value;
      }

      for (final monthly in summary.payrollMonthlySubtotals) {
        final key = (monthly.year * 100) + monthly.month;
        final accumulator = monthlyAccumulators.putIfAbsent(
          key,
          () => _MonthlySubtotalAccumulator(
            year: monthly.year,
            month: monthly.month,
          ),
        );
        if (monthly.hasLockedPayroll) {
          accumulator.hasLockedPayroll = true;
          accumulator.salaryBase += monthly.salaryBase;
          accumulator.extraCompensation += monthly.extraCompensation;
          accumulator.otherIncome += monthly.otherIncome;
          accumulator.gross += monthly.gross;
          accumulator.familyBonus += monthly.familyBonus;
          accumulator.ipsEmployee += monthly.ipsEmployee;
          accumulator.discounts += monthly.discounts;
          accumulator.embargo += monthly.embargo;
          accumulator.balance += monthly.balance;
        }
      }
    }

    final orderedKeys = monthlyAccumulators.keys.toList()..sort();
    final payrollMonthlySubtotals = <ReportsPayrollMonthlySubtotal>[];
    for (final key in orderedKeys) {
      final accumulator = monthlyAccumulators[key]!;
      payrollMonthlySubtotals.add(
        ReportsPayrollMonthlySubtotal(
          year: accumulator.year,
          month: accumulator.month,
          hasLockedPayroll: accumulator.hasLockedPayroll,
          rowMessage: accumulator.hasLockedPayroll
              ? null
              : 'Sin liquidacion guardada',
          salaryBase: accumulator.salaryBase,
          extraCompensation: accumulator.extraCompensation,
          otherIncome: accumulator.otherIncome,
          gross: accumulator.gross,
          familyBonus: accumulator.familyBonus,
          ipsEmployee: accumulator.ipsEmployee,
          discounts: accumulator.discounts,
          embargo: accumulator.embargo,
          balance: accumulator.balance,
        ),
      );
    }

    final payrollGrandTotal = ReportsPayrollMonthlySubtotal(
      year: 0,
      month: 0,
      hasLockedPayroll: true,
      rowMessage: null,
      salaryBase: summaries.fold<double>(
        0,
        (sum, item) => sum + item.payrollGrandTotal.salaryBase,
      ),
      extraCompensation: summaries.fold<double>(
        0,
        (sum, item) => sum + item.payrollGrandTotal.extraCompensation,
      ),
      otherIncome: summaries.fold<double>(
        0,
        (sum, item) => sum + item.payrollGrandTotal.otherIncome,
      ),
      gross: summaries.fold<double>(
        0,
        (sum, item) => sum + item.payrollGrandTotal.gross,
      ),
      familyBonus: summaries.fold<double>(
        0,
        (sum, item) => sum + item.payrollGrandTotal.familyBonus,
      ),
      ipsEmployee: summaries.fold<double>(
        0,
        (sum, item) => sum + item.payrollGrandTotal.ipsEmployee,
      ),
      discounts: summaries.fold<double>(
        0,
        (sum, item) => sum + item.payrollGrandTotal.discounts,
      ),
      embargo: summaries.fold<double>(
        0,
        (sum, item) => sum + item.payrollGrandTotal.embargo,
      ),
      balance: summaries.fold<double>(
        0,
        (sum, item) => sum + item.payrollGrandTotal.balance,
      ),
    );

    return ReportsPeriodSummary(
      companyId: 0,
      startDate: reference.startDate,
      endDate: reference.endDate,
      totalEmployees: totalEmployees,
      activeEmployees: activeEmployees,
      inactiveEmployees: inactiveEmployees,
      attendanceRecords: attendanceRecords,
      totalWorkedHours: totalWorkedHours,
      totalOvertimeHours: totalOvertimeHours,
      attendanceByEventType: attendanceByEventType,
      payrollMonthsConsidered: payrollMonthlySubtotals.length,
      payrollRunsCount: payrollRunsCount,
      payrollLockedRunsCount: payrollLockedRunsCount,
      payrollLastGeneratedAt: payrollLastGeneratedAt,
      payrollEmployees: payrollEmployees,
      payrollGrossTotal: payrollGrossTotal,
      payrollNetTotal: payrollNetTotal,
      payrollIpsTotal: payrollIpsTotal,
      payrollAttendanceDiscountTotal: payrollAttendanceDiscountTotal,
      payrollOtherDiscountTotal: payrollOtherDiscountTotal,
      payrollEmbargoTotal: payrollEmbargoTotal,
      payrollMonthlySubtotals: payrollMonthlySubtotals,
      payrollGrandTotal: payrollGrandTotal,
    );
  }

  Future<List<ReportsEmployeeSummary>> getEmployeeSummaryForCompanies({
    required List<int> companyIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedCompanyIds =
        companyIds.where((id) => id > 0).toSet().toList()..sort();
    if (normalizedCompanyIds.isEmpty) {
      throw ArgumentError('Debe seleccionar al menos una empresa.');
    }

    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    _validateDateRange(startDate: normalizedStart, endDate: normalizedEnd);

    final reportCompanies = await listReportCompanies();
    final companyNameById = <int, String>{
      for (final company in reportCompanies)
        company.id: (company.abbreviation ?? '').trim().isNotEmpty
            ? company.abbreviation!.trim()
            : company.name,
    };

    final monthsInRange = _monthPeriodsInRange(
      startDate: normalizedStart,
      endDate: normalizedEnd,
    );
    final accumulators = <int, _EmployeeSummaryAccumulator>{};

    for (final companyId in normalizedCompanyIds) {
      await _authorizationService.ensurePermission(
        PermissionKeys.reportsRead,
        companyId: companyId,
      );
      _validateCompanyId(companyId);

      for (final period in monthsInRange) {
        final payrollRun = await _payrollDao.getPayrollRunByPeriod(
          companyId: companyId,
          year: period.year,
          month: period.month,
        );
        if (payrollRun == null || !payrollRun.isLocked) {
          continue;
        }

        final payrollItems = await _payrollDao.getPayrollItemsByPeriod(
          companyId: companyId,
          year: period.year,
          month: period.month,
        );

        for (final record in payrollItems) {
          final item = record.item;
          final employee = record.employee;
          final companyName = (companyNameById[employee.companyId] ?? '')
              .trim();
          final resolvedCompanyName = companyName.isEmpty
              ? 'Empresa ${employee.companyId}'
              : companyName;
          final acc = accumulators.putIfAbsent(
            employee.id,
            () => _EmployeeSummaryAccumulator(
              employeeId: employee.id,
              employeeName: _employeeDisplayName(employee),
              documentNumber: employee.documentNumber,
              companyId: employee.companyId,
              companyName: resolvedCompanyName,
            ),
          );

          final itemExtraCompensation =
              item.overtimePay + item.ordinaryNightSurchargePay;
          final itemDiscounts = item.attendanceDiscount + item.otherDiscount;
          final itemEmbargo = item.embargoAmount ?? 0.0;
          final itemGross = item.grossPay + item.advancesTotal;

          acc.salaryBase += item.baseSalary;
          acc.extraCompensation += itemExtraCompensation;
          acc.otherIncome += item.advancesTotal;
          acc.gross += itemGross;
          acc.familyBonus += item.familyBonus;
          acc.ipsEmployee += item.ipsEmployee;
          acc.discounts += itemDiscounts;
          acc.embargo += itemEmbargo;
          acc.balance += item.netPay;
        }
      }
    }

    final rows = accumulators.values
        .map(
          (acc) => ReportsEmployeeSummary(
            employeeId: acc.employeeId,
            employeeName: acc.employeeName,
            documentNumber: acc.documentNumber,
            companyId: acc.companyId,
            companyName: acc.companyName,
            salaryBase: acc.salaryBase,
            extraCompensation: acc.extraCompensation,
            otherIncome: acc.otherIncome,
            gross: acc.gross,
            familyBonus: acc.familyBonus,
            ipsEmployee: acc.ipsEmployee,
            discounts: acc.discounts,
            embargo: acc.embargo,
            balance: acc.balance,
          ),
        )
        .toList();

    rows.sort(
      (left, right) => left.employeeName.toLowerCase().compareTo(
        right.employeeName.toLowerCase(),
      ),
    );
    return rows;
  }

  String _employeeDisplayName(Employee employee) {
    final fullName = employee.fullName.trim();
    final firstNames = employee.firstNames.trim();
    final lastNames = employee.lastNames.trim();

    if (firstNames.isNotEmpty || lastNames.isNotEmpty) {
      final combined = '$firstNames $lastNames'.trim();
      if (combined.isNotEmpty) {
        return combined;
      }
    }
    return fullName.isNotEmpty ? fullName : 'Empleado ${employee.id}';
  }

  List<Employee> _filterEmployees({
    required List<Employee> employees,
    required int? employeeId,
    required Set<int>? departmentIds,
    required Set<int>? sectorIds,
  }) {
    final normalizedDepartmentIds = (departmentIds ?? const <int>{})
        .where((id) => id > 0)
        .toSet();
    final normalizedSectorIds = (sectorIds ?? const <int>{})
        .where((id) => id > 0)
        .toSet();
    final filtered = <Employee>[];
    for (final employee in employees) {
      if (employeeId != null && employee.id != employeeId) {
        continue;
      }
      if (normalizedDepartmentIds.isNotEmpty &&
          !normalizedDepartmentIds.contains(employee.departmentId)) {
        continue;
      }
      if (normalizedSectorIds.isNotEmpty &&
          !normalizedSectorIds.contains(employee.sectorId)) {
        continue;
      }
      filtered.add(employee);
    }
    return filtered;
  }

  List<_MonthPeriod> _monthPeriodsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final periods = <_MonthPeriod>[];
    var cursor = DateTime(startDate.year, startDate.month, 1);
    final limit = DateTime(endDate.year, endDate.month, 1);

    while (!cursor.isAfter(limit)) {
      periods.add(_MonthPeriod(year: cursor.year, month: cursor.month));
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    return periods;
  }

  void _validateCompanyId(int companyId) {
    if (companyId <= 0) {
      throw ArgumentError('La empresa no es valida.');
    }
  }

  void _validateDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (startDate.isAfter(endDate)) {
      throw ArgumentError(
        'La fecha desde no puede ser mayor a la fecha hasta.',
      );
    }
    if (startDate.year < 2000 || endDate.year > 2200) {
      throw ArgumentError('El rango de fechas no es valido.');
    }
  }
}

class _MonthPeriod {
  const _MonthPeriod({required this.year, required this.month});

  final int year;
  final int month;
}

class _MonthlySubtotalAccumulator {
  _MonthlySubtotalAccumulator({required this.year, required this.month});

  final int year;
  final int month;
  bool hasLockedPayroll = false;
  double salaryBase = 0.0;
  double extraCompensation = 0.0;
  double otherIncome = 0.0;
  double gross = 0.0;
  double familyBonus = 0.0;
  double ipsEmployee = 0.0;
  double discounts = 0.0;
  double embargo = 0.0;
  double balance = 0.0;
}

class _EmployeeSummaryAccumulator {
  _EmployeeSummaryAccumulator({
    required this.employeeId,
    required this.employeeName,
    required this.documentNumber,
    required this.companyId,
    required this.companyName,
  });

  final int employeeId;
  final String employeeName;
  final String documentNumber;
  final int companyId;
  final String companyName;
  double salaryBase = 0.0;
  double extraCompensation = 0.0;
  double otherIncome = 0.0;
  double gross = 0.0;
  double familyBonus = 0.0;
  double ipsEmployee = 0.0;
  double discounts = 0.0;
  double embargo = 0.0;
  double balance = 0.0;
}
