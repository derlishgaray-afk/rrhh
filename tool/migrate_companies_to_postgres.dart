import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart' as pg;
import 'package:sqlite3/sqlite3.dart' as sqlite;

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final sourcePath = options.sourcePath ?? _defaultSqlitePath();
  final dryRun = options.dryRun;

  if (!File(sourcePath).existsSync()) {
    stderr.writeln('No se encontro SQLite en: $sourcePath');
    exitCode = 1;
    return;
  }

  final host = _requiredEnv('DB_HOST');
  final dbName = _requiredEnv('DB_NAME');
  final user = _requiredEnv('DB_USER');
  final password = _requiredEnv('DB_PASSWORD');
  final port = int.tryParse(Platform.environment['DB_PORT'] ?? '5432') ?? 5432;
  final sslMode = _sslModeFromEnv(Platform.environment['DB_SSL_MODE']);

  final sqliteDb = sqlite.sqlite3.open(sourcePath, mode: sqlite.OpenMode.readOnly);
  try {
    final tableCheck = sqliteDb.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='companies'",
    );
    if (tableCheck.isEmpty) {
      stderr.writeln('La base local no tiene tabla companies.');
      exitCode = 1;
      return;
    }

    final rows = sqliteDb.select(
      'SELECT id, name, abbreviation, ruc, address, phone, '
      'mjt_employer_number, logo_png, active, created_at '
      'FROM companies ORDER BY id',
    );
    final settingsRows = _tableExists(sqliteDb, 'company_settings')
        ? sqliteDb.select('SELECT * FROM company_settings ORDER BY company_id')
        : const <sqlite.Row>[];
    final appSettingsRows = _tableExists(sqliteDb, 'app_settings')
        ? sqliteDb.select(
            "SELECT key, value FROM app_settings WHERE key <> 'current_user_id' ORDER BY key",
          )
        : const <sqlite.Row>[];

    stdout.writeln('Empresas encontradas en SQLite: ${rows.length}');
    stdout.writeln(
      'Configuraciones de empresa encontradas: ${settingsRows.length}',
    );
    stdout.writeln(
      'App settings encontrados (sin sesion): ${appSettingsRows.length}',
    );
    if (rows.isEmpty) {
      return;
    }

    if (dryRun) {
      for (final row in rows) {
        stdout.writeln(' - [${row['id']}] ${row['name']}');
      }
      stdout.writeln('Modo simulacion: no se insertaron datos.');
      return;
    }

    final connection = await pg.Connection.open(
      pg.Endpoint(
        host: host,
        port: port,
        database: dbName,
        username: user,
        password: password,
      ),
      settings: pg.ConnectionSettings(
        sslMode: sslMode,
        connectTimeout: const Duration(seconds: 6),
      ),
    );

    try {
      await connection.runTx((tx) async {
        for (final row in rows) {
          final id = _asInt(row['id']);
          final createdAt = _toUnixSeconds(row['created_at']);
          final active = _asBool(row['active']);
          final logoBytes = _asBytes(row['logo_png']);

          await tx.execute(
            pg.Sql.named(
              'INSERT INTO companies ('
              'id, name, abbreviation, ruc, address, phone, '
              'mjt_employer_number, logo_png, active, created_at'
              ') VALUES ('
              '@id, @name, @abbreviation, @ruc, @address, @phone, '
              '@mjtEmployerNumber, @logoPng, @active, @createdAt'
              ') '
              'ON CONFLICT (id) DO UPDATE SET '
              'name = EXCLUDED.name, '
              'abbreviation = EXCLUDED.abbreviation, '
              'ruc = EXCLUDED.ruc, '
              'address = EXCLUDED.address, '
              'phone = EXCLUDED.phone, '
              'mjt_employer_number = EXCLUDED.mjt_employer_number, '
              'logo_png = EXCLUDED.logo_png, '
              'active = EXCLUDED.active, '
              'created_at = EXCLUDED.created_at',
            ),
            parameters: {
              'id': id,
              'name': (row['name'] ?? '').toString(),
              'abbreviation': _asNullableString(row['abbreviation']),
              'ruc': _asNullableString(row['ruc']),
              'address': _asNullableString(row['address']),
              'phone': _asNullableString(row['phone']),
              'mjtEmployerNumber': _asNullableString(row['mjt_employer_number']),
              'logoPng': logoBytes == null
                  ? null
                  : pg.TypedValue(pg.Type.byteArray, logoBytes),
              'active': active,
              'createdAt': createdAt,
            },
          );
        }

        for (final row in settingsRows) {
          final companyId = _asInt(row['company_id']);
          final updatedAt = _toUnixSeconds(row['updated_at']);

          await tx.execute(
            pg.Sql.named(
              'INSERT INTO company_settings ('
              'company_id, ips_employee_rate, ips_employer_rate, minimum_wage, '
              'family_bonus_rate, overtime_day_rate, overtime_night_rate, '
              'ordinary_night_surcharge_rate, ordinary_night_start, ordinary_night_end, '
              'overtime_day_start, overtime_day_end, overtime_night_start, overtime_night_end, '
              'holiday_dates, late_arrival_tolerance_minutes, late_arrival_allowed_times_per_month, '
              'updated_at'
              ') VALUES ('
              '@companyId, @ipsEmployeeRate, @ipsEmployerRate, @minimumWage, '
              '@familyBonusRate, @overtimeDayRate, @overtimeNightRate, '
              '@ordinaryNightSurchargeRate, @ordinaryNightStart, @ordinaryNightEnd, '
              '@overtimeDayStart, @overtimeDayEnd, @overtimeNightStart, @overtimeNightEnd, '
              '@holidayDates, @lateArrivalToleranceMinutes, @lateArrivalAllowedTimesPerMonth, '
              '@updatedAt'
              ') '
              'ON CONFLICT (company_id) DO UPDATE SET '
              'ips_employee_rate = EXCLUDED.ips_employee_rate, '
              'ips_employer_rate = EXCLUDED.ips_employer_rate, '
              'minimum_wage = EXCLUDED.minimum_wage, '
              'family_bonus_rate = EXCLUDED.family_bonus_rate, '
              'overtime_day_rate = EXCLUDED.overtime_day_rate, '
              'overtime_night_rate = EXCLUDED.overtime_night_rate, '
              'ordinary_night_surcharge_rate = EXCLUDED.ordinary_night_surcharge_rate, '
              'ordinary_night_start = EXCLUDED.ordinary_night_start, '
              'ordinary_night_end = EXCLUDED.ordinary_night_end, '
              'overtime_day_start = EXCLUDED.overtime_day_start, '
              'overtime_day_end = EXCLUDED.overtime_day_end, '
              'overtime_night_start = EXCLUDED.overtime_night_start, '
              'overtime_night_end = EXCLUDED.overtime_night_end, '
              'holiday_dates = EXCLUDED.holiday_dates, '
              'late_arrival_tolerance_minutes = EXCLUDED.late_arrival_tolerance_minutes, '
              'late_arrival_allowed_times_per_month = EXCLUDED.late_arrival_allowed_times_per_month, '
              'updated_at = EXCLUDED.updated_at',
            ),
            parameters: {
              'companyId': companyId,
              'ipsEmployeeRate': _asDouble(row['ips_employee_rate'], 0.09),
              'ipsEmployerRate': _asDouble(row['ips_employer_rate'], 0.165),
              'minimumWage': _asDouble(row['minimum_wage'], 0),
              'familyBonusRate': _asDouble(row['family_bonus_rate'], 0),
              'overtimeDayRate': _asDouble(row['overtime_day_rate'], 0.5),
              'overtimeNightRate': _asDouble(row['overtime_night_rate'], 1.0),
              'ordinaryNightSurchargeRate': _asDouble(
                row['ordinary_night_surcharge_rate'],
                0.3,
              ),
              'ordinaryNightStart': _asTextOrDefault(
                row['ordinary_night_start'],
                '20:00',
              ),
              'ordinaryNightEnd': _asTextOrDefault(
                row['ordinary_night_end'],
                '06:00',
              ),
              'overtimeDayStart': _asTextOrDefault(
                row['overtime_day_start'],
                '06:00',
              ),
              'overtimeDayEnd': _asTextOrDefault(
                row['overtime_day_end'],
                '20:00',
              ),
              'overtimeNightStart': _asTextOrDefault(
                row['overtime_night_start'],
                '20:00',
              ),
              'overtimeNightEnd': _asTextOrDefault(
                row['overtime_night_end'],
                '06:00',
              ),
              'holidayDates': _asTextOrDefault(row['holiday_dates'], '[]'),
              'lateArrivalToleranceMinutes': _asIntWithDefault(
                row['late_arrival_tolerance_minutes'],
                0,
              ),
              'lateArrivalAllowedTimesPerMonth': _asIntWithDefault(
                row['late_arrival_allowed_times_per_month'],
                0,
              ),
              'updatedAt': updatedAt,
            },
          );
        }

        for (final row in appSettingsRows) {
          final key = (row['key'] ?? '').toString().trim();
          if (key.isEmpty) {
            continue;
          }
          final value = row['value']?.toString();
          await tx.execute(
            pg.Sql.named(
              'INSERT INTO app_settings (key, value) VALUES (@key, @value) '
              'ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value',
            ),
            parameters: {
              'key': key,
              'value': value,
            },
          );
        }

        final maxIdResult = await tx.execute('SELECT COALESCE(MAX(id), 0) FROM companies');
        final maxId = (maxIdResult.first.first as int?) ?? 0;
        if (maxId > 0) {
          await tx.execute(
            pg.Sql.named(
              "SELECT setval(pg_get_serial_sequence('companies', 'id'), @maxId, true)",
            ),
            parameters: {'maxId': maxId},
          );
        }
      });

      stdout.writeln(
        'Migracion completada: ${rows.length} empresas, '
        '${settingsRows.length} configuraciones de empresa, '
        '${appSettingsRows.length} app settings.',
      );
    } finally {
      await connection.close();
    }
  } finally {
    sqliteDb.dispose();
  }
}

