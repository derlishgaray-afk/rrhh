import 'dart:math' as math;
import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'company_settings_service.dart';

class PayrollGenerationResult {
  const PayrollGenerationResult({
    required this.runId,
    required this.itemsGenerated,
  });

  final int runId;
  final int itemsGenerated;
}

class PayrollItemView {
  const PayrollItemView({
    required this.payrollItem,
    required this.employeeName,
    required this.departmentName,
  });

  final PayrollItem payrollItem;
  final String employeeName;
  final String? departmentName;
}

class PayrollService {
  PayrollService({
    required PayrollDao payrollDao,
    required EmployeesDao employeesDao,
    required AttendanceDao attendanceDao,
    required CompanySettingsService companySettingsService,
  }) : _payrollDao = payrollDao,
       _employeesDao = employeesDao,
       _attendanceDao = attendanceDao,
       _companySettingsService = companySettingsService;

  final PayrollDao _payrollDao;
  final EmployeesDao _employeesDao;
  final AttendanceDao _attendanceDao;
  final CompanySettingsService _companySettingsService;

  Future<PayrollGenerationResult> generatePayroll({
    required int companyId,
    required int year,
    required int month,
    String? notes,
  }) async {
    _validatePeriod(companyId: companyId, year: year, month: month);
    final settings = await _companySettingsService.getOrCreateSettings(
      companyId,
    );

    final now = DateTime.now();
    final normalizedNotes = _normalizeOptional(notes);

    final existingRun = await _payrollDao.getPayrollRunByPeriod(
      companyId: companyId,
      year: year,
      month: month,
    );

    final int runId;
    if (existingRun == null) {
      runId = await _payrollDao.insertPayrollRun(
        PayrollRunsCompanion.insert(
          companyId: companyId,
          year: year,
          month: month,
          generatedAt: Value(now),
          notes: Value(normalizedNotes),
        ),
      );
    } else {
      runId = existingRun.id;
      await _payrollDao.updatePayrollRun(
        existingRun.copyWith(generatedAt: now, notes: Value(normalizedNotes)),
      );
    }

    await _payrollDao.deleteItemsByRun(runId);

    final employees = await _employeesDao.getActiveEmployeesByCompany(
      companyId,
    );
    if (employees.isEmpty) {
      return PayrollGenerationResult(runId: runId, itemsGenerated: 0);
    }

    final attendanceEvents = await _attendanceDao.getAttendanceByMonth(
      companyId: companyId,
      year: year,
      month: month,
    );

    final attendanceByEmployee = <int, List<AttendanceEvent>>{};
    for (final event in attendanceEvents) {
      attendanceByEmployee.putIfAbsent(event.employeeId, () => []).add(event);
    }

    final items = <PayrollItemsCompanion>[];
    final timeWindows = _buildTimeWindows(settings);
    for (final employee in employees) {
      final metrics = _computeWorkMetrics(
        employee: employee,
        events: attendanceByEmployee[employee.id] ?? const [],
        timeWindows: timeWindows,
      );

      final effectiveOvertimeHours = employee.allowOvertime
          ? metrics.overtimeHours
          : 0.0;
      final effectiveOvertimeDayHours = employee.allowOvertime
          ? metrics.overtimeDayHours
          : 0.0;
      final effectiveOvertimeNightHours = employee.allowOvertime
          ? metrics.overtimeNightHours
          : 0.0;

      final hourlyRate = computeHourlyRate(
        employeeType: employee.employeeType,
        baseSalary: employee.baseSalary,
      );
      final baseGross = _computeBaseGross(
        employeeType: employee.employeeType,
        baseSalary: employee.baseSalary,
        workedDays: metrics.workedDays,
        hourlyRate: hourlyRate,
        nightShiftBaseReductionHours: metrics.nightShiftBaseReductionHours,
      );

      final overtimePay = computeOvertimePay(
        overtimeHoursDay: effectiveOvertimeDayHours,
        overtimeHoursNight: effectiveOvertimeNightHours,
        hourlyRate: hourlyRate,
        overtimeDayRate: settings.overtimeDayRate,
        overtimeNightRate: settings.overtimeNightRate,
      );
      final ordinaryNightSurchargePay = computeOrdinaryNightSurchargePay(
        ordinaryNightHours: metrics.ordinaryNightHours,
        hourlyRate: hourlyRate,
        ordinaryNightSurchargeRate: settings.ordinaryNightSurchargeRate,
      );
      final attendanceDiscount = _computeAttendanceDiscount(
        employee: employee,
        events: attendanceByEmployee[employee.id] ?? const [],
        settings: settings,
        hourlyRate: hourlyRate,
      );
      final gross = baseGross + overtimePay + ordinaryNightSurchargePay;
      final familyBonus = _computeFamilyBonus(
        baseSalary: employee.baseSalary,
        grossPay: gross,
        childrenCount: employee.childrenCount,
        minimumWage: settings.minimumWage,
        familyBonusRate: settings.familyBonusRate,
      );
      final ipsEmployee = employee.ipsEnabled
          ? gross * settings.ipsEmployeeRate
          : 0.0;
      const ipsEmployer = 0.0;
      final embargoDiscount = _computeEmbargoDiscount(
        hasEmbargo: employee.hasEmbargo,
        embargoAmount: employee.embargoAmount,
      );
      const otherDiscount = 0.0;
      final netPay =
          gross +
          familyBonus -
          ipsEmployee -
          attendanceDiscount -
          embargoDiscount -
          otherDiscount;

      items.add(
        PayrollItemsCompanion.insert(
          companyId: companyId,
          payrollRunId: runId,
          employeeId: employee.id,
          employeeType: employee.employeeType,
          baseSalary: employee.baseSalary,
          workedDays: metrics.workedDays,
          workedHours: metrics.workedHours,
          overtimeHours: effectiveOvertimeHours,
          overtimePay: Value(overtimePay),
          ordinaryNightHours: Value(metrics.ordinaryNightHours),
          ordinaryNightSurchargePay: Value(ordinaryNightSurchargePay),
          grossPay: gross,
          familyBonus: Value(familyBonus),
          ipsEmployee: ipsEmployee,
          ipsEmployer: ipsEmployer,
          advancesTotal: 0,
          attendanceDiscount: Value(attendanceDiscount),
          otherDiscount: const Value(otherDiscount),
          embargoAmount: Value(embargoDiscount == 0 ? null : embargoDiscount),
          embargoAccount: Value(
            embargoDiscount == 0 ? null : employee.embargoAccount,
          ),
          netPay: netPay,
        ),
      );
    }

    await _payrollDao.insertPayrollItems(items);

    return PayrollGenerationResult(runId: runId, itemsGenerated: items.length);
  }

