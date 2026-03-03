import 'dart:math' as math;
import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../security/password_hasher.dart';
import '../security/security_constants.dart';
import 'authorization_service.dart';
import 'attendance_notes_markers.dart';
import 'company_settings_service.dart';
import 'employee_name_formatter.dart';

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
    required this.employeeNameLastFirst,
    required this.ipsEnabled,
    required this.departmentName,
  });

  final PayrollItem payrollItem;
  final String employeeName;
  final String employeeNameLastFirst;
  final bool ipsEnabled;
  final String? departmentName;
}

class PayrollPeriodStatus {
  const PayrollPeriodStatus({required this.run});

  final PayrollRun? run;

  bool get hasRun => run != null;
  bool get isLocked => run?.isLocked ?? false;
}

class PayrollService {
  PayrollService({
    required PayrollDao payrollDao,
    required EmployeesDao employeesDao,
    required AttendanceDao attendanceDao,
    required CompanySettingsService companySettingsService,
    required AuthorizationService authorizationService,
  }) : _payrollDao = payrollDao,
       _employeesDao = employeesDao,
       _attendanceDao = attendanceDao,
       _companySettingsService = companySettingsService,
       _authorizationService = authorizationService;

  final PayrollDao _payrollDao;
  final EmployeesDao _employeesDao;
  final AttendanceDao _attendanceDao;
  final CompanySettingsService _companySettingsService;
  final AuthorizationService _authorizationService;

  Future<PayrollGenerationResult> generatePayroll({
    required int companyId,
    required int year,
    required int month,
    String? notes,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.payrollGenerate,
      companyId: companyId,
    );
    _validatePeriod(companyId: companyId, year: year, month: month);
    final settings = await _companySettingsService.getOrCreateSettings(
      companyId,
    );
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final holidayDates = _companySettingsService.parseHolidayDates(
      settings.holidayDates,
    );

    final now = DateTime.now();
    final normalizedNotes = _normalizeOptional(notes);

    final existingRun = await _payrollDao.getPayrollRunByPeriod(
      companyId: companyId,
      year: year,
      month: month,
    );
    if (existingRun?.isLocked ?? false) {
      throw StateError(
        'La liquidacion del periodo esta guardada. Debe desbloquearla para regenerar.',
      );
    }

    final int runId;
    final preservedAdjustmentsByEmployeeId = <int, _PayrollAdjustments>{};
    final existingItemsByEmployeeId = <int, PayrollItem>{};
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
      final existingItems = await _payrollDao.getPayrollItemsByPeriod(
        companyId: companyId,
        year: year,
        month: month,
      );
      for (final record in existingItems) {
        existingItemsByEmployeeId[record.item.employeeId] = record.item;
        preservedAdjustmentsByEmployeeId[record.item.employeeId] =
            _PayrollAdjustments(
              otherIncome: math.max(0.0, record.item.advancesTotal),
              otherDiscount: math.max(0.0, record.item.otherDiscount),
            );
      }
      await _payrollDao.updatePayrollRun(
        existingRun.copyWith(generatedAt: now, notes: Value(normalizedNotes)),
      );
    }

    await _payrollDao.deleteItemsByRun(runId);

    final employees = await _employeesDao.getActiveEmployeesByCompany(
      companyId,
    );

