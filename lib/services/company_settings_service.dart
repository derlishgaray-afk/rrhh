import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../security/security_constants.dart';
import 'authorization_service.dart';

class CompanySettingsService {
  CompanySettingsService(this._companySettingsDao, this._authorizationService);

  final CompanySettingsDao _companySettingsDao;
  final AuthorizationService _authorizationService;

  Future<CompanySetting> getOrCreateSettings(int companyId) async {
    _validateCompanyId(companyId);

    final existing = await _companySettingsDao.getCompanySettings(companyId);
    if (existing != null) {
      return existing;
    }

    final template = await _companySettingsDao.getMostRecentlyUpdatedSettings(
      excludeCompanyId: companyId,
    );
    await _companySettingsDao.upsertCompanySettings(
      template == null
          ? CompanySettingsCompanion.insert(companyId: Value(companyId))
          : CompanySettingsCompanion.insert(
              companyId: Value(companyId),
              ipsEmployeeRate: Value(template.ipsEmployeeRate),
              ipsEmployerRate: Value(template.ipsEmployerRate),
              minimumWage: Value(template.minimumWage),
              familyBonusRate: Value(template.familyBonusRate),
              overtimeDayRate: Value(template.overtimeDayRate),
              overtimeNightRate: Value(template.overtimeNightRate),
              ordinaryNightSurchargeRate: Value(
                template.ordinaryNightSurchargeRate,
              ),
              ordinaryNightStart: Value(template.ordinaryNightStart),
              ordinaryNightEnd: Value(template.ordinaryNightEnd),
              overtimeDayStart: Value(template.overtimeDayStart),
              overtimeDayEnd: Value(template.overtimeDayEnd),
              overtimeNightStart: Value(template.overtimeNightStart),
              overtimeNightEnd: Value(template.overtimeNightEnd),
              holidayDates: Value(template.holidayDates),
              lateArrivalToleranceMinutes: Value(
                template.lateArrivalToleranceMinutes,
              ),
              lateArrivalAllowedTimesPerMonth: Value(
                template.lateArrivalAllowedTimesPerMonth,
              ),
              updatedAt: Value(DateTime.now()),
            ),
    );

    final created = await _companySettingsDao.getCompanySettings(companyId);
    if (created == null) {
      throw StateError('No se pudo crear configuracion de empresa.');
    }
    return created;
  }

