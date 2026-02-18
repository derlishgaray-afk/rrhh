import 'package:drift/drift.dart';

import '../data/database/app_database.dart';

class EmployeesService {
  EmployeesService(this._employeesDao, this._departmentsDao);

  final EmployeesDao _employeesDao;
  final DepartmentsDao _departmentsDao;

  Future<int> createEmployee({
    required int companyId,
    required int? departmentId,
    required int? sectorId,
    required String? jobTitle,
    required String? workLocation,
    required String fullName,
    required String documentNumber,
    required DateTime hireDate,
    required String employeeType,
    required double baseSalary,
    bool? ipsEnabled,
    int childrenCount = 0,
    bool allowOvertime = true,
    bool biometricClockEnabled = true,
    bool hasEmbargo = false,
    String? embargoAccount,
    double? embargoAmount,
    String? phone,
    String? address,
    String? workStartTime1,
    String? workStartTime2,
    String? workStartTime3,
    String? workStartTimeSaturday,
    String? workEndTimeSaturday,
    bool active = true,
  }) async {
    final input = await _sanitizeAndValidate(
      companyId: companyId,
      departmentId: departmentId,
      sectorId: sectorId,
      jobTitle: jobTitle,
      workLocation: workLocation,
      fullName: fullName,
      documentNumber: documentNumber,
      hireDate: hireDate,
      employeeType: employeeType,
      baseSalary: baseSalary,
      ipsEnabled: ipsEnabled,
      childrenCount: childrenCount,
      allowOvertime: allowOvertime,
      biometricClockEnabled: biometricClockEnabled,
      hasEmbargo: hasEmbargo,
      embargoAccount: embargoAccount,
      embargoAmount: embargoAmount,
      phone: phone,
      address: address,
      workStartTime1: workStartTime1,
      workStartTime2: workStartTime2,
      workStartTime3: workStartTime3,
      workStartTimeSaturday: workStartTimeSaturday,
      workEndTimeSaturday: workEndTimeSaturday,
      active: active,
      excludeEmployeeId: null,
    );

    return _employeesDao.insertEmployee(
      EmployeesCompanion.insert(
        companyId: input.companyId,
        departmentId: Value(input.departmentId),
        sectorId: Value(input.sectorId),
        jobTitle: Value(input.jobTitle),
        workLocation: Value(input.workLocation),
        fullName: input.fullName,
        documentNumber: input.documentNumber,
        hireDate: input.hireDate,
        employeeType: input.employeeType,
        baseSalary: input.baseSalary,
        ipsEnabled: Value(input.ipsEnabled),
        childrenCount: Value(input.childrenCount),
        allowOvertime: Value(input.allowOvertime),
        biometricClockEnabled: Value(input.biometricClockEnabled),
        hasEmbargo: Value(input.hasEmbargo),
        embargoAccount: Value(input.embargoAccount),
        embargoAmount: Value(input.embargoAmount),
        phone: Value(input.phone),
        address: Value(input.address),
        workStartTime1: Value(input.workStartTime1),
        workStartTime2: Value(input.workStartTime2),
        workStartTime3: Value(input.workStartTime3),
        workStartTimeSaturday: Value(input.workStartTimeSaturday),
        workEndTimeSaturday: Value(input.workEndTimeSaturday),
        active: Value(input.active),
      ),
    );
  }

