import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../security/security_constants.dart';
import 'authorization_service.dart';

class AttendanceService {
  AttendanceService(
    this._attendanceDao,
    this._employeesDao,
    this._payrollDao,
    this._authorizationService,
  );

  final AttendanceDao _attendanceDao;
  final EmployeesDao _employeesDao;
  final PayrollDao _payrollDao;
  final AuthorizationService _authorizationService;

  Future<int> createAttendanceEvent({
    required int companyId,
    required int employeeId,
    required DateTime date,
    required String eventType,
    int? minutesLate,
    double? hoursWorked,
    double? overtimeHours,
    String? overtimeType,
    String? checkInTime,
    String? checkOutTime,
    int? breakMinutes,
    String? notes,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.attendanceEdit,
      companyId: companyId,
    );
    await _ensurePayrollMonthUnlocked(companyId: companyId, date: date);

    final input = await _sanitizeAndValidate(
      companyId: companyId,
      employeeId: employeeId,
      date: date,
      eventType: eventType,
      minutesLate: minutesLate,
      hoursWorked: hoursWorked,
      overtimeHours: overtimeHours,
      overtimeType: overtimeType,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      breakMinutes: breakMinutes,
      notes: notes,
    );

    return _attendanceDao.insertAttendanceEvent(
      AttendanceEventsCompanion.insert(
        companyId: input.companyId,
        employeeId: input.employeeId,
        date: input.date,
        eventType: input.eventType,
        minutesLate: Value(input.minutesLate),
        hoursWorked: Value(input.hoursWorked),
        overtimeHours: Value(input.overtimeHours),
        overtimeType: Value(input.overtimeType),
        checkInTime: Value(input.checkInTime),
        checkOutTime: Value(input.checkOutTime),
        breakMinutes: Value(input.breakMinutes),
        notes: Value(input.notes),
      ),
    );
  }

  Future<bool> updateAttendanceEvent({
    required AttendanceEvent currentEvent,
    required int employeeId,
    required DateTime date,
    required String eventType,
    int? minutesLate,
    double? hoursWorked,
    double? overtimeHours,
    String? overtimeType,
    String? checkInTime,
    String? checkOutTime,
    int? breakMinutes,
    String? notes,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.attendanceEdit,
      companyId: currentEvent.companyId,
    );
    await _ensurePayrollMonthUnlocked(
      companyId: currentEvent.companyId,
      date: currentEvent.date,
    );
    final isSamePeriod =
        currentEvent.date.year == date.year &&
        currentEvent.date.month == date.month;
    if (!isSamePeriod) {
      await _ensurePayrollMonthUnlocked(
        companyId: currentEvent.companyId,
        date: date,
      );
    }

    final input = await _sanitizeAndValidate(
      companyId: currentEvent.companyId,
      employeeId: employeeId,
      date: date,
      eventType: eventType,
      minutesLate: minutesLate,
      hoursWorked: hoursWorked,
      overtimeHours: overtimeHours,
      overtimeType: overtimeType,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      breakMinutes: breakMinutes,
      notes: notes,
    );

    final updatedEvent = currentEvent.copyWith(
      employeeId: input.employeeId,
      date: input.date,
      eventType: input.eventType,
      minutesLate: Value(input.minutesLate),
      hoursWorked: Value(input.hoursWorked),
      overtimeHours: Value(input.overtimeHours),
      overtimeType: Value(input.overtimeType),
      checkInTime: Value(input.checkInTime),
      checkOutTime: Value(input.checkOutTime),
      breakMinutes: Value(input.breakMinutes),
      notes: Value(input.notes),
    );

    return _attendanceDao.updateAttendanceEvent(updatedEvent);
  }