  Future<CompanySetting> updateSettings({
    required int companyId,
    required double ipsEmployeeRate,
    required double ipsEmployerRate,
    required double minimumWage,
    required double familyBonusRate,
    required double overtimeDayRate,
    required double overtimeNightRate,
    required double ordinaryNightSurchargeRate,
    required String ordinaryNightStart,
    required String ordinaryNightEnd,
    required String overtimeDayStart,
    required String overtimeDayEnd,
    required String overtimeNightStart,
    required String overtimeNightEnd,
    required int lateArrivalToleranceMinutes,
    required int lateArrivalAllowedTimesPerMonth,
  }) async {
    _validateCompanyId(companyId);
    await _authorizationService.ensurePermission(
      PermissionKeys.settingsUpdate,
      companyId: companyId,
    );
    _validateNonNegative('IPS empleado', ipsEmployeeRate);
    _validateNonNegative('IPS empleador', ipsEmployerRate);
    _validateNonNegative('Salario minimo', minimumWage);
    _validateNonNegative('Bono familiar', familyBonusRate);
    _validateNonNegative('Hora extra diurna', overtimeDayRate);
    _validateNonNegative('Hora extra nocturna', overtimeNightRate);
    _validateNonNegative(
      'Recargo nocturno ordinario',
      ordinaryNightSurchargeRate,
    );
    _validateNonNegativeInt(
      'Tolerancia de tardanza (min)',
      lateArrivalToleranceMinutes,
    );
    _validateNonNegativeInt(
      'Cantidad de tardanzas permitidas al mes',
      lateArrivalAllowedTimesPerMonth,
    );

    final normalizedOrdinaryNightStart = _normalizeHourMinute(
      ordinaryNightStart,
    );
    final normalizedOrdinaryNightEnd = _normalizeHourMinute(ordinaryNightEnd);
    final normalizedOvertimeDayStart = _normalizeHourMinute(overtimeDayStart);
    final normalizedOvertimeDayEnd = _normalizeHourMinute(overtimeDayEnd);
    final normalizedOvertimeNightStart = _normalizeHourMinute(
      overtimeNightStart,
    );
    final normalizedOvertimeNightEnd = _normalizeHourMinute(overtimeNightEnd);

    _validateTimeRange(
      label: 'Recargo nocturno ordinario',
      start: normalizedOrdinaryNightStart,
      end: normalizedOrdinaryNightEnd,
    );
    _validateTimeRange(
      label: 'Hora extra diurna',
      start: normalizedOvertimeDayStart,
      end: normalizedOvertimeDayEnd,
    );
    _validateTimeRange(
      label: 'Hora extra nocturna',
      start: normalizedOvertimeNightStart,
      end: normalizedOvertimeNightEnd,
    );

    final current = await getOrCreateSettings(companyId);
    final now = DateTime.now();
    final template = current.copyWith(
      ipsEmployeeRate: ipsEmployeeRate,
      ipsEmployerRate: ipsEmployerRate,
      minimumWage: minimumWage,
      familyBonusRate: familyBonusRate,
      overtimeDayRate: overtimeDayRate,
      overtimeNightRate: overtimeNightRate,
      ordinaryNightSurchargeRate: ordinaryNightSurchargeRate,
      ordinaryNightStart: normalizedOrdinaryNightStart,
      ordinaryNightEnd: normalizedOrdinaryNightEnd,
      overtimeDayStart: normalizedOvertimeDayStart,
      overtimeDayEnd: normalizedOvertimeDayEnd,
      overtimeNightStart: normalizedOvertimeNightStart,
      overtimeNightEnd: normalizedOvertimeNightEnd,
      lateArrivalToleranceMinutes: lateArrivalToleranceMinutes,
      lateArrivalAllowedTimesPerMonth: lateArrivalAllowedTimesPerMonth,
      updatedAt: now,
    );

    final allSettings = await _companySettingsDao.listCompanySettings();
    if (allSettings.isEmpty) {
      await _companySettingsDao.upsertCompanySettings(
        CompanySettingsCompanion.insert(
          companyId: Value(companyId),
          ipsEmployeeRate: Value(template.ipsEmployeeRate),
          ipsEmployerRate: Value(template.ipsEmployerRate),
          minimumWage: Value(template.minimumWage),
          familyBonusRate: Value(template.familyBonusRate),
          overtimeDayRate: Value(template.overtimeDayRate),
          overtimeNightRate: Value(template.overtimeNightRate),
          ordinaryNightSurchargeRate: Value(
            template.ordinaryNightSurchargeRate,
          ),
          ordinaryNightStart: Value(template.ordinaryNightStart),
          ordinaryNightEnd: Value(template.ordinaryNightEnd),
          overtimeDayStart: Value(template.overtimeDayStart),
          overtimeDayEnd: Value(template.overtimeDayEnd),
          overtimeNightStart: Value(template.overtimeNightStart),
          overtimeNightEnd: Value(template.overtimeNightEnd),
          holidayDates: Value(template.holidayDates),
          lateArrivalToleranceMinutes: Value(
            template.lateArrivalToleranceMinutes,
          ),
          lateArrivalAllowedTimesPerMonth: Value(
            template.lateArrivalAllowedTimesPerMonth,
          ),
          updatedAt: Value(now),
        ),
      );
    } else {
      for (final settings in allSettings) {
        await _companySettingsDao.updateCompanySettings(
          settings.copyWith(
            ipsEmployeeRate: template.ipsEmployeeRate,
            ipsEmployerRate: template.ipsEmployerRate,
            minimumWage: template.minimumWage,
            familyBonusRate: template.familyBonusRate,
            overtimeDayRate: template.overtimeDayRate,
            overtimeNightRate: template.overtimeNightRate,
            ordinaryNightSurchargeRate: template.ordinaryNightSurchargeRate,
            ordinaryNightStart: template.ordinaryNightStart,
            ordinaryNightEnd: template.ordinaryNightEnd,
            overtimeDayStart: template.overtimeDayStart,
            overtimeDayEnd: template.overtimeDayEnd,
            overtimeNightStart: template.overtimeNightStart,
            overtimeNightEnd: template.overtimeNightEnd,
            holidayDates: template.holidayDates,
            lateArrivalToleranceMinutes: template.lateArrivalToleranceMinutes,
            lateArrivalAllowedTimesPerMonth:
                template.lateArrivalAllowedTimesPerMonth,
            updatedAt: now,
          ),
        );
      }
    }

    final saved = await _companySettingsDao.getCompanySettings(companyId);
    if (saved == null) {
      throw StateError('No se pudo guardar configuracion de empresa.');
    }
    return saved;
  }