  Future<bool> updateEmployee({
    required Employee currentEmployee,
    required int? departmentId,
    required int? sectorId,
    required String? jobTitle,
    required String? workLocation,
    required String fullName,
    required String documentNumber,
    required DateTime hireDate,
    required String employeeType,
    required double baseSalary,
    required bool ipsEnabled,
    required int childrenCount,
    required bool allowOvertime,
    required bool biometricClockEnabled,
    required bool hasEmbargo,
    String? embargoAccount,
    double? embargoAmount,
    String? phone,
    String? address,
    required String workStartTime1,
    required String workStartTime2,
    required String workStartTime3,
    String? workStartTimeSaturday,
    String? workEndTimeSaturday,
    required bool active,
  }) async {
    final input = await _sanitizeAndValidate(
      companyId: currentEmployee.companyId,
      departmentId: departmentId,
      sectorId: sectorId,
      jobTitle: jobTitle,
      workLocation: workLocation,
      fullName: fullName,
      documentNumber: documentNumber,
      hireDate: hireDate,
      employeeType: employeeType,
      baseSalary: baseSalary,
      ipsEnabled: ipsEnabled,
      childrenCount: childrenCount,
      allowOvertime: allowOvertime,
      biometricClockEnabled: biometricClockEnabled,
      hasEmbargo: hasEmbargo,
      embargoAccount: embargoAccount,
      embargoAmount: embargoAmount,
      phone: phone,
      address: address,
      workStartTime1: workStartTime1,
      workStartTime2: workStartTime2,
      workStartTime3: workStartTime3,
      workStartTimeSaturday: workStartTimeSaturday,
      workEndTimeSaturday: workEndTimeSaturday,
      active: active,
      excludeEmployeeId: currentEmployee.id,
    );

    final updatedEmployee = currentEmployee.copyWith(
      departmentId: Value(input.departmentId),
      sectorId: Value(input.sectorId),
      jobTitle: Value(input.jobTitle),
      workLocation: Value(input.workLocation),
      fullName: input.fullName,
      documentNumber: input.documentNumber,
      hireDate: input.hireDate,
      employeeType: input.employeeType,
      baseSalary: input.baseSalary,
      ipsEnabled: input.ipsEnabled,
      childrenCount: input.childrenCount,
      allowOvertime: input.allowOvertime,
      biometricClockEnabled: input.biometricClockEnabled,
      hasEmbargo: input.hasEmbargo,
      embargoAccount: Value(input.embargoAccount),
      embargoAmount: Value(input.embargoAmount),
      phone: Value(input.phone),
      address: Value(input.address),
      workStartTime1: input.workStartTime1,
      workStartTime2: input.workStartTime2,
      workStartTime3: input.workStartTime3,
      workStartTimeSaturday: Value(input.workStartTimeSaturday),
      workEndTimeSaturday: Value(input.workEndTimeSaturday),
      active: input.active,
    );

    return _employeesDao.updateEmployee(updatedEmployee);
  }

  Future<int> deleteEmployee(int employeeId) {
    if (employeeId <= 0) {
      throw ArgumentError('El id del empleado no es valido.');
    }
    return _employeesDao.deleteEmployee(employeeId);
  }

  Future<List<Employee>> listEmployeesByCompany(int companyId) {
    return _employeesDao.getEmployeesByCompany(companyId);
  }

  Future<List<Employee>> listEmployeesAllCompanies() {
    return _employeesDao.getEmployees();
  }

  Future<List<Employee>> listActiveEmployeesByCompany(int companyId) {
    return _employeesDao.getActiveEmployeesByCompany(companyId);
  }

  Future<List<Employee>> searchEmployeesByName(int companyId, String query) {
    return _employeesDao.searchEmployeesByName(companyId, query);
  }

  Future<Employee?> findEmployeeByDocumentInCompany({
    required int companyId,
    required String documentNumber,
    int? excludeEmployeeId,
  }) async {
    if (companyId <= 0) {
      throw ArgumentError('La empresa seleccionada no es valida.');
    }

    final normalizedTarget = _normalizeDocumentForLookup(documentNumber);
    if (normalizedTarget == null) {
      return null;
    }

    final employees = await _employeesDao.getEmployeesByCompany(companyId);
    for (final employee in employees) {
      if (excludeEmployeeId != null && employee.id == excludeEmployeeId) {
        continue;
      }

      final normalizedEmployeeDocument = _normalizeDocumentForLookup(
        employee.documentNumber,
      );
      if (normalizedEmployeeDocument == null) {
        continue;
      }

      if (normalizedEmployeeDocument == normalizedTarget) {
        return employee;
      }
    }

    return null;
  }

