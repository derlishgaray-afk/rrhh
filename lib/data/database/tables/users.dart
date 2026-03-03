part of '../app_database.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get username => text().customConstraint('UNIQUE NOT NULL')();

  TextColumn get passwordHash => text().named('password_hash')();

  TextColumn get fullName => text().named('full_name')();

  BoolColumn get active =>
      boolean().named('active').withDefault(const Constant(true))();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').clientDefault(() => DateTime.now())();

  DateTimeColumn get lastLoginAt =>
      dateTime().named('last_login_at').nullable()();
}

