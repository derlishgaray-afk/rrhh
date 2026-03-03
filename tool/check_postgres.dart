import 'dart:io';

import 'package:postgres/postgres.dart';

Future<void> main() async {
  final host = _readRequired('DB_HOST');
  final dbName = _readRequired('DB_NAME');
  final dbUser = _readRequired('DB_USER');
  final dbPassword = _readRequired('DB_PASSWORD');
  final dbPort = int.tryParse(Platform.environment['DB_PORT'] ?? '5432') ?? 5432;

  final connection = await Connection.open(
    Endpoint(
      host: host,
      port: dbPort,
      database: dbName,
      username: dbUser,
      password: dbPassword,
    ),
    settings: const ConnectionSettings(
      sslMode: SslMode.disable,
      connectTimeout: Duration(seconds: 5),
    ),
  );

  try {
    final serverInfo = await connection.execute(
      'select current_database() as db, current_user as usr, version() as ver',
    );
    final infoRow = serverInfo.first;
    stdout.writeln('DB: ${infoRow[0]}');
    stdout.writeln('Usuario conectado: ${infoRow[1]}');
    stdout.writeln('Version: ${(infoRow[2] as String).split(" ").take(2).join(" ")}');

    final tablesResult = await connection.execute(
      Sql.named(
        'select table_name from information_schema.tables '
        "where table_schema = 'public' and table_name in "
        "('users','roles','permissions','user_company_access','companies') "
        'order by table_name',
      ),
    );
    stdout.writeln('Tablas clave encontradas: ${tablesResult.length}');
    for (final row in tablesResult) {
      stdout.writeln(' - ${row[0]}');
    }

    final usersExists = tablesResult.any((row) => row[0] == 'users');
    if (!usersExists) {
      stdout.writeln(
        'La tabla users no existe. La app no pudo crear esquema en PostgreSQL.',
      );
      return;
    }

    final users = await connection.execute(
      'select id, username, active from users order by id limit 20',
    );
    stdout.writeln('Usuarios registrados: ${users.length}');
    for (final row in users) {
      stdout.writeln(' - id=${row[0]}, user=${row[1]}, active=${row[2]}');
    }
  } finally {
    await connection.close();
  }
}

String _readRequired(String key) {
  final value = Platform.environment[key]?.trim() ?? '';
  if (value.isEmpty) {
    throw StateError('Falta variable de entorno: $key');
  }
  return value;
}