  Future<_EmployeeInput> _sanitizeAndValidate({
    required int companyId,
    required int? departmentId,
    required int? sectorId,
    required String? jobTitle,
    required String? workLocation,
    required String fullName,
    required String documentNumber,
    required DateTime hireDate,
    required String employeeType,
    required double baseSalary,
    required bool? ipsEnabled,
    required int childrenCount,
    required bool allowOvertime,
    required bool biometricClockEnabled,
    required bool hasEmbargo,
    String? embargoAccount,
    double? embargoAmount,
    String? phone,
    String? address,
    String? workStartTime1,
    String? workStartTime2,
    String? workStartTime3,
    String? workStartTimeSaturday,
    String? workEndTimeSaturday,
    required bool active,
    int? excludeEmployeeId,
  }) async {
    if (companyId <= 0) {
      throw ArgumentError('La empresa seleccionada no es valida.');
    }

    if (departmentId == null || departmentId <= 0) {
      throw ArgumentError('Debe seleccionar un departamento.');
    }

    if (sectorId == null || sectorId <= 0) {
      throw ArgumentError('Debe seleccionar un sector.');
    }

    final department = await _departmentsDao.getDepartmentById(departmentId);
    if (department == null || department.companyId != companyId) {
      throw ArgumentError('El departamento seleccionado no es valido.');
    }

    final sector = await _departmentsDao.getSectorById(sectorId);
    if (sector == null || sector.departmentId != departmentId) {
      throw ArgumentError(
        'El sector seleccionado no pertenece al departamento.',
      );
    }

    final normalizedName = fullName.trim();
    final normalizedDocument = documentNumber.trim();
    final normalizedType = employeeType.trim().toLowerCase();
    final normalizedJobTitle = _normalizeOptional(jobTitle);
    final normalizedWorkLocation = _normalizeOptional(workLocation);
    final normalizedPhone = _normalizeOptional(phone);
    final normalizedAddress = _normalizeOptional(address);
    final normalizedEmbargoAccount = _normalizeOptional(embargoAccount);
    final normalizedWorkStartTime1 = _normalizeWorkStartTime(
      workStartTime1 ?? _defaultWorkStartTime1,
    );
    final normalizedWorkStartTime2 = _normalizeWorkStartTime(
      workStartTime2 ?? _defaultWorkStartTime2,
    );
    final normalizedWorkStartTime3 = _normalizeWorkStartTime(
      workStartTime3 ?? _defaultWorkStartTime3,
    );
    final normalizedWorkStartTimeSaturday = _normalizeOptional(
      workStartTimeSaturday,
    );
    final normalizedWorkEndTimeSaturday = _normalizeOptional(
      workEndTimeSaturday,
    );

    if (normalizedName.isEmpty) {
      throw ArgumentError('El nombre es obligatorio.');
    }

    if (normalizedDocument.isEmpty) {
      throw ArgumentError('El documento es obligatorio.');
    }

    final duplicateEmployee = await findEmployeeByDocumentInCompany(
      companyId: companyId,
      documentNumber: normalizedDocument,
      excludeEmployeeId: excludeEmployeeId,
    );
    if (duplicateEmployee != null) {
      throw ArgumentError(
        'El documento ya esta registrado en esta empresa (${duplicateEmployee.fullName}).',
      );
    }

    if (normalizedJobTitle == null) {
      throw ArgumentError('El cargo es obligatorio.');
    }

    if (normalizedWorkLocation == null) {
      throw ArgumentError('El lugar de trabajo es obligatorio.');
    }

    if (!_allowedEmployeeTypes.contains(normalizedType)) {
      throw ArgumentError('El tipo de empleado no es valido.');
    }

    if (baseSalary <= 0) {
      throw ArgumentError('El salario base debe ser mayor que cero.');
    }

    if (childrenCount < 0) {
      throw ArgumentError('La cantidad de hijos no puede ser negativa.');
    }

    if (embargoAmount != null && embargoAmount < 0) {
      throw ArgumentError('El monto de embargo no puede ser negativo.');
    }

    if (hasEmbargo && (embargoAmount == null || embargoAmount <= 0)) {
      throw ArgumentError('Debe ingresar un monto de embargo mayor que cero.');
    }

    final effectiveSaturdaySchedule = allowOvertime
        ? null
        : _normalizeRequiredSaturdaySchedule(
            start: normalizedWorkStartTimeSaturday,
            end: normalizedWorkEndTimeSaturday,
          );

    return _EmployeeInput(
      companyId: companyId,
      departmentId: departmentId,
      sectorId: sectorId,
      jobTitle: normalizedJobTitle,
      workLocation: normalizedWorkLocation,
      fullName: normalizedName,
      documentNumber: normalizedDocument,
      hireDate: DateTime(hireDate.year, hireDate.month, hireDate.day),
      employeeType: normalizedType,
      baseSalary: baseSalary,
      ipsEnabled: ipsEnabled ?? (normalizedType == 'servicio' ? false : true),
      childrenCount: childrenCount,
      allowOvertime: allowOvertime,
      biometricClockEnabled: biometricClockEnabled,
      hasEmbargo: hasEmbargo,
      embargoAccount: hasEmbargo ? normalizedEmbargoAccount : null,
      embargoAmount: hasEmbargo ? embargoAmount : null,
      phone: normalizedPhone,
      address: normalizedAddress,
      workStartTime1: normalizedWorkStartTime1,
      workStartTime2: normalizedWorkStartTime2,
      workStartTime3: normalizedWorkStartTime3,
      workStartTimeSaturday: effectiveSaturdaySchedule?.$1,
      workEndTimeSaturday: effectiveSaturdaySchedule?.$2,
      active: active,
    );
  }

