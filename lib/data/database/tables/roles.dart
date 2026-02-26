part of '../app_database.dart';

class Roles extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().customConstraint('UNIQUE NOT NULL')();

  TextColumn get description => text().nullable()();
}
