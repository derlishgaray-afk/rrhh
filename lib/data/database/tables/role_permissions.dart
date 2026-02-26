part of '../app_database.dart';

class RolePermissions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get roleId => integer()
      .named('role_id')
      .references(Roles, #id, onDelete: KeyAction.cascade)();

  IntColumn get permissionId => integer()
      .named('permission_id')
      .references(Permissions, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {roleId, permissionId},
  ];
}