bool _tableExists(sqlite.Database db, String tableName) {
  final rows = db.select(
    "SELECT 1 FROM sqlite_master WHERE type='table' AND name = ? LIMIT 1",
    [tableName],
  );
  return rows.isNotEmpty;
}

_Options _parseArgs(List<String> args) {
  String? sourcePath;
  var dryRun = false;

  for (final arg in args) {
    if (arg == '--dry-run') {
      dryRun = true;
      continue;
    }
    if (arg.startsWith('--source=')) {
      sourcePath = arg.substring('--source='.length).trim();
    }
  }

  return _Options(sourcePath: sourcePath, dryRun: dryRun);
}

String _defaultSqlitePath() {
  final appData = Platform.environment['APPDATA'] ?? '';
  return p.join(appData, 'com.example', 'rrhh_app', 'rrhh_app.sqlite');
}

String _requiredEnv(String key) {
  final value = Platform.environment[key]?.trim() ?? '';
  if (value.isEmpty) {
    throw StateError('Falta variable de entorno: $key');
  }
  return value;
}

pg.SslMode _sslModeFromEnv(String? raw) {
  final value = (raw ?? '').trim().toLowerCase();
  return switch (value) {
    'require' => pg.SslMode.require,
    'verifyfull' || 'verify_full' || 'verify-full' => pg.SslMode.verifyFull,
    _ => pg.SslMode.disable,
  };
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.parse(value.toString());
}

