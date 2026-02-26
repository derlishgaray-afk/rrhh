part of '../app_database.dart';

class UserCompanyAccess extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()
      .named('user_id')
      .references(Users, #id, onDelete: KeyAction.cascade)();

  IntColumn get companyId => integer()
      .named('company_id')
      .references(Companies, #id, onDelete: KeyAction.cascade)();

  IntColumn get roleId => integer()
      .named('role_id')
      .references(Roles, #id, onDelete: KeyAction.restrict)();

  BoolColumn get active =>
      boolean().named('active').withDefault(const Constant(true))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {userId, companyId},
  ];
}