  Future<List<PayrollItemView>> listPayrollItemsByPeriod({
    required int companyId,
    required int year,
    required int month,
  }) async {
    _validatePeriod(companyId: companyId, year: year, month: month);

    final records = await _payrollDao.getPayrollItemsByPeriod(
      companyId: companyId,
      year: year,
      month: month,
    );

    final items = records
        .map(
          (record) => PayrollItemView(
            payrollItem: record.item,
            employeeName: record.employee.fullName,
            departmentName: record.departmentName,
          ),
        )
        .toList();

    items.sort((left, right) {
      final byDepartment = _compareDepartmentName(
        left.departmentName,
        right.departmentName,
      );
      if (byDepartment != 0) {
        return byDepartment;
      }
      return left.employeeName.toLowerCase().compareTo(
        right.employeeName.toLowerCase(),
      );
    });

    return items;
  }

  Future<void> updateOtherDiscount({
    required int payrollItemId,
    required double otherDiscount,
  }) async {
    if (payrollItemId <= 0) {
      throw ArgumentError('El item de liquidacion no es valido.');
    }
    if (otherDiscount < 0) {
      throw ArgumentError('Otros descuentos no puede ser negativo.');
    }

    final item = await _payrollDao.getPayrollItemById(payrollItemId);
    if (item == null) {
      throw ArgumentError('No se encontro el item de liquidacion.');
    }

    final netPay = item.netPay + item.otherDiscount - otherDiscount;
    await _payrollDao.updatePayrollItem(
      item.copyWith(otherDiscount: otherDiscount, netPay: netPay),
    );
  }

