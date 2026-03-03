part of '../app_database.dart';

class Companies extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get abbreviation => text().nullable()();

  TextColumn get ruc => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get mjtEmployerNumber =>
      text().named('mjt_employer_number').nullable()();

  BlobColumn get logoPng => blob().named('logo_png').nullable()();

  BoolColumn get active => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').clientDefault(() => DateTime.now())();
}