int _asIntWithDefault(Object? value, int fallback) {
  if (value == null) {
    return fallback;
  }
  final asInt = int.tryParse(value.toString());
  if (asInt != null) {
    return asInt;
  }
  return fallback;
}

double _asDouble(Object? value, double fallback) {
  if (value == null) {
    return fallback;
  }
  if (value is num) {
    return value.toDouble();
  }
  final parsed = double.tryParse(value.toString());
  return parsed ?? fallback;
}

bool _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  return normalized == '1' || normalized == 'true' || normalized == 't';
}

String? _asNullableString(Object? value) {
  if (value == null) {
    return null;
  }
  final normalized = value.toString().trim();
  return normalized.isEmpty ? null : normalized;
}

String _asTextOrDefault(Object? value, String fallback) {
  final asString = _asNullableString(value);
  return asString ?? fallback;
}

Uint8List? _asBytes(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Uint8List) {
    return value;
  }
  if (value is List<int>) {
    return Uint8List.fromList(value);
  }
  return null;
}

int _toUnixSeconds(Object? value) {
  if (value == null) {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }

  final raw = value.toString().trim();
  final asInt = int.tryParse(raw);
  if (asInt != null) {
    return asInt;
  }

  final parsed = DateTime.tryParse(raw);
  if (parsed != null) {
    return parsed.millisecondsSinceEpoch ~/ 1000;
  }

  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

class _Options {
  const _Options({required this.sourcePath, required this.dryRun});

  final String? sourcePath;
  final bool dryRun;
}