  _WorkMetrics _computeWorkMetrics({
    required Employee employee,
    required List<AttendanceEvent> events,
    required _PayrollTimeWindows timeWindows,
  }) {
    var workedDays = 0.0;
    var workedHours = 0.0;
    var overtimeHours = 0.0;
    var overtimeDayHours = 0.0;
    var overtimeNightHours = 0.0;
    var ordinaryNightHours = 0.0;
    var nightShiftBaseReductionHours = 0.0;

    for (final event in events) {
      final effectiveWorkedHours = _resolveWorkedHoursForPayroll(
        event: event,
        employee: employee,
      );
      final isPresentEvent = event.eventType == 'presente';
      var workedInEvent = 0.0;
      var hasWorkedInEvent = false;

      if (isPresentEvent) {
        final hasAnyTime =
            (event.checkInTime?.trim().isNotEmpty ?? false) ||
            (event.checkOutTime?.trim().isNotEmpty ?? false);
        workedInEvent =
            effectiveWorkedHours ??
            event.hoursWorked ??
            (hasAnyTime ? 0.0 : 8.0);
        hasWorkedInEvent = true;
        workedHours += workedInEvent;
        if (workedInEvent > 0) {
          workedDays += 1;
        }
      } else if (event.eventType == 'tardanza') {
        workedDays += 1;
        final lateMinutes = event.minutesLate ?? 0;
        final defaultHours = (8 - (lateMinutes / 60)).clamp(0, 8).toDouble();
        workedHours += event.hoursWorked ?? defaultHours;
      } else if (_paidDayEvents.contains(event.eventType)) {
        workedDays += 1;
        workedHours += event.hoursWorked ?? 8.0;
      } else {
        workedHours += event.hoursWorked ?? 0.0;
      }

      var eventOvertimeDayHours = 0.0;
      var eventOvertimeNightHours = 0.0;
      final eventOvertimeHours = event.overtimeHours ?? 0.0;
      if (eventOvertimeHours > 0) {
        if (event.overtimeType == 'nocturna') {
          eventOvertimeNightHours = eventOvertimeHours;
        } else {
          eventOvertimeDayHours = eventOvertimeHours;
        }
      } else if (isPresentEvent) {
        final automaticOvertime = _calculateAutomaticOvertime(
          event: event,
          workedHours: effectiveWorkedHours ?? event.hoursWorked,
          timeWindows: timeWindows,
        );
        if (automaticOvertime != null) {
          eventOvertimeDayHours = automaticOvertime.dayHours;
          eventOvertimeNightHours = automaticOvertime.nightHours;
        }
      }

      overtimeDayHours += eventOvertimeDayHours;
      overtimeNightHours += eventOvertimeNightHours;
      overtimeHours += eventOvertimeDayHours + eventOvertimeNightHours;

      if (!isPresentEvent || !hasWorkedInEvent || workedInEvent <= 0) {
        continue;
      }

      ordinaryNightHours += _calculateOrdinaryNightHours(
        event: event,
        employee: employee,
        workedHours: workedInEvent,
        overtimeHours: eventOvertimeDayHours + eventOvertimeNightHours,
        timeWindows: timeWindows,
      );
      nightShiftBaseReductionHours += _calculateNightShiftBaseReductionHours(
        event: event,
        employee: employee,
        workedHours: workedInEvent,
        overtimeHours: eventOvertimeDayHours + eventOvertimeNightHours,
        timeWindows: timeWindows,
      );
    }

    return _WorkMetrics(
      workedDays: workedDays,
      workedHours: workedHours,
      overtimeHours: overtimeHours,
      overtimeDayHours: overtimeDayHours,
      overtimeNightHours: overtimeNightHours,
      ordinaryNightHours: ordinaryNightHours,
      nightShiftBaseReductionHours: nightShiftBaseReductionHours,
    );
  }

  double? _resolveWorkedHoursForPayroll({
    required AttendanceEvent event,
    required Employee employee,
  }) {
    if (event.eventType != 'presente') {
      return event.hoursWorked;
    }

    final recalculated = _calculateWorkedHoursFromTimes(
      checkInTime: event.checkInTime,
      checkOutTime: event.checkOutTime,
      breakMinutes: event.breakMinutes ?? _defaultBreakMinutes,
      employee: employee,
      date: event.date,
    );
    if (recalculated != null) {
      return recalculated;
    }
    return event.hoursWorked;
  }

  double? _calculateWorkedHoursFromTimes({
    required String? checkInTime,
    required String? checkOutTime,
    required int breakMinutes,
    required Employee employee,
    required DateTime date,
  }) {
    final normalizedCheckIn = checkInTime?.trim() ?? '';
    final normalizedCheckOut = checkOutTime?.trim() ?? '';
    if (normalizedCheckIn.isEmpty || normalizedCheckOut.isEmpty) {
      return null;
    }

    final checkInMinutes = _parseMinutesOrDefault(normalizedCheckIn, -1);
    final checkOutMinutes = _parseMinutesOrDefault(normalizedCheckOut, -1);
    if (checkInMinutes < 0 || checkOutMinutes < 0) {
      return null;
    }

    var effectiveCheckInMinutes = checkInMinutes;
    final scheduledStartMinute = _pickScheduledStartMinute(
      checkInMinutes: checkInMinutes,
      date: date,
      employee: employee,
    );
    if (scheduledStartMinute != null &&
        effectiveCheckInMinutes < scheduledStartMinute) {
      effectiveCheckInMinutes = scheduledStartMinute;
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
      breakMinutes: breakMinutes,
    );
    final netMinutes = workedMinutes - effectiveBreakMinutes;
    if (netMinutes <= 0) {
      return null;
    }

    return netMinutes / 60;
  }