  Future<void> upsertDailyAttendance({
    required int companyId,
    required int employeeId,
    required DateTime date,
    String? checkInTime,
    String? checkOutTime,
    int? breakMinutes,
    String? eventType,
    String? notes,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.attendanceEdit,
      companyId: companyId,
    );
    await _ensurePayrollMonthUnlocked(companyId: companyId, date: date);

    if (companyId <= 0 || employeeId <= 0) {
      throw ArgumentError('La empresa o empleado no es valido.');
    }

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedEventType = _normalizeOptional(eventType)?.toLowerCase();
    if (normalizedEventType != null &&
        !_allowedDailyUpsertEvents.contains(normalizedEventType)) {
      throw ArgumentError('El tipo de evento no es valido para este registro.');
    }
    final effectiveEventType = normalizedEventType ?? 'presente';
    final hasNotesInput = notes != null;
    final normalizedNotes = _normalizeOptional(notes);
    final normalizedCheckInTime = _normalizeOptionalTime(checkInTime);
    final normalizedCheckOutTime = _normalizeOptionalTime(checkOutTime);
    final normalizedBreakMinutes = _normalizeBreakMinutes(breakMinutes);

    final employee = await _employeesDao.getEmployeeById(employeeId);
    if (employee == null || employee.companyId != companyId) {
      throw ArgumentError('El empleado no pertenece a la empresa activa.');
    }

    final currentEvent = await _attendanceDao.getAttendanceByEmployeeAndDate(
      companyId: companyId,
      employeeId: employeeId,
      date: normalizedDate,
    );

    final effectiveNotes = hasNotesInput
        ? normalizedNotes
        : currentEvent?.notes;

    if (effectiveEventType != 'presente') {
      if (currentEvent == null) {
        await createAttendanceEvent(
          companyId: companyId,
          employeeId: employeeId,
          date: normalizedDate,
          eventType: effectiveEventType,
          minutesLate: null,
          hoursWorked: null,
          overtimeHours: null,
          overtimeType: null,
          checkInTime: null,
          checkOutTime: null,
          breakMinutes: null,
          notes: effectiveNotes,
        );
        return;
      }

      await updateAttendanceEvent(
        currentEvent: currentEvent,
        employeeId: employeeId,
        date: normalizedDate,
        eventType: effectiveEventType,
        minutesLate: null,
        hoursWorked: null,
        overtimeHours: null,
        overtimeType: null,
        checkInTime: null,
        checkOutTime: null,
        breakMinutes: null,
        notes: effectiveNotes,
      );
      return;
    }

    if (normalizedCheckInTime == null && normalizedCheckOutTime == null) {
      if (currentEvent != null &&
          _dailyUpsertRemovableEventTypes.contains(currentEvent.eventType)) {
        await _attendanceDao.deleteAttendanceEvent(currentEvent.id);
      }
      return;
    }

    final configuredBreakMinutes =
        normalizedBreakMinutes ??
        currentEvent?.breakMinutes ??
        _defaultBreakMinutes;
    final effectiveBreakMinutes = _effectiveBreakMinutesForSchedule(
      checkInTime: normalizedCheckInTime,
      checkOutTime: normalizedCheckOutTime,
      breakMinutes: configuredBreakMinutes,
    );
    final scheduledStartMinute = _pickScheduledStartMinute(
      checkInTime: normalizedCheckInTime,
      date: normalizedDate,
      employee: employee,
    );
    final minutesLate = _calculateMinutesLate(
      checkInTime: normalizedCheckInTime,
      scheduledStartMinute: scheduledStartMinute,
    );

    final calculatedHours = _calculateWorkedHours(
      checkInTime: normalizedCheckInTime,
      checkOutTime: normalizedCheckOutTime,
      breakMinutes: effectiveBreakMinutes,
      scheduledStartMinute: scheduledStartMinute,
    );

    if (normalizedCheckInTime != null &&
        normalizedCheckOutTime != null &&
        (calculatedHours == null || calculatedHours <= 0)) {
      throw ArgumentError('La jornada debe ser mayor al descanso configurado.');
    }

    if (currentEvent == null) {
      await createAttendanceEvent(
        companyId: companyId,
        employeeId: employeeId,
        date: normalizedDate,
        eventType: 'presente',
        minutesLate: minutesLate,
        hoursWorked: calculatedHours,
        overtimeHours: null,
        overtimeType: null,
        checkInTime: normalizedCheckInTime,
        checkOutTime: normalizedCheckOutTime,
        breakMinutes: effectiveBreakMinutes,
        notes: effectiveNotes,
      );
      return;
    }

    await updateAttendanceEvent(
      currentEvent: currentEvent,
      employeeId: employeeId,
      date: normalizedDate,
      eventType: 'presente',
      minutesLate: minutesLate,
      hoursWorked: calculatedHours,
      overtimeHours: null,
      overtimeType: null,
      checkInTime: normalizedCheckInTime,
      checkOutTime: normalizedCheckOutTime,
      breakMinutes: effectiveBreakMinutes,
      notes: effectiveNotes,
    );
  }