  Set<DateTime> parseHolidayDates(String raw) {
    if (raw.trim().isEmpty) {
      return <DateTime>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <DateTime>{};
      }

      final dates = <DateTime>{};
      for (final value in decoded) {
        if (value is! String) {
          continue;
        }
        final parsed = DateTime.tryParse(value);
        if (parsed == null) {
          continue;
        }
        dates.add(DateTime(parsed.year, parsed.month, parsed.day));
      }
      return dates;
    } catch (_) {
      return <DateTime>{};
    }
  }

  String serializeHolidayDates(Iterable<DateTime> dates) {
    final normalized =
        dates
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet()
            .toList()
          ..sort((left, right) => left.compareTo(right));

    final asStrings = normalized
        .map(
          (date) =>
              '${date.year.toString().padLeft(4, '0')}-'
              '${date.month.toString().padLeft(2, '0')}-'
              '${date.day.toString().padLeft(2, '0')}',
        )
        .toList();

    return jsonEncode(asStrings);
  }

  Future<CompanySetting> updateHolidays({
    required int companyId,
    required Iterable<DateTime> holidayDates,
  }) async {
    _validateCompanyId(companyId);
    await _authorizationService.ensurePermission(
      PermissionKeys.settingsUpdate,
      companyId: companyId,
    );
    final now = DateTime.now();
    final serializedDates = serializeHolidayDates(holidayDates);
    await getOrCreateSettings(companyId);
    final allSettings = await _companySettingsDao.listCompanySettings();
    if (allSettings.isEmpty) {
      await _companySettingsDao.upsertCompanySettings(
        CompanySettingsCompanion.insert(
          companyId: Value(companyId),
          holidayDates: Value(serializedDates),
          updatedAt: Value(now),
        ),
      );
    } else {
      for (final settings in allSettings) {
        await _companySettingsDao.updateCompanySettings(
          settings.copyWith(holidayDates: serializedDates, updatedAt: now),
        );
      }
    }

    final saved = await _companySettingsDao.getCompanySettings(companyId);
    if (saved == null) {
      throw StateError('No se pudo guardar feriados de empresa.');
    }
    return saved;
  }

  void _validateCompanyId(int companyId) {
    if (companyId <= 0) {
      throw ArgumentError('La empresa no es valida.');
    }
  }

  void _validateNonNegative(String fieldName, double value) {
    if (value < 0) {
      throw ArgumentError('$fieldName no puede ser negativo.');
    }
  }

  void _validateNonNegativeInt(String fieldName, int value) {
    if (value < 0) {
      throw ArgumentError('$fieldName no puede ser negativo.');
    }
  }

  String _normalizeHourMinute(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('El horario no puede estar vacio.');
    }

    final parsed = _parseHourMinute(normalized);
    if (parsed == null) {
      throw ArgumentError('Formato de hora invalido. Use HH:mm.');
    }

    final hour = parsed.$1;
    final minute = parsed.$2;

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('El horario ingresado no es valido.');
    }

    final normalizedHour = hour.toString().padLeft(2, '0');
    final normalizedMinute = minute.toString().padLeft(2, '0');
    return '$normalizedHour:$normalizedMinute';
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

  void _validateTimeRange({
    required String label,
    required String start,
    required String end,
  }) {
    if (start == end) {
      throw ArgumentError(
        'Rango de $label invalido: inicio y fin no pueden ser iguales.',
      );
    }
  }
}

final RegExp _timeRegExp = RegExp(r'^(\d{1,2})[:.,](\d{2})$');