  int? _pickScheduledStartMinute({
    required int checkInMinutes,
    required DateTime date,
    required Employee employee,
  }) {
    if (!employee.allowOvertime && date.weekday == DateTime.saturday) {
      final saturday = employee.workStartTimeSaturday?.trim() ?? '';
      final saturdayStart = _parseMinutesOrDefault(saturday, -1);
      if (saturdayStart >= 0) {
        return saturdayStart;
      }
    }

    final starts = _employeeScheduledStartMinutes(employee);
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

  List<int> _employeeScheduledStartMinutes(Employee employee) {
    final starts = <int>[];
    for (final raw in [
      employee.workStartTime1,
      employee.workStartTime2,
      employee.workStartTime3,
    ]) {
      final parsed = _parseMinutesOrDefault(raw, -1);
      if (parsed >= 0 && !starts.contains(parsed)) {
        starts.add(parsed);
      }
    }
    return starts;
  }

  double _computeGrossPay({
    required String employeeType,
    required double baseSalary,
    required double workedDays,
  }) {
    final computableDays = workedDays < 0 ? 0.0 : workedDays;
    switch (employeeType) {
      case 'mensual':
        return (baseSalary / 30) * math.min(computableDays, 30.0);
      case 'jornalero':
        return computableDays * baseSalary;
      case 'servicio':
        return (baseSalary / 30) * math.min(computableDays, 30.0);
      default:
        return (baseSalary / 30) * math.min(computableDays, 30.0);
    }
  }

  double _computeBaseGross({
    required String employeeType,
    required double baseSalary,
    required double workedDays,
    required double hourlyRate,
    required double nightShiftBaseReductionHours,
  }) {
    final baseGross = _computeGrossPay(
      employeeType: employeeType,
      baseSalary: baseSalary,
      workedDays: workedDays,
    );

    if ((employeeType == 'mensual' || employeeType == 'servicio') &&
        nightShiftBaseReductionHours > 0 &&
        hourlyRate > 0) {
      final reduction = nightShiftBaseReductionHours * hourlyRate;
      final adjusted = baseGross - reduction;
      return adjusted < 0 ? 0 : adjusted;
    }

    return baseGross;
  }

  double computeHourlyRate({
    required String employeeType,
    required double baseSalary,
  }) {
    switch (employeeType) {
      case 'mensual':
        return baseSalary / 30 / 8;
      case 'jornalero':
        return baseSalary / 8;
      case 'servicio':
        return baseSalary / 30 / 8;
      default:
        return 0;
    }
  }

  double computeOvertimePay({
    required double overtimeHoursDay,
    required double overtimeHoursNight,
    required double hourlyRate,
    required double overtimeDayRate,
    required double overtimeNightRate,
  }) {
    final dayPay = overtimeHoursDay * hourlyRate * (1 + overtimeDayRate);
    final nightPay = overtimeHoursNight * hourlyRate * (1 + overtimeNightRate);
    return dayPay + nightPay;
  }

  double computeOrdinaryNightSurchargePay({
    required double ordinaryNightHours,
    required double hourlyRate,
    required double ordinaryNightSurchargeRate,
  }) {
    if (ordinaryNightHours <= 0 ||
        hourlyRate <= 0 ||
        ordinaryNightSurchargeRate <= 0) {
      return 0;
    }
    return ordinaryNightHours * hourlyRate * ordinaryNightSurchargeRate;
  }

  double _computeFamilyBonus({
    required double baseSalary,
    required double grossPay,
    required int childrenCount,
    required double minimumWage,
    required double familyBonusRate,
  }) {
    if (childrenCount <= 0 ||
        minimumWage <= 0 ||
        familyBonusRate <= 0 ||
        baseSalary <= 0 ||
        grossPay <= 0) {
      return 0;
    }

    if (baseSalary > (minimumWage * 2) || grossPay > (minimumWage * 2)) {
      return 0;
    }
    return childrenCount * (minimumWage * familyBonusRate);
  }

  double _computeEmbargoDiscount({
    required bool hasEmbargo,
    required double? embargoAmount,
  }) {
    if (!hasEmbargo || embargoAmount == null || embargoAmount <= 0) {
      return 0;
    }
    return embargoAmount;
  }

  double _computeAttendanceDiscount({
    required Employee employee,
    required List<AttendanceEvent> events,
    required CompanySetting settings,
    required double hourlyRate,
  }) {
    if (hourlyRate <= 0 || events.isEmpty) {
      return 0;
    }

    final sortedEvents = events.toList()
      ..sort((left, right) {
        final byDate = left.date.compareTo(right.date);
        if (byDate != 0) {
          return byDate;
        }
        return left.id.compareTo(right.id);
      });

    final toleranceMinutes = math.max(0, settings.lateArrivalToleranceMinutes);
    final allowedLateOccurrences = math.max(
      0,
      settings.lateArrivalAllowedTimesPerMonth,
    );

    var lateOccurrences = 0;
    var discountedMinutes = 0;

    for (final event in sortedEvents) {
      final breakdown = _computeDiscountBreakdownForEvent(
        event: event,
        employee: employee,
      );

      var discountedLateMinutes = 0;
      final rawLateMinutes = breakdown.rawLateMinutes;
      final exceedsTolerance = rawLateMinutes > toleranceMinutes;
      if (!employee.allowOvertime && exceedsTolerance) {
        lateOccurrences += 1;
        if (lateOccurrences <= allowedLateOccurrences) {
          discountedLateMinutes = rawLateMinutes - toleranceMinutes;
        } else {
          discountedLateMinutes = rawLateMinutes;
        }
      }

      discountedMinutes += discountedLateMinutes + breakdown.rawEarlyMinutes;
    }

    if (discountedMinutes <= 0) {
      return 0;
    }

    return (discountedMinutes / 60) * hourlyRate;
  }

  _AttendanceDiscountBreakdown _computeDiscountBreakdownForEvent({
    required AttendanceEvent event,
    required Employee employee,
  }) {
    if (event.eventType != 'presente' && event.eventType != 'tardanza') {
      return const _AttendanceDiscountBreakdown();
    }

    final checkInTime = event.checkInTime?.trim();
    final checkOutTime = event.checkOutTime?.trim();
    final checkInMinutes = (checkInTime == null || checkInTime.isEmpty)
        ? -1
        : _parseMinutesOrDefault(checkInTime, -1);
    final checkOutMinutes = (checkOutTime == null || checkOutTime.isEmpty)
        ? -1
        : _parseMinutesOrDefault(checkOutTime, -1);

    if (event.eventType == 'tardanza') {
      final rawLateMinutes = math.max(0, event.minutesLate ?? 0);
      return _AttendanceDiscountBreakdown(rawLateMinutes: rawLateMinutes);
    }

    if (checkInMinutes < 0) {
      return const _AttendanceDiscountBreakdown();
    }

    final scheduledStartMinute = _pickScheduledStartMinute(
      checkInMinutes: checkInMinutes,
      date: event.date,
      employee: employee,
    );
    if (scheduledStartMinute == null) {
      return const _AttendanceDiscountBreakdown();
    }

    final rawLateMinutes = math.max(0, checkInMinutes - scheduledStartMinute);
    if (checkOutMinutes < 0) {
      return _AttendanceDiscountBreakdown(rawLateMinutes: rawLateMinutes);
    }

    var adjustedCheckOutMinutes = checkOutMinutes;
    if (adjustedCheckOutMinutes < checkInMinutes) {
      adjustedCheckOutMinutes += _minutesPerDay;
    }

    final breakMinutes = math.max(
      0,
      event.breakMinutes ?? _defaultBreakMinutes,
    );
    final effectiveBreakMinutes = _effectiveBreakMinutesForSchedule(
      checkInMinutes: checkInMinutes,
      checkOutMinutes: checkOutMinutes,
      breakMinutes: breakMinutes,
    );
    final expectedCheckOutMinutes = _resolveExpectedCheckOutMinutes(
      event: event,
      employee: employee,
      scheduledStartMinute: scheduledStartMinute,
      breakMinutes: effectiveBreakMinutes,
    );
    final rawEarlyMinutes = math.max(
      0,
      expectedCheckOutMinutes - adjustedCheckOutMinutes,
    );

    return _AttendanceDiscountBreakdown(
      rawLateMinutes: rawLateMinutes,
      rawEarlyMinutes: rawEarlyMinutes,
    );
  }

  int _resolveExpectedCheckOutMinutes({
    required AttendanceEvent event,
    required Employee employee,
    required int scheduledStartMinute,
    required int breakMinutes,
  }) {
    if (!employee.allowOvertime && event.date.weekday == DateTime.saturday) {
      final saturdayEnd = employee.workEndTimeSaturday?.trim() ?? '';
      final parsedSaturdayEnd = _parseMinutesOrDefault(saturdayEnd, -1);
      if (parsedSaturdayEnd >= 0) {
        var expectedSaturdayEnd = parsedSaturdayEnd;
        if (expectedSaturdayEnd < scheduledStartMinute) {
          expectedSaturdayEnd += _minutesPerDay;
        }
        return expectedSaturdayEnd;
      }
    }

    return scheduledStartMinute + _normalDayMinutes + breakMinutes;
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

  void _validatePeriod({
    required int companyId,
    required int year,
    required int month,
  }) {
    if (companyId <= 0) {
      throw ArgumentError('La empresa no es valida.');
    }
    if (year < 2000 || year > 2200) {
      throw ArgumentError('El ano no es valido.');
    }
    if (month < 1 || month > 12) {
      throw ArgumentError('El mes no es valido.');
    }
  }

  String? _normalizeOptional(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  int _compareDepartmentName(String? left, String? right) {
    final normalizedLeft = _normalizeOptional(left)?.toLowerCase();
    final normalizedRight = _normalizeOptional(right)?.toLowerCase();

    final missingLeft = normalizedLeft == null;
    final missingRight = normalizedRight == null;
    if (missingLeft && missingRight) {
      return 0;
    }
    if (missingLeft) {
      return 1;
    }
    if (missingRight) {
      return -1;
    }
    return normalizedLeft.compareTo(normalizedRight);
  }

  _PayrollTimeWindows _buildTimeWindows(CompanySetting settings) {
    return _PayrollTimeWindows(
      ordinaryNightStart: _parseMinutesOrDefault(
        settings.ordinaryNightStart,
        _defaultOrdinaryNightStart,
      ),
      ordinaryNightEnd: _parseMinutesOrDefault(
        settings.ordinaryNightEnd,
        _defaultOrdinaryNightEnd,
      ),
      overtimeDayStart: _parseMinutesOrDefault(
        settings.overtimeDayStart,
        _defaultOvertimeDayStart,
      ),
      overtimeDayEnd: _parseMinutesOrDefault(
        settings.overtimeDayEnd,
        _defaultOvertimeDayEnd,
      ),
      overtimeNightStart: _parseMinutesOrDefault(
        settings.overtimeNightStart,
        _defaultOvertimeNightStart,
      ),
      overtimeNightEnd: _parseMinutesOrDefault(
        settings.overtimeNightEnd,
        _defaultOvertimeNightEnd,
      ),
    );
  }

  int _parseMinutesOrDefault(String value, int fallback) {
    final match = _timeRegex.firstMatch(value.trim());
    if (match == null) {
      return fallback;
    }

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) {
      return fallback;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return fallback;
    }

    return (hour * 60) + minute;
  }

  _CalculatedOvertime? _calculateAutomaticOvertime({
    required AttendanceEvent event,
    required double? workedHours,
    required _PayrollTimeWindows timeWindows,
  }) {
    final checkInTime = event.checkInTime?.trim();
    final checkOutTime = event.checkOutTime?.trim();

    if (workedHours == null || workedHours <= 0) {
      return null;
    }
    if (checkInTime == null ||
        checkInTime.isEmpty ||
        checkOutTime == null ||
        checkOutTime.isEmpty) {
      return null;
    }

    final checkInMinutes = _parseMinutesOrDefault(checkInTime, -1);
    final checkOutMinutes = _parseMinutesOrDefault(checkOutTime, -1);
    if (checkInMinutes < 0 || checkOutMinutes < 0) {
      return null;
    }
    if (checkInMinutes == checkOutMinutes) {
      return null;
    }

    var shiftStart = checkInMinutes;
    var shiftEnd = checkOutMinutes;
    if (shiftEnd < shiftStart) {
      shiftEnd += _minutesPerDay;
    }

    final shiftMinutes = shiftEnd - shiftStart;
    if (shiftMinutes <= 0) {
      return null;
    }

    final nightMinutes = _countMinutesInRange(
      intervalStart: shiftStart,
      intervalEnd: shiftEnd,
      rangeStart: timeWindows.ordinaryNightStart,
      rangeEnd: timeWindows.ordinaryNightEnd,
    );

    final isNightShift = (nightMinutes * 2) >= shiftMinutes;
    final normalLimit = isNightShift ? _normalNightHours : _normalDayHours;
    final overtimeHours = workedHours - normalLimit;
    if (overtimeHours <= 0) {
      return null;
    }

    var overtimeMinutes = (overtimeHours * 60).round();
    if (overtimeMinutes <= 0) {
      return null;
    }
    if (overtimeMinutes > shiftMinutes) {
      overtimeMinutes = shiftMinutes;
    }

    final overtimeStart = shiftEnd - overtimeMinutes;
    final overtimeEnd = shiftEnd;

    var overtimeDayMinutes = 0;
    var overtimeNightMinutes = 0;

    for (
      var minuteCursor = overtimeStart;
      minuteCursor < overtimeEnd;
      minuteCursor++
    ) {
      final minuteOfDay = minuteCursor % _minutesPerDay;
      final inNightOvertime = _isMinuteInRange(
        minuteOfDay,
        timeWindows.overtimeNightStart,
        timeWindows.overtimeNightEnd,
      );
      if (inNightOvertime) {
        overtimeNightMinutes += 1;
        continue;
      }

      final inDayOvertime = _isMinuteInRange(
        minuteOfDay,
        timeWindows.overtimeDayStart,
        timeWindows.overtimeDayEnd,
      );
      if (inDayOvertime) {
        overtimeDayMinutes += 1;
        continue;
      }

      if (isNightShift) {
        overtimeNightMinutes += 1;
      } else {
        overtimeDayMinutes += 1;
      }
    }

    return _CalculatedOvertime(
      dayHours: overtimeDayMinutes / 60,
      nightHours: overtimeNightMinutes / 60,
    );
  }

  double _calculateOrdinaryNightHours({
    required AttendanceEvent event,
    required Employee employee,
    required double workedHours,
    required double overtimeHours,
    required _PayrollTimeWindows timeWindows,
  }) {
    final checkInTime = event.checkInTime?.trim();
    final checkOutTime = event.checkOutTime?.trim();
    if (workedHours <= 0 ||
        checkInTime == null ||
        checkInTime.isEmpty ||
        checkOutTime == null ||
        checkOutTime.isEmpty) {
      return 0;
    }

    final checkInMinutes = _parseMinutesOrDefault(checkInTime, -1);
    final checkOutMinutes = _parseMinutesOrDefault(checkOutTime, -1);
    if (checkInMinutes < 0 || checkOutMinutes < 0) {
      return 0;
    }
    if (checkInMinutes == checkOutMinutes) {
      return 0;
    }

    var shiftStart = checkInMinutes;
    final scheduledStartMinute = _pickScheduledStartMinute(
      checkInMinutes: checkInMinutes,
      date: event.date,
      employee: employee,
    );
    if (scheduledStartMinute != null && shiftStart < scheduledStartMinute) {
      shiftStart = scheduledStartMinute;
    }
    var shiftEnd = checkOutMinutes;
    if (shiftEnd < shiftStart) {
      shiftEnd += _minutesPerDay;
    }

    final shiftMinutes = shiftEnd - shiftStart;
    if (shiftMinutes <= 0) {
      return 0;
    }

    var workedMinutes = (workedHours * 60).round();
    if (workedMinutes <= 0) {
      return 0;
    }
    if (workedMinutes > shiftMinutes) {
      workedMinutes = shiftMinutes;
    }

    var overtimeMinutes = (overtimeHours * 60).round();
    if (overtimeMinutes < 0) {
      overtimeMinutes = 0;
    }
    if (overtimeMinutes > workedMinutes) {
      overtimeMinutes = workedMinutes;
    }

    final breakMinutes = math.max(0, shiftMinutes - workedMinutes);
    final ordinaryWindowStart = shiftStart;
    final ordinaryWindowEnd = shiftEnd - overtimeMinutes;
    if (ordinaryWindowEnd <= ordinaryWindowStart) {
      return 0;
    }
    final ordinaryWindowMinutes = ordinaryWindowEnd - ordinaryWindowStart;

    final ordinaryNightMinutes = _countMinutesInRange(
      intervalStart: ordinaryWindowStart,
      intervalEnd: ordinaryWindowEnd,
      rangeStart: timeWindows.ordinaryNightStart,
      rangeEnd: timeWindows.ordinaryNightEnd,
    );
    if (ordinaryNightMinutes <= 0) {
      return 0;
    }

    // Sin hora exacta de descanso, se descuenta del tramo ordinario y se
    // prioriza descontarlo de horas nocturnas para evitar sobreliquidacion.
    final breakToDiscount = math.min(breakMinutes, ordinaryWindowMinutes);
    final effectiveOrdinaryNightMinutes = math.max(
      0,
      ordinaryNightMinutes - breakToDiscount,
    );

    return effectiveOrdinaryNightMinutes / 60;
  }

  double _calculateNightShiftBaseReductionHours({
    required AttendanceEvent event,
    required Employee employee,
    required double workedHours,
    required double overtimeHours,
    required _PayrollTimeWindows timeWindows,
  }) {
    final checkInTime = event.checkInTime?.trim();
    final checkOutTime = event.checkOutTime?.trim();
    if (workedHours <= 0 ||
        checkInTime == null ||
        checkInTime.isEmpty ||
        checkOutTime == null ||
        checkOutTime.isEmpty) {
      return 0;
    }

    final checkInMinutes = _parseMinutesOrDefault(checkInTime, -1);
    final checkOutMinutes = _parseMinutesOrDefault(checkOutTime, -1);
    if (checkInMinutes < 0 || checkOutMinutes < 0) {
      return 0;
    }
    if (checkInMinutes == checkOutMinutes) {
      return 0;
    }

    var shiftStart = checkInMinutes;
    final scheduledStartMinute = _pickScheduledStartMinute(
      checkInMinutes: checkInMinutes,
      date: event.date,
      employee: employee,
    );
    if (scheduledStartMinute != null && shiftStart < scheduledStartMinute) {
      shiftStart = scheduledStartMinute;
    }
    var shiftEnd = checkOutMinutes;
    if (shiftEnd < shiftStart) {
      shiftEnd += _minutesPerDay;
    }

    final shiftMinutes = shiftEnd - shiftStart;
    if (shiftMinutes <= 0) {
      return 0;
    }

    final nightMinutes = _countMinutesInRange(
      intervalStart: shiftStart,
      intervalEnd: shiftEnd,
      rangeStart: timeWindows.ordinaryNightStart,
      rangeEnd: timeWindows.ordinaryNightEnd,
    );

    final isNightShift = (nightMinutes * 2) >= shiftMinutes;
    if (!isNightShift) {
      return 0;
    }

    final ordinaryHours = math.max(
      0.0,
      workedHours - math.max(0.0, overtimeHours),
    );
    if (ordinaryHours >= _normalDayHours) {
      return 0;
    }

    return _normalDayHours - ordinaryHours;
  }

  int _countMinutesInRange({
    required int intervalStart,
    required int intervalEnd,
    required int rangeStart,
    required int rangeEnd,
  }) {
    var minutes = 0;
    for (
      var minuteCursor = intervalStart;
      minuteCursor < intervalEnd;
      minuteCursor++
    ) {
      final minuteOfDay = minuteCursor % _minutesPerDay;
      if (_isMinuteInRange(minuteOfDay, rangeStart, rangeEnd)) {
        minutes += 1;
      }
    }
    return minutes;
  }

  bool _isMinuteInRange(int minuteOfDay, int start, int end) {
    if (start == end) {
      return false;
    }
    if (start < end) {
      return minuteOfDay >= start && minuteOfDay < end;
    }
    return minuteOfDay >= start || minuteOfDay < end;
  }
}

const Set<String> _paidDayEvents = {
  'presente',
  'tardanza',
  'permiso_remunerado',
  'vacaciones',
  'paternidad',
  'duelo',
  'reposo',
};

const int _defaultBreakMinutes = 60;
const int _dayBreakMarkerMinutes = 13 * 60;
const int _overnightBreakMarkerMinutes = 25 * 60;
const int _manualBreakWindowStartMinutes = 14 * 60;
const int _manualBreakWindowEndMinutes = (14 * 60) + 30;
const int _minutesPerDay = 24 * 60;
const int _normalDayMinutes = 8 * 60;
const double _normalDayHours = 8.0;
const double _normalNightHours = 7.5;
const int _defaultOrdinaryNightStart = 20 * 60;
const int _defaultOrdinaryNightEnd = 6 * 60;
const int _defaultOvertimeDayStart = 6 * 60;
const int _defaultOvertimeDayEnd = 20 * 60;
const int _defaultOvertimeNightStart = 20 * 60;
const int _defaultOvertimeNightEnd = 6 * 60;
final RegExp _timeRegex = RegExp(r'^(\d{1,2}):(\d{2})$');

class _PayrollTimeWindows {
  const _PayrollTimeWindows({
    required this.ordinaryNightStart,
    required this.ordinaryNightEnd,
    required this.overtimeDayStart,
    required this.overtimeDayEnd,
    required this.overtimeNightStart,
    required this.overtimeNightEnd,
  });

  final int ordinaryNightStart;
  final int ordinaryNightEnd;
  final int overtimeDayStart;
  final int overtimeDayEnd;
  final int overtimeNightStart;
  final int overtimeNightEnd;
}

class _CalculatedOvertime {
  const _CalculatedOvertime({required this.dayHours, required this.nightHours});

  final double dayHours;
  final double nightHours;
}

class _AttendanceDiscountBreakdown {
  const _AttendanceDiscountBreakdown({
    this.rawLateMinutes = 0,
    this.rawEarlyMinutes = 0,
  });

  final int rawLateMinutes;
  final int rawEarlyMinutes;
}

class _WorkMetrics {
  const _WorkMetrics({
    required this.workedDays,
    required this.workedHours,
    required this.overtimeHours,
    required this.overtimeDayHours,
    required this.overtimeNightHours,
    required this.ordinaryNightHours,
    required this.nightShiftBaseReductionHours,
  });

  final double workedDays;
  final double workedHours;
  final double overtimeHours;
  final double overtimeDayHours;
  final double overtimeNightHours;
  final double ordinaryNightHours;
  final double nightShiftBaseReductionHours;
}