    final items = <PayrollItemsCompanion>[];
    final activeEmployeeIds = <int>{};
    if (employees.isNotEmpty) {
      final attendanceEvents = await _attendanceDao.getAttendanceByMonth(
        companyId: companyId,
        year: year,
        month: month,
      );

      final attendanceByEmployee = <int, List<AttendanceEvent>>{};
      for (final event in attendanceEvents) {
        attendanceByEmployee.putIfAbsent(event.employeeId, () => []).add(event);
      }

      final timeWindows = _buildTimeWindows(settings);
      for (final employee in employees) {
        activeEmployeeIds.add(employee.id);
        final metrics = _computeWorkMetrics(
          employee: employee,
          events: attendanceByEmployee[employee.id] ?? const [],
          timeWindows: timeWindows,
          holidayDates: holidayDates,
          daysInMonth: daysInMonth,
        );
        final baseGrossWorkedDays =
            metrics.hasCompleteMonthAttendance &&
                _usesMonthlyBaseGross(employee.employeeType)
            ? math.max(0.0, _monthlyGrossBaseDays - metrics.nonRemuneratedDays)
            : metrics.workedDays;

        final effectiveOvertimeHours = employee.allowOvertime
            ? metrics.overtimeHours +
                  metrics.holidaySurchargeHours +
                  metrics.sundaySurchargeHours
            : 0.0;
        final effectiveOvertimeDayHours = employee.allowOvertime
            ? metrics.overtimeDayHours
            : 0.0;
        final effectiveOvertimeNightHours = employee.allowOvertime
            ? metrics.overtimeNightHours
            : 0.0;
        final effectiveHolidaySurchargePayHours = employee.allowOvertime
            ? metrics.holidaySurchargePayHours
            : 0.0;
        final effectiveSundaySurchargePayHours = employee.allowOvertime
            ? metrics.sundaySurchargePayHours
            : 0.0;

        final hourlyRate = computeHourlyRate(
          employeeType: employee.employeeType,
          baseSalary: employee.baseSalary,
        );
        final baseGross = _computeBaseGross(
          employeeType: employee.employeeType,
          baseSalary: employee.baseSalary,
          workedDays: baseGrossWorkedDays,
          hourlyRate: hourlyRate,
          nightShiftBaseReductionHours: metrics.nightShiftBaseReductionHours,
        );

        final overtimePay = computeOvertimePay(
          overtimeHoursDay: effectiveOvertimeDayHours,
          overtimeHoursNight: effectiveOvertimeNightHours,
          holidaySurchargeHours: effectiveHolidaySurchargePayHours,
          sundaySurchargeHours: effectiveSundaySurchargePayHours,
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
          holidayDates: holidayDates,
        );
        final gross = baseGross + overtimePay + ordinaryNightSurchargePay;
        final preservedAdjustments =
            preservedAdjustmentsByEmployeeId[employee.id] ??
            const _PayrollAdjustments();
        final otherIncome = preservedAdjustments.otherIncome;
        final otherDiscount = preservedAdjustments.otherDiscount;
        final familyBonus = _computeFamilyBonus(
          baseSalary: employee.baseSalary,
          grossPay: gross,
          childrenCount: employee.childrenCount,
          minimumWage: settings.minimumWage,
          familyBonusRate: settings.familyBonusRate,
        );
        final ipsEmployee = _computeIpsEmployee(
          ipsEnabled: employee.ipsEnabled,
          grossPay: gross,
          otherIncome: otherIncome,
          ipsEmployeeRate: settings.ipsEmployeeRate,
        );
        const ipsEmployer = 0.0;
        final embargoDiscount = _computeEmbargoDiscount(
          hasEmbargo: employee.hasEmbargo,
          embargoAmount: employee.embargoAmount,
        );
        final netPay =
            gross +
            familyBonus +
            otherIncome -
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
            advancesTotal: otherIncome,
            attendanceDiscount: Value(attendanceDiscount),
            otherDiscount: Value(otherDiscount),
            embargoAmount: Value(embargoDiscount == 0 ? null : embargoDiscount),
            embargoAccount: Value(
              embargoDiscount == 0 ? null : employee.embargoAccount,
            ),
            netPay: netPay,
          ),
        );
      }
    }

    for (final entry in existingItemsByEmployeeId.entries) {
      if (activeEmployeeIds.contains(entry.key)) {
        continue;
      }
      items.add(_companionFromExistingItem(entry.value, runId: runId));
    }

    await _payrollDao.insertPayrollItems(items);

    return PayrollGenerationResult(runId: runId, itemsGenerated: items.length);
  }

  Future<List<PayrollItemView>> listPayrollItemsByPeriod({
    required int companyId,
    required int year,
    required int month,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.payrollRead,
      companyId: companyId,
    );
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
            employeeName: employeeDisplayName(record.employee),
            employeeNameLastFirst: employeeDisplayNameLastFirst(
              record.employee,
            ),
            ipsEnabled: record.employee.ipsEnabled,
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
      return left.employeeNameLastFirst.toLowerCase().compareTo(
        right.employeeNameLastFirst.toLowerCase(),
      );
    });

    return items;
  }

  Future<PayrollPeriodStatus> getPayrollPeriodStatus({
    required int companyId,
    required int year,
    required int month,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.payrollRead,
      companyId: companyId,
    );
    _validatePeriod(companyId: companyId, year: year, month: month);

    final run = await _payrollDao.getPayrollRunByPeriod(
      companyId: companyId,
      year: year,
      month: month,
    );
    return PayrollPeriodStatus(run: run);
  }

  Future<void> lockPayrollRun({
    required int companyId,
    required int year,
    required int month,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.payrollLock,
      companyId: companyId,
    );
    _validatePeriod(companyId: companyId, year: year, month: month);

    final run = await _payrollDao.getPayrollRunByPeriod(
      companyId: companyId,
      year: year,
      month: month,
    );
    if (run == null) {
      throw StateError('Primero debe generar la liquidacion para guardarla.');
    }
    if (run.isLocked) {
      return;
    }

    final currentUser = await _authorizationService.getCurrentUser();
    if (currentUser == null) {
      throw StateError('No hay sesion activa.');
    }

    await _payrollDao.updatePayrollRun(
      run.copyWith(
        isLocked: true,
        lockedAt: Value(DateTime.now()),
        lockedByUserId: Value(currentUser.id),
      ),
    );
  }

  Future<void> unlockPayrollRun({
    required int companyId,
    required int year,
    required int month,
    required String password,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.payrollUnlock,
      companyId: companyId,
    );
    _validatePeriod(companyId: companyId, year: year, month: month);

    final normalizedPassword = password;
    if (normalizedPassword.isEmpty) {
      throw ArgumentError('La contrasena es obligatoria para desbloquear.');
    }

    final run = await _payrollDao.getPayrollRunByPeriod(
      companyId: companyId,
      year: year,
      month: month,
    );
    if (run == null) {
      throw StateError('No existe una liquidacion generada para este periodo.');
    }
    if (!run.isLocked) {
      return;
    }

    final isSuperAdmin = await _authorizationService.isSuperAdmin();
    if (!isSuperAdmin) {
      _ensureUnlockWithinAllowedWindow(year: year, month: month);
    }

    final currentUser = await _authorizationService.getCurrentUser();
    if (currentUser == null) {
      throw StateError('No hay sesion activa.');
    }
    final validPassword = PasswordHasher.verify(
      username: currentUser.username,
      password: normalizedPassword,
      expectedHash: currentUser.passwordHash,
    );
    if (!validPassword) {
      throw StateError('Contrasena incorrecta.');
    }

    await _payrollDao.updatePayrollRun(
      run.copyWith(
        isLocked: false,
        lockedAt: const Value(null),
        lockedByUserId: const Value(null),
      ),
    );
  }

  Future<bool> deletePayrollRun({
    required int companyId,
    required int year,
    required int month,
  }) async {
    await _authorizationService.ensureSuperAdmin(
      message: 'Solo SUPER_ADMIN puede borrar liquidaciones generadas.',
    );
    _validatePeriod(companyId: companyId, year: year, month: month);

    final run = await _payrollDao.getPayrollRunByPeriod(
      companyId: companyId,
      year: year,
      month: month,
    );
    if (run == null) {
      return false;
    }

    await _payrollDao.deletePayrollRunById(run.id);
    return true;
  }

  void _ensureUnlockWithinAllowedWindow({
    required int year,
    required int month,
  }) {
    final now = DateTime.now();
    final unlockDeadline = DateTime(year, month + 1, 10, 23, 59, 59, 999, 999);
    if (now.isAfter(unlockDeadline)) {
      final deadlineDay = unlockDeadline.day.toString().padLeft(2, '0');
      final deadlineMonth = unlockDeadline.month.toString().padLeft(2, '0');
      throw StateError(
        'Solo se puede desbloquear hasta el $deadlineDay/$deadlineMonth/${unlockDeadline.year}.',
      );
    }
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
    await _authorizationService.ensurePermission(
      PermissionKeys.payrollGenerate,
      companyId: item.companyId,
    );
    await _ensureRunIsUnlocked(item.payrollRunId);

    final netPay = _recalculateNetPay(item, otherDiscount: otherDiscount);
    await _payrollDao.updatePayrollItem(
      item.copyWith(otherDiscount: otherDiscount, netPay: netPay),
    );
  }

  Future<void> updateOtherIncome({
    required int payrollItemId,
    required double otherIncome,
  }) async {
    if (payrollItemId <= 0) {
      throw ArgumentError('El item de liquidacion no es valido.');
    }
    if (otherIncome < 0) {
      throw ArgumentError('Otros ingresos no puede ser negativo.');
    }

    final item = await _payrollDao.getPayrollItemById(payrollItemId);
    if (item == null) {
      throw ArgumentError('No se encontro el item de liquidacion.');
    }
    await _authorizationService.ensurePermission(
      PermissionKeys.payrollGenerate,
      companyId: item.companyId,
    );
    await _ensureRunIsUnlocked(item.payrollRunId);

    final settings = await _companySettingsService.getOrCreateSettings(
      item.companyId,
    );
    final employee = await _employeesDao.getEmployeeById(item.employeeId);
    if (employee == null) {
      throw StateError('No se encontro el empleado del item de liquidacion.');
    }
    final ipsEmployee = _computeIpsEmployee(
      ipsEnabled: employee.ipsEnabled,
      grossPay: item.grossPay,
      otherIncome: otherIncome,
      ipsEmployeeRate: settings.ipsEmployeeRate,
    );
    final netPay = _recalculateNetPay(
      item,
      otherIncome: otherIncome,
      ipsEmployee: ipsEmployee,
    );
    await _payrollDao.updatePayrollItem(
      item.copyWith(
        advancesTotal: otherIncome,
        ipsEmployee: ipsEmployee,
        netPay: netPay,
      ),
    );
  }

  Future<void> _ensureRunIsUnlocked(int payrollRunId) async {
    final run = await _payrollDao.getPayrollRunById(payrollRunId);
    if (run == null) {
      throw StateError('No se encontro la cabecera de la liquidacion.');
    }
    if (run.isLocked) {
      throw StateError('La liquidacion esta guardada y bloqueada.');
    }
  }

  PayrollItemsCompanion _companionFromExistingItem(
    PayrollItem item, {
    required int runId,
  }) {
    return PayrollItemsCompanion.insert(
      companyId: item.companyId,
      payrollRunId: runId,
      employeeId: item.employeeId,
      employeeType: item.employeeType,
      baseSalary: item.baseSalary,
      workedDays: item.workedDays,
      workedHours: item.workedHours,
      overtimeHours: item.overtimeHours,
      overtimePay: Value(item.overtimePay),
      ordinaryNightHours: Value(item.ordinaryNightHours),
      ordinaryNightSurchargePay: Value(item.ordinaryNightSurchargePay),
      grossPay: item.grossPay,
      familyBonus: Value(item.familyBonus),
      ipsEmployee: item.ipsEmployee,
      ipsEmployer: item.ipsEmployer,
      advancesTotal: item.advancesTotal,
      attendanceDiscount: Value(item.attendanceDiscount),
      otherDiscount: Value(item.otherDiscount),
      embargoAmount: Value(item.embargoAmount),
      embargoAccount: Value(item.embargoAccount),
      netPay: item.netPay,
      createdAt: Value(item.createdAt),
    );
  }

  double _recalculateNetPay(
    PayrollItem item, {
    double? otherDiscount,
    double? otherIncome,
    double? ipsEmployee,
  }) {
    final effectiveOtherDiscount = otherDiscount ?? item.otherDiscount;
    final effectiveOtherIncome = otherIncome ?? item.advancesTotal;
    final effectiveIpsEmployee = ipsEmployee ?? item.ipsEmployee;
    final embargo = item.embargoAmount ?? 0;
    return item.grossPay +
        item.familyBonus +
        effectiveOtherIncome -
        effectiveIpsEmployee -
        item.attendanceDiscount -
        effectiveOtherDiscount -
        embargo;
  }

  double _computeIpsEmployee({
    required bool ipsEnabled,
    required double grossPay,
    required double otherIncome,
    required double ipsEmployeeRate,
  }) {
    if (!ipsEnabled || ipsEmployeeRate <= 0) {
      return 0.0;
    }
    final ipsBase = math.max(0.0, grossPay + otherIncome);
    return ipsBase * ipsEmployeeRate;
  }

  _WorkMetrics _computeWorkMetrics({
    required Employee employee,
    required List<AttendanceEvent> events,
    required _PayrollTimeWindows timeWindows,
    required Set<DateTime> holidayDates,
    required int daysInMonth,
  }) {
    var workedDays = 0.0;
    var workedHours = 0.0;
    var overtimeHours = 0.0;
    var overtimeDayHours = 0.0;
    var overtimeNightHours = 0.0;
    var holidaySurchargeHours = 0.0;
    var holidaySurchargePayHours = 0.0;
    var sundaySurchargeHours = 0.0;
    var sundaySurchargePayHours = 0.0;
    var ordinaryNightHours = 0.0;
    var nightShiftBaseReductionHours = 0.0;
    final latestEventsByDay = _latestEventsByDay(events);
    final hasCompleteMonthAttendance = _hasCompleteMonthAttendance(
      employee: employee,
      latestEventsByDay: latestEventsByDay,
      daysInMonth: daysInMonth,
      holidayDates: holidayDates,
    );
    final nonRemuneratedDays = latestEventsByDay.values
        .where((event) => _nonRemuneratedEvents.contains(event.eventType))
        .length
        .toDouble();

    for (final event in events) {
      final effectiveWorkedHours = _resolveWorkedHoursForPayroll(
        event: event,
        employee: employee,
        holidayDates: holidayDates,
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

      final isHolidayPresentWithWork =
          isPresentEvent &&
          hasWorkedInEvent &&
          workedInEvent > 0 &&
          employee.allowOvertime &&
          _isHolidayNonSunday(date: event.date, holidayDates: holidayDates);
      var holidayAutomaticSurchargeApplied = false;
      if (isHolidayPresentWithWork) {
        final isHolidayOvernight = _isOvernightShift(event);
        final holidaySegments = _resolveSundayWorkedSegments(
          event: event,
          employee: employee,
          workedHours: workedInEvent,
          timeWindows: timeWindows,
        );
        // Feriados: mismo esquema de domingo 100% aplicado:
        // se paga 100% sobre toda la jornada sin canje ni recargo adicional por >8h.
        holidaySurchargeHours += workedInEvent;
        holidaySurchargePayHours += _sundayManualPayEquivalentHours(
          workedInEvent,
        );
        eventOvertimeDayHours = 0;
        eventOvertimeNightHours = 0;
        if (isHolidayOvernight && holidaySegments.nightHours > 0) {
          ordinaryNightHours += holidaySegments.nightHours * 2;
        }
        holidayAutomaticSurchargeApplied = true;
      }

      final isSundayPresentWithWork =
          isPresentEvent &&
          hasWorkedInEvent &&
          workedInEvent > 0 &&
          event.date.weekday == DateTime.sunday;
      var sundayManualSurchargeApplied = false;
      if (isSundayPresentWithWork) {
        final isSundayOvernight = _isOvernightShift(event);
        final sundaySegments = _resolveSundayWorkedSegments(
          event: event,
          employee: employee,
          workedHours: workedInEvent,
          timeWindows: timeWindows,
        );
        if (_isSundayManualSurchargeEvent(event)) {
          // Domingo con 100% aplicado:
          // - Todo el turno lleva recargo 100%.
          // - El tramo nocturno ademas lleva recargo nocturno ordinario.
          sundaySurchargeHours += workedInEvent;
          sundaySurchargePayHours += _sundayManualPayEquivalentHours(
            workedInEvent,
          );
          if (isSundayOvernight && sundaySegments.nightHours > 0) {
            ordinaryNightHours += sundaySegments.nightHours * 2;
          }
          eventOvertimeDayHours = 0;
          eventOvertimeNightHours = 0;
          sundayManualSurchargeApplied = true;
        } else {
          final sundayOvertimeHours = workedInEvent - _normalDayHours;
          if (!isSundayOvernight && sundayOvertimeHours > 0) {
            sundaySurchargeHours += sundayOvertimeHours;
            sundaySurchargePayHours +=
                sundayOvertimeHours * (1 + _sundaySurchargeRate);
            eventOvertimeDayHours = 0;
            eventOvertimeNightHours = 0;
          }
        }
      }

      overtimeDayHours += eventOvertimeDayHours;
      overtimeNightHours += eventOvertimeNightHours;
      overtimeHours += eventOvertimeDayHours + eventOvertimeNightHours;

      if (!isPresentEvent || !hasWorkedInEvent || workedInEvent <= 0) {
        continue;
      }
      if (holidayAutomaticSurchargeApplied || sundayManualSurchargeApplied) {
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
      holidaySurchargeHours: holidaySurchargeHours,
      holidaySurchargePayHours: holidaySurchargePayHours,
      sundaySurchargeHours: sundaySurchargeHours,
      sundaySurchargePayHours: sundaySurchargePayHours,
      ordinaryNightHours: ordinaryNightHours,
      nightShiftBaseReductionHours: nightShiftBaseReductionHours,
      hasCompleteMonthAttendance: hasCompleteMonthAttendance,
      nonRemuneratedDays: nonRemuneratedDays,
    );
  }

  _SundayWorkedSegments _resolveSundayWorkedSegments({
    required AttendanceEvent event,
    required Employee employee,
    required double workedHours,
    required _PayrollTimeWindows timeWindows,
  }) {
    final checkInTime = event.checkInTime?.trim();
    final checkOutTime = event.checkOutTime?.trim();
    if (workedHours <= 0 ||
        checkInTime == null ||
        checkInTime.isEmpty ||
        checkOutTime == null ||
        checkOutTime.isEmpty) {
      return _SundayWorkedSegments(dayHours: workedHours, nightHours: 0);
    }

    final checkInMinutes = _parseMinutesOrDefault(checkInTime, -1);
    final checkOutMinutes = _parseMinutesOrDefault(checkOutTime, -1);
    if (checkInMinutes < 0 ||
        checkOutMinutes < 0 ||
        checkInMinutes == checkOutMinutes) {
      return _SundayWorkedSegments(dayHours: workedHours, nightHours: 0);
    }

    var effectiveShiftStart = checkInMinutes;
    final scheduledStartMinute = _pickScheduledStartMinute(
      checkInMinutes: checkInMinutes,
      date: event.date,
      employee: employee,
    );
    if (scheduledStartMinute != null &&
        effectiveShiftStart < scheduledStartMinute) {
      effectiveShiftStart = scheduledStartMinute;
    }

    var shiftEnd = checkOutMinutes;
    if (shiftEnd < effectiveShiftStart) {
      shiftEnd += _minutesPerDay;
    }
    final shiftMinutes = shiftEnd - effectiveShiftStart;
    if (shiftMinutes <= 0) {
      return _SundayWorkedSegments(dayHours: workedHours, nightHours: 0);
    }

    var workedMinutes = (workedHours * 60).round();
    if (workedMinutes <= 0) {
      return const _SundayWorkedSegments(dayHours: 0, nightHours: 0);
    }
    if (workedMinutes > shiftMinutes) {
      workedMinutes = shiftMinutes;
    }

    final effectiveShiftEnd = effectiveShiftStart + workedMinutes;
    final dayMinutes = _countMinutesInRange(
      intervalStart: effectiveShiftStart,
      intervalEnd: effectiveShiftEnd,
      rangeStart: timeWindows.overtimeDayStart,
      rangeEnd: timeWindows.overtimeDayEnd,
    );
    final nightMinutes = math.max(0, workedMinutes - dayMinutes);
    return _SundayWorkedSegments(
      dayHours: dayMinutes / 60,
      nightHours: nightMinutes / 60,
    );
  }

  double _sundayManualPayEquivalentHours(double workedHours) {
    if (workedHours <= 0) {
      return 0;
    }
    final equivalentHours =
        (workedHours * (1 + _sundaySurchargeRate)) - _normalDayHours;
    return equivalentHours <= 0 ? 0 : equivalentHours;
  }

  bool _isOvernightShift(AttendanceEvent event) {
    final checkIn = event.checkInTime?.trim() ?? '';
    final checkOut = event.checkOutTime?.trim() ?? '';
    if (checkIn.isEmpty || checkOut.isEmpty) {
      return false;
    }
    final checkInMinutes = _parseMinutesOrDefault(checkIn, -1);
    final checkOutMinutes = _parseMinutesOrDefault(checkOut, -1);
    if (checkInMinutes < 0 || checkOutMinutes < 0) {
      return false;
    }
    return checkOutMinutes < checkInMinutes;
  }

  Map<int, AttendanceEvent> _latestEventsByDay(List<AttendanceEvent> events) {
    final latest = <int, AttendanceEvent>{};
    for (final event in events) {
      final day = event.date.day;
      final current = latest[day];
      if (current == null || event.id > current.id) {
        latest[day] = event;
      }
    }
    return latest;
  }

  bool _hasCompleteMonthAttendance({
    required Employee employee,
    required Map<int, AttendanceEvent> latestEventsByDay,
    required int daysInMonth,
    required Set<DateTime> holidayDates,
  }) {
    for (var day = 1; day <= daysInMonth; day++) {
      final event = latestEventsByDay[day];
      if (event == null) {
        return false;
      }
      if (event.eventType != 'presente') {
        continue;
      }

      final workedHours = _resolveWorkedHoursForPayroll(
        event: event,
        employee: employee,
        holidayDates: holidayDates,
      );
      if (workedHours == null || workedHours <= 0) {
        return false;
      }
    }
    return true;
  }

  bool _usesMonthlyBaseGross(String employeeType) {
    return employeeType == 'mensual' || employeeType == 'servicio';
  }

  double? _resolveWorkedHoursForPayroll({
    required AttendanceEvent event,
    required Employee employee,
    required Set<DateTime> holidayDates,
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
      holidayDates: holidayDates,
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
    required Set<DateTime> holidayDates,
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

    final effectiveBreakMinutes =
        _isBreakDiscountExemptDay(date: date, holidayDates: holidayDates)
        ? 0
        : _effectiveBreakMinutesForSchedule(
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
    double holidaySurchargeHours = 0,
    double sundaySurchargeHours = 0,
    required double hourlyRate,
    required double overtimeDayRate,
    required double overtimeNightRate,
  }) {
    final dayPay = overtimeHoursDay * hourlyRate * (1 + overtimeDayRate);
    final nightPay = overtimeHoursNight * hourlyRate * (1 + overtimeNightRate);
    final holidaySurchargePay =
        holidaySurchargeHours * hourlyRate * _holidaySurchargeRate;
    final sundaySurchargePay =
        sundaySurchargeHours * hourlyRate * _sundaySurchargeRate;
    return dayPay + nightPay + holidaySurchargePay + sundaySurchargePay;
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
    required Set<DateTime> holidayDates,
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
      if (employee.allowOvertime) {
        discountedMinutes += _computeOvertimeAttendanceDeficitMinutes(
          event: event,
          employee: employee,
          holidayDates: holidayDates,
        );
        continue;
      }

      final breakdown = _computeDiscountBreakdownForEvent(
        event: event,
        employee: employee,
        holidayDates: holidayDates,
      );

      var discountedLateMinutes = 0;
      final rawLateMinutes = breakdown.rawLateMinutes;
      if (rawLateMinutes > toleranceMinutes) {
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

  int _computeOvertimeAttendanceDeficitMinutes({
    required AttendanceEvent event,
    required Employee employee,
    required Set<DateTime> holidayDates,
  }) {
    if (event.eventType != 'presente' && event.eventType != 'tardanza') {
      return 0;
    }

    final workedHoursFromTimes = _calculateWorkedHoursFromTimes(
      checkInTime: event.checkInTime,
      checkOutTime: event.checkOutTime,
      breakMinutes: event.breakMinutes ?? _defaultBreakMinutes,
      employee: employee,
      date: event.date,
      holidayDates: holidayDates,
    );

    double? workedHours = workedHoursFromTimes ?? event.hoursWorked;
    if (workedHours == null && event.eventType == 'tardanza') {
      final lateMinutes = math.max(0, event.minutesLate ?? 0);
      workedHours =
          (_normalDayMinutes - lateMinutes).clamp(0, _normalDayMinutes) / 60;
    }
    if (workedHours == null || workedHours <= 0) {
      return 0;
    }

    final workedMinutes = (workedHours * 60).round();
    final deficitMinutes = _normalDayMinutes - workedMinutes;
    return deficitMinutes > 0 ? deficitMinutes : 0;
  }

  _AttendanceDiscountBreakdown _computeDiscountBreakdownForEvent({
    required AttendanceEvent event,
    required Employee employee,
    required Set<DateTime> holidayDates,
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

    final fallbackLateMinutes = math.max(0, event.minutesLate ?? 0);
    if (checkInMinutes < 0) {
      if (event.eventType == 'tardanza' && fallbackLateMinutes > 0) {
        return _AttendanceDiscountBreakdown(
          rawLateMinutes: fallbackLateMinutes,
        );
      }
      return const _AttendanceDiscountBreakdown();
    }

    final scheduledStartMinute = _pickScheduledStartMinute(
      checkInMinutes: checkInMinutes,
      date: event.date,
      employee: employee,
    );
    if (scheduledStartMinute == null) {
      if (event.eventType == 'tardanza' && fallbackLateMinutes > 0) {
        return _AttendanceDiscountBreakdown(
          rawLateMinutes: fallbackLateMinutes,
        );
      }
      return const _AttendanceDiscountBreakdown();
    }

    final computedLateMinutes = math.max(
      0,
      checkInMinutes - scheduledStartMinute,
    );
    final rawLateMinutes = event.eventType == 'tardanza'
        ? math.max(computedLateMinutes, fallbackLateMinutes)
        : computedLateMinutes;
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
    final effectiveBreakMinutes =
        _isBreakDiscountExemptDay(date: event.date, holidayDates: holidayDates)
        ? 0
        : _effectiveBreakMinutesForSchedule(
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
    final normalLimit = event.date.weekday == DateTime.sunday
        ? _normalDayHours
        : (isNightShift ? _normalNightHours : _normalDayHours);
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

  bool _isHolidayNonSunday({
    required DateTime date,
    required Set<DateTime> holidayDates,
  }) {
    if (date.weekday == DateTime.sunday) {
      return false;
    }
    final normalized = DateTime(date.year, date.month, date.day);
    return holidayDates.contains(normalized);
  }

  bool _isBreakDiscountExemptDay({
    required DateTime date,
    required Set<DateTime> holidayDates,
  }) {
    return date.weekday == DateTime.sunday ||
        _isHolidayNonSunday(date: date, holidayDates: holidayDates);
  }

  bool _isSundayManualSurchargeEvent(AttendanceEvent event) {
    if (event.eventType != 'presente' ||
        event.date.weekday != DateTime.sunday) {
      return false;
    }
    return hasSundaySurcharge100Marker(event.notes);
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

const Set<String> _nonRemuneratedEvents = {'permiso_no_remunerado', 'ausente'};

const int _defaultBreakMinutes = 60;
const int _dayBreakMarkerMinutes = 13 * 60;
const int _overnightBreakMarkerMinutes = 25 * 60;
const int _manualBreakWindowStartMinutes = 14 * 60;
const int _manualBreakWindowEndMinutes = (14 * 60) + 30;
const int _minutesPerDay = 24 * 60;
const double _monthlyGrossBaseDays = 30.0;
const int _normalDayMinutes = 8 * 60;
const double _normalDayHours = 8.0;
const double _normalNightHours = 7.5;
const int _defaultOrdinaryNightStart = 20 * 60;
const int _defaultOrdinaryNightEnd = 6 * 60;
const int _defaultOvertimeDayStart = 6 * 60;
const int _defaultOvertimeDayEnd = 20 * 60;
const int _defaultOvertimeNightStart = 20 * 60;
const int _defaultOvertimeNightEnd = 6 * 60;
const double _holidaySurchargeRate = 1.0;
const double _sundaySurchargeRate = 1.0;
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

class _SundayWorkedSegments {
  const _SundayWorkedSegments({
    required this.dayHours,
    required this.nightHours,
  });

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
    required this.holidaySurchargeHours,
    required this.holidaySurchargePayHours,
    required this.sundaySurchargeHours,
    required this.sundaySurchargePayHours,
    required this.ordinaryNightHours,
    required this.nightShiftBaseReductionHours,
    required this.hasCompleteMonthAttendance,
    required this.nonRemuneratedDays,
  });

  final double workedDays;
  final double workedHours;
  final double overtimeHours;
  final double overtimeDayHours;
  final double overtimeNightHours;
  final double holidaySurchargeHours;
  final double holidaySurchargePayHours;
  final double sundaySurchargeHours;
  final double sundaySurchargePayHours;
  final double ordinaryNightHours;
  final double nightShiftBaseReductionHours;
  final bool hasCompleteMonthAttendance;
  final double nonRemuneratedDays;
}

class _PayrollAdjustments {
  const _PayrollAdjustments({this.otherIncome = 0, this.otherDiscount = 0});

  final double otherIncome;
  final double otherDiscount;
}