  String _normalizeWorkStartTime(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('El horario de inicio laboral es obligatorio.');
    }

    final parsed = _parseHourMinute(normalized);
    if (parsed == null) {
      throw ArgumentError(
        'Formato de horario invalido. Use HH:mm para inicio laboral.',
      );
    }

    final hour = parsed.$1;
    final minute = parsed.$2;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('El horario de inicio laboral no es valido.');
    }

    final normalizedHour = hour.toString().padLeft(2, '0');
    final normalizedMinute = minute.toString().padLeft(2, '0');
    return '$normalizedHour:$normalizedMinute';
  }

  (String, String) _normalizeRequiredSaturdaySchedule({
    required String? start,
    required String? end,
  }) {
    final normalizedStart = start?.trim() ?? '';
    final normalizedEnd = end?.trim() ?? '';
    if (normalizedStart.isEmpty || normalizedEnd.isEmpty) {
      throw ArgumentError(
        'Ingrese inicio y salida de sabado cuando horas extra esta desactivada.',
      );
    }

    final effectiveStart = _normalizeWorkStartTime(normalizedStart);
    final effectiveEnd = _normalizeWorkStartTime(normalizedEnd);

    final startMinutes = _minutesFromTime(effectiveStart);
    final endMinutes = _minutesFromTime(effectiveEnd);
    if (endMinutes <= startMinutes) {
      throw ArgumentError(
        'La salida de sabado debe ser mayor al inicio de sabado.',
      );
    }

    return (effectiveStart, effectiveEnd);
  }

  int _minutesFromTime(String normalizedTime) {
    final segments = normalizedTime.split(':');
    final hour = int.parse(segments[0]);
    final minute = int.parse(segments[1]);
    return (hour * 60) + minute;
  }

  (int, int)? _parseHourMinute(String value) {
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

  String? _normalizeOptional(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _normalizeDocumentForLookup(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isNotEmpty) {
      return digitsOnly;
    }

    final alphanumeric = trimmed.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    return alphanumeric.isEmpty ? null : alphanumeric;
  }
}

const Set<String> _allowedEmployeeTypes = {'mensual', 'jornalero', 'servicio'};
const String _defaultWorkStartTime1 = '06:00';
const String _defaultWorkStartTime2 = '15:00';
const String _defaultWorkStartTime3 = '18:00';
final RegExp _timeRegExp = RegExp(r'^(\\d{1,2})[:.,](\\d{2})$');

class _EmployeeInput {
  const _EmployeeInput({
    required this.companyId,
    required this.departmentId,
    required this.sectorId,
    required this.jobTitle,
    required this.workLocation,
    required this.fullName,
    required this.documentNumber,
    required this.hireDate,
    required this.employeeType,
    required this.baseSalary,
    required this.ipsEnabled,
    required this.childrenCount,
    required this.allowOvertime,
    required this.biometricClockEnabled,
    required this.hasEmbargo,
    required this.embargoAccount,
    required this.embargoAmount,
    required this.phone,
    required this.address,
    required this.workStartTime1,
    required this.workStartTime2,
    required this.workStartTime3,
    required this.workStartTimeSaturday,
    required this.workEndTimeSaturday,
    required this.active,
  });

  final int companyId;
  final int departmentId;
  final int sectorId;
  final String jobTitle;
  final String workLocation;
  final String fullName;
  final String documentNumber;
  final DateTime hireDate;
  final String employeeType;
  final double baseSalary;
  final bool ipsEnabled;
  final int childrenCount;
  final bool allowOvertime;
  final bool biometricClockEnabled;
  final bool hasEmbargo;
  final String? embargoAccount;
  final double? embargoAmount;
  final String? phone;
  final String? address;
  final String workStartTime1;
  final String workStartTime2;
  final String workStartTime3;
  final String? workStartTimeSaturday;
  final String? workEndTimeSaturday;
  final bool active;
}
