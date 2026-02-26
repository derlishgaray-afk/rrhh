part of '../app_database.dart';

class Permissions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get key =>
      text().named('permission_key').customConstraint('UNIQUE NOT NULL')();

  TextColumn get description => text().nullable()();
}