  Future<void> upsertDailyAttendanceFromImport({
    required int companyId,
    required int employeeId,
    required DateTime date,
    String? checkInTime,
    String? checkOutTime,
    int? breakMinutes,
    String? eventType,
    String? notes,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.attendanceImportClock,
      companyId: companyId,
    );
    await upsertDailyAttendance(
      companyId: companyId,
      employeeId: employeeId,
      date: date,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      breakMinutes: breakMinutes,
      eventType: eventType,
      notes: notes,
    );
  }

  Future<int> deleteAttendanceEvent(int eventId) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.attendanceDelete,
    );
    if (eventId <= 0) {
      throw ArgumentError('El evento no es valido.');
    }

    final event = await _attendanceDao.getAttendanceEventById(eventId);
    if (event != null) {
      await _ensurePayrollMonthUnlocked(
        companyId: event.companyId,
        date: event.date,
      );
    }

    return _attendanceDao.deleteAttendanceEvent(eventId);
  }

  Future<List<AttendanceEvent>> listAttendanceByMonth({
    required int companyId,
    required int year,
    required int month,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.attendanceRead,
      companyId: companyId,
    );
    _validatePeriod(companyId: companyId, year: year, month: month);
    return _attendanceDao.getAttendanceByMonth(
      companyId: companyId,
      year: year,
      month: month,
    );
  }

  Future<bool> isAttendancePeriodLocked({
    required int companyId,
    required int year,
    required int month,
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.attendanceRead,
      companyId: companyId,
    );
    _validatePeriod(companyId: companyId, year: year, month: month);

    final run = await _payrollDao.getPayrollRunByPeriod(
      companyId: companyId,
      year: year,
      month: month,
    );
    return run?.isLocked ?? false;
  }

  Future<_AttendanceInput> _sanitizeAndValidate({
    required int companyId,
    required int employeeId,
    required DateTime date,
    required String eventType,
    int? minutesLate,
    double? hoursWorked,
    double? overtimeHours,
    String? overtimeType,
    String? checkInTime,
    String? checkOutTime,
    int? breakMinutes,
    String? notes,
  }) async {
    if (companyId <= 0 || employeeId <= 0) {
      throw ArgumentError('La empresa o empleado no es valido.');
    }

    final normalizedType = eventType.trim().toLowerCase();
    if (!_allowedAttendanceEvents.contains(normalizedType)) {
      throw ArgumentError('El tipo de evento no es valido.');
    }

    if (minutesLate != null && minutesLate < 0) {
      throw ArgumentError('Los minutos de tardanza no pueden ser negativos.');
    }

    if (hoursWorked != null && hoursWorked < 0) {
      throw ArgumentError('Las horas trabajadas no pueden ser negativas.');
    }

    if (overtimeHours != null && overtimeHours < 0) {
      throw ArgumentError('Las horas extra no pueden ser negativas.');
    }

    final normalizedBreakMinutes = _normalizeBreakMinutes(breakMinutes);

    final employee = await _employeesDao.getEmployeeById(employeeId);
    if (employee == null || employee.companyId != companyId) {
      throw ArgumentError('El empleado no pertenece a la empresa activa.');
    }

    final normalizedOvertimeHours =
        (overtimeHours == null || overtimeHours <= 0) ? null : overtimeHours;
    final normalizedOvertimeType = _normalizeOptional(
      overtimeType,
    )?.toLowerCase();

    if (normalizedOvertimeType != null &&
        !_allowedOvertimeTypes.contains(normalizedOvertimeType)) {
      throw ArgumentError('El tipo de hora extra no es valido.');
    }

    if (normalizedOvertimeHours != null && normalizedOvertimeType == null) {
      throw ArgumentError(
        'Debe seleccionar tipo de hora extra cuando hay horas extra.',
      );
    }

    if (!employee.allowOvertime && normalizedOvertimeHours != null) {
      throw ArgumentError('El empleado seleccionado no permite horas extra.');
    }

    final normalizedCheckInTime = _normalizeOptionalTime(checkInTime);
    final normalizedCheckOutTime = _normalizeOptionalTime(checkOutTime);

    if (normalizedCheckInTime != null && normalizedCheckOutTime != null) {
      final checkInMinutes = _minutesFromTime(normalizedCheckInTime);
      final checkOutMinutes = _minutesFromTime(normalizedCheckOutTime);
      if (checkOutMinutes == checkInMinutes) {
        throw ArgumentError('La hora de salida no puede ser igual a entrada.');
      }
    }

    final normalizedNotes = _normalizeOptional(notes);

    return _AttendanceInput(
      companyId: companyId,
      employeeId: employeeId,
      date: DateTime(date.year, date.month, date.day),
      eventType: normalizedType,
      minutesLate: minutesLate,
      hoursWorked: hoursWorked,
      overtimeHours: normalizedOvertimeHours,
      overtimeType: normalizedOvertimeHours == null
          ? null
          : normalizedOvertimeType,
      checkInTime: normalizedCheckInTime,
      checkOutTime: normalizedCheckOutTime,
      breakMinutes: normalizedBreakMinutes,
      notes: normalizedNotes,
    );
  }

  int? _calculateMinutesLate({
    required String? checkInTime,
    required int? scheduledStartMinute,
  }) {
    if (checkInTime == null || scheduledStartMinute == null) {
      return null;
    }

    final checkInMinutes = _minutesFromTime(checkInTime);
    final lateMinutes = checkInMinutes - scheduledStartMinute;
    if (lateMinutes <= 0) {
      return null;
    }
    return lateMinutes;
  }

  double? _calculateWorkedHours({
    required String? checkInTime,
    required String? checkOutTime,
    int breakMinutes = 0,
    int? scheduledStartMinute,
  }) {
    if (checkInTime == null || checkOutTime == null) {
      return null;
    }

    var effectiveCheckInMinutes = _minutesFromTime(checkInTime);
    if (scheduledStartMinute != null &&
        effectiveCheckInMinutes < scheduledStartMinute) {
      effectiveCheckInMinutes = scheduledStartMinute;
    }

    var workedMinutes =
        _minutesFromTime(checkOutTime) - effectiveCheckInMinutes;
    if (workedMinutes < 0) {
      workedMinutes += _minutesPerDay;
    }
    if (workedMinutes == 0) {
      return null;
    }

    final netMinutes = workedMinutes - breakMinutes;
    if (netMinutes <= 0) {
      return null;
    }

    return netMinutes / 60;
  }

  int _effectiveBreakMinutesForSchedule({
    required String? checkInTime,
    required String? checkOutTime,
    required int breakMinutes,
  }) {
    if (checkInTime == null || checkOutTime == null) {
      return 0;
    }

    final checkOutMinutes = _minutesFromTime(checkOutTime);
    final checkInMinutes = _minutesFromTime(checkInTime);
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
    required String? checkInTime,
    required DateTime date,
    required Employee employee,
  }) {
    if (checkInTime == null) {
      return null;
    }

    if (!employee.allowOvertime && date.weekday == DateTime.saturday) {
      final saturday = employee.workStartTimeSaturday?.trim() ?? '';
      final saturdayStart = _parseTimeToMinutes(saturday);
      if (saturdayStart != null) {
        return saturdayStart;
      }
    }

    final checkInMinutes = _minutesFromTime(checkInTime);
    final candidates = _employeeScheduledStartMinutes(employee);
    if (candidates.isEmpty) {
      return null;
    }

    var selected = candidates.first;
    var selectedDistance = (selected - checkInMinutes).abs();

    for (final candidate in candidates.skip(1)) {
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
    final parsed1 = _parseTimeToMinutes(employee.workStartTime1);
    final parsed2 = _parseTimeToMinutes(employee.workStartTime2);
    final parsed3 = _parseTimeToMinutes(employee.workStartTime3);

    if (parsed1 != null) {
      starts.add(parsed1);
    }
    if (parsed2 != null && !starts.contains(parsed2)) {
      starts.add(parsed2);
    }
    if (parsed3 != null && !starts.contains(parsed3)) {
      starts.add(parsed3);
    }

    return starts;
  }

  int? _parseTimeToMinutes(String value) {
    final parsed = _parseTimeParts(value);
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

  int _minutesFromTime(String value) {
    final segments = value.split(':');
    final hour = int.parse(segments[0]);
    final minute = int.parse(segments[1]);
    return (hour * 60) + minute;
  }

  String? _normalizeOptionalTime(String? value) {
    final normalized = _normalizeOptional(value);
    if (normalized == null) {
      return null;
    }

    final parsed = _parseTimeParts(normalized);
    if (parsed == null) {
      throw ArgumentError(
        'Formato de hora invalido. Use HH:mm, HH.mm, HHmm o HH.',
      );
    }

    final hour = parsed.$1;
    final minute = parsed.$2;
    if (hour > 23 || minute > 59) {
      throw ArgumentError('La hora ingresada no es valida.');
    }

    final normalizedHour = hour.toString().padLeft(2, '0');
    final normalizedMinute = minute.toString().padLeft(2, '0');
    return '$normalizedHour:$normalizedMinute';
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

  int? _normalizeBreakMinutes(int? value) {
    if (value == null) {
      return null;
    }

    if (value < 0) {
      throw ArgumentError('El descanso no puede ser negativo.');
    }

    return value;
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

  Future<void> _ensurePayrollMonthUnlocked({
    required int companyId,
    required DateTime date,
  }) async {
    final run = await _payrollDao.getPayrollRunByPeriod(
      companyId: companyId,
      year: date.year,
      month: date.month,
    );
    if (run?.isLocked ?? false) {
      final month = date.month.toString().padLeft(2, '0');
      throw ArgumentError(
        'No se puede editar asistencia de $month/${date.year} porque la liquidacion esta guardada y bloqueada.',
      );
    }
  }
}

const Set<String> _allowedAttendanceEvents = {
  'presente',
  'ausente',
  'permiso_remunerado',
  'permiso_no_remunerado',
  'vacaciones',
  'paternidad',
  'duelo',
  'reposo',
  'tardanza',
};

const Set<String> _allowedDailyUpsertEvents = {
  'presente',
  'permiso_remunerado',
  'permiso_no_remunerado',
};

const Set<String> _dailyUpsertRemovableEventTypes = {
  'presente',
  'permiso_remunerado',
  'permiso_no_remunerado',
};

const Set<String> _allowedOvertimeTypes = {'diurna', 'nocturna'};
const int _defaultBreakMinutes = 60;
const int _dayBreakMarkerMinutes = 13 * 60;
const int _overnightBreakMarkerMinutes = 25 * 60;
const int _manualBreakWindowStartMinutes = 14 * 60;
const int _manualBreakWindowEndMinutes = (14 * 60) + 30;
const int _minutesPerDay = 24 * 60;
final RegExp _timeRegExp = RegExp(r'^(\\d{1,2})[:.,](\\d{2})$');

class _AttendanceInput {
  const _AttendanceInput({
    required this.companyId,
    required this.employeeId,
    required this.date,
    required this.eventType,
    required this.minutesLate,
    required this.hoursWorked,
    required this.overtimeHours,
    required this.overtimeType,
    required this.checkInTime,
    required this.checkOutTime,
    required this.breakMinutes,
    required this.notes,
  });

  final int companyId;
  final int employeeId;
  final DateTime date;
  final String eventType;
  final int? minutesLate;
  final double? hoursWorked;
  final double? overtimeHours;
  final String? overtimeType;
  final String? checkInTime;
  final String? checkOutTime;
  final int? breakMinutes;
  final String? notes;
}
