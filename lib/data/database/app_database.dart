import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../security/password_hasher.dart';
import '../../security/security_constants.dart';

part 'dao/advances_dao.dart';
part 'dao/attendance_dao.dart';
part 'dao/company_settings_dao.dart';
part 'dao/companies_dao.dart';
part 'dao/departments_dao.dart';
part 'dao/employees_dao.dart';
part 'dao/payroll_dao.dart';
part 'dao/security_dao.dart';
part 'dao/settings_dao.dart';
part 'tables/advances.dart';
part 'tables/app_settings.dart';
part 'tables/attendance_events.dart';
part 'tables/company_settings.dart';
part 'tables/companies.dart';
part 'tables/departments.dart';
part 'tables/department_sectors.dart';
part 'tables/employees.dart';
part 'tables/permissions.dart';
part 'tables/payroll_items.dart';
part 'tables/payroll_runs.dart';
part 'tables/role_permissions.dart';
part 'tables/roles.dart';
part 'tables/user_company_access.dart';
part 'tables/users.dart';
part 'app_database.g.dart';

const String _activeCompanySettingKey = 'active_company_id';

@DriftDatabase(
  tables: [
    Companies,
    Departments,
    DepartmentSectors,
    AppSettings,
    Employees,
    AttendanceEvents,
    CompanySettings,
    Advances,
    PayrollRuns,
    PayrollItems,
    Users,
    Roles,
    Permissions,
    RolePermissions,
    UserCompanyAccess,
  ],
  daos: [
    CompaniesDao,
    DepartmentsDao,
    SettingsDao,
    EmployeesDao,
    AttendanceDao,
    CompanySettingsDao,
    AdvancesDao,
    PayrollDao,
    SecurityDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 24;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedSecurityModel();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(companies);
        await m.createTable(appSettings);

        final defaultCompanyId = await into(
          companies,
        ).insert(CompaniesCompanion.insert(name: 'Empresa principal'));

        await m.alterTable(
          TableMigration(
            employees,
            newColumns: [
              employees.companyId,
              employees.ipsEnabled,
              employees.childrenCount,
              employees.allowOvertime,
              employees.biometricClockEnabled,
              employees.hasEmbargo,
              employees.embargoAccount,
              employees.embargoAmount,
              employees.workStartTime1,
              employees.workStartTime2,
              employees.workStartTime3,
              employees.workStartTimeSaturday,
              employees.workEndTimeSaturday,
            ],
            columnTransformer: {
              employees.companyId: Constant(defaultCompanyId),
              employees.ipsEnabled: const Constant(true),
              employees.childrenCount: const Constant(0),
              employees.allowOvertime: const Constant(true),
              employees.biometricClockEnabled: const Constant(true),
              employees.hasEmbargo: const Constant(false),
              employees.workStartTime1: const Constant('06:00'),
              employees.workStartTime2: const Constant('15:00'),
              employees.workStartTime3: const Constant('18:00'),
            },
          ),
        );

        await m.createTable(attendanceEvents);
        await m.createTable(advances);
        await m.createTable(payrollRuns);
        await m.createTable(payrollItems);

        await into(appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _activeCompanySettingKey,
            value: Value(defaultCompanyId.toString()),
          ),
        );
      }

      if (from < 3) {
        await m.createTable(companySettings);

        final existingCompanies = await select(companies).get();
        for (final company in existingCompanies) {
          await into(companySettings).insertOnConflictUpdate(
            CompanySettingsCompanion.insert(companyId: Value(company.id)),
          );
        }

        if (from >= 2) {
          await _addColumnIfMissing(m, employees, employees.childrenCount);
          await _addColumnIfMissing(m, employees, employees.allowOvertime);
          await _addColumnIfMissing(m, employees, employees.hasEmbargo);
          await _addColumnIfMissing(m, employees, employees.embargoAccount);
          await _addColumnIfMissing(m, employees, employees.embargoAmount);
          await _addColumnIfMissing(
            m,
            attendanceEvents,
            attendanceEvents.overtimeType,
          );
          await _addColumnIfMissing(
            m,
            payrollItems,
            payrollItems.embargoAmount,
          );
          await _addColumnIfMissing(
            m,
            payrollItems,
            payrollItems.embargoAccount,
          );
        }
      }

      if (from >= 2 && from < 4) {
        await _addColumnIfMissing(
          m,
          attendanceEvents,
          attendanceEvents.checkInTime,
        );
        await _addColumnIfMissing(
          m,
          attendanceEvents,
          attendanceEvents.checkOutTime,
        );
      }

      if (from >= 2 && from < 5) {
        await _addColumnIfMissing(
          m,
          attendanceEvents,
          attendanceEvents.breakMinutes,
        );
      }

      if (from >= 3 && from < 6) {
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.ordinaryNightSurchargeRate,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.ordinaryNightStart,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.ordinaryNightEnd,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.overtimeDayStart,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.overtimeDayEnd,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.overtimeNightStart,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.overtimeNightEnd,
        );
      }

      if (from >= 2 && from < 7) {
        await _addColumnIfMissing(m, employees, employees.workStartTime1);
        await _addColumnIfMissing(m, employees, employees.workStartTime2);
        await _addColumnIfMissing(m, employees, employees.workStartTime3);
      }

      if (from >= 2 && from < 8) {
        await _addColumnIfMissing(m, payrollItems, payrollItems.overtimePay);
      }

      if (from >= 2 && from < 9) {
        await _addColumnIfMissing(m, payrollItems, payrollItems.otherDiscount);
      }

      if (from >= 2 && from < 10) {
        await m.createTable(departments);
        await m.createTable(departmentSectors);
      }

      if (from >= 2 && from < 11) {
        await _addColumnIfMissing(m, employees, employees.departmentId);
        await _addColumnIfMissing(m, employees, employees.sectorId);
        await _addColumnIfMissing(m, employees, employees.jobTitle);
        await _addColumnIfMissing(m, employees, employees.workLocation);
      }

      if (from >= 2 && from < 12) {
        await _addColumnIfMissing(
          m,
          payrollItems,
          payrollItems.ordinaryNightHours,
        );
        await _addColumnIfMissing(
          m,
          payrollItems,
          payrollItems.ordinaryNightSurchargePay,
        );
      }

      if (from >= 2 && from < 13) {
        await _addColumnIfMissing(m, payrollItems, payrollItems.familyBonus);
      }

      if (from >= 3 && from < 14) {
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.holidayDates,
        );
      }

      if (from >= 3 && from < 15) {
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.lateArrivalToleranceMinutes,
        );
        await _addColumnIfMissing(
          m,
          companySettings,
          companySettings.lateArrivalAllowedTimesPerMonth,
        );
      }

      if (from >= 2 && from < 16) {
        await _addColumnIfMissing(
          m,
          payrollItems,
          payrollItems.attendanceDiscount,
        );
      }

      if (from >= 2 && from < 17) {
        await _addColumnIfMissing(
          m,
          employees,
          employees.biometricClockEnabled,
        );
      }

      if (from >= 2 && from < 18) {
        await _addColumnIfMissing(
          m,
          employees,
          employees.workStartTimeSaturday,
        );
      }

      if (from >= 2 && from < 19) {
        await _addColumnIfMissing(m, employees, employees.workEndTimeSaturday);
      }

      if (from < 20) {
        await _createTableIfMissing(m, users);
        await _createTableIfMissing(m, roles);
        await _createTableIfMissing(m, permissions);
        await _createTableIfMissing(m, rolePermissions);
        await _createTableIfMissing(m, userCompanyAccess);
      }

      if (from < 21) {
        await _addColumnIfMissing(m, payrollRuns, payrollRuns.isLocked);
        await _addColumnIfMissing(m, payrollRuns, payrollRuns.lockedAt);
        await _addColumnIfMissing(m, payrollRuns, payrollRuns.lockedByUserId);
      }

      if (from < 22) {
        await _addColumnIfMissing(m, companies, companies.mjtEmployerNumber);
        await _addColumnIfMissing(m, companies, companies.logoPng);
      }

      if (from < 23) {
        await _addColumnIfMissing(m, employees, employees.firstNames);
        await _addColumnIfMissing(m, employees, employees.lastNames);

        final legacyEmployees = await select(employees).get();
        for (final employee in legacyEmployees) {
          final split = _splitLegacyEmployeeName(employee.fullName);
          final normalizedFullName = _composeEmployeeFullName(
            firstNames: split.$1,
            lastNames: split.$2,
          );
          await update(employees).replace(
            employee.copyWith(
              firstNames: split.$1,
              lastNames: split.$2,
              fullName: normalizedFullName,
            ),
          );
        }
      }

      if (from < 24) {
        await _addColumnIfMissing(m, companies, companies.abbreviation);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _seedSecurityModel();
    },
  );

  Future<void> _seedSecurityModel() async {
    await transaction(() async {
      final permissionDescriptions = <String, String>{
        PermissionKeys.usersRead: 'Ver usuarios.',
        PermissionKeys.usersCreate: 'Crear usuarios.',
        PermissionKeys.usersUpdate: 'Actualizar usuarios.',
        PermissionKeys.usersDisable: 'Desactivar usuarios.',
        PermissionKeys.usersResetPassword: 'Resetear contrasenas de usuarios.',
        PermissionKeys.rolesManage: 'Administrar roles y permisos.',
        PermissionKeys.companiesRead: 'Consultar empresas.',
        PermissionKeys.companiesCreate: 'Crear empresas.',
        PermissionKeys.companiesUpdate: 'Actualizar empresas.',
        PermissionKeys.companiesDelete: 'Eliminar empresas.',
        PermissionKeys.employeesRead: 'Consultar empleados.',
        PermissionKeys.employeesCreate: 'Crear empleados.',
        PermissionKeys.employeesUpdate: 'Actualizar empleados.',
        PermissionKeys.employeesDisable: 'Desactivar empleados.',
        PermissionKeys.employeesDelete: 'Eliminar empleados.',
        PermissionKeys.attendanceRead: 'Consultar asistencia.',
        PermissionKeys.attendanceEdit: 'Editar asistencia.',
        PermissionKeys.attendanceDelete: 'Eliminar eventos de asistencia.',
        PermissionKeys.attendanceImportClock: 'Importar marcaciones.',
        PermissionKeys.payrollRead: 'Consultar liquidacion.',
        PermissionKeys.payrollGenerate: 'Generar liquidacion.',
        PermissionKeys.payrollLock: 'Guardar y bloquear liquidacion.',
        PermissionKeys.payrollUnlock:
            'Desbloquear liquidacion con contrasena autorizada.',
        PermissionKeys.payrollPrint: 'Imprimir liquidacion y boletas.',
        PermissionKeys.payrollExport: 'Exportar liquidacion.',
        PermissionKeys.reportsRead: 'Consultar informes.',
        PermissionKeys.settingsRead: 'Consultar configuracion.',
        PermissionKeys.settingsUpdate: 'Actualizar configuracion.',
      };

      final permissionByKey = <String, Permission>{};
      for (final permissionKey in PermissionKeys.all) {
        final existing = await (select(
          permissions,
        )..where((tbl) => tbl.key.equals(permissionKey))).getSingleOrNull();
        final description = permissionDescriptions[permissionKey];
        if (existing == null) {
          final insertedId = await into(permissions).insert(
            PermissionsCompanion.insert(
              key: permissionKey,
              description: Value(description),
            ),
          );
          final inserted = await (select(
            permissions,
          )..where((tbl) => tbl.id.equals(insertedId))).getSingle();
          permissionByKey[permissionKey] = inserted;
        } else {
          if ((existing.description ?? '') != (description ?? '')) {
            await update(
              permissions,
            ).replace(existing.copyWith(description: Value(description)));
          }
          permissionByKey[permissionKey] = existing;
        }
      }

      final roleByName = <String, Role>{};
      for (final roleName in RoleNames.baseRoles) {
        final existing = await (select(
          roles,
        )..where((tbl) => tbl.name.equals(roleName))).getSingleOrNull();
        final description = defaultRoleDescriptions[roleName];
        if (existing == null) {
          final insertedId = await into(roles).insert(
            RolesCompanion.insert(
              name: roleName,
              description: Value(description),
            ),
          );
          final inserted = await (select(
            roles,
          )..where((tbl) => tbl.id.equals(insertedId))).getSingle();
          roleByName[roleName] = inserted;
        } else {
          if ((existing.description ?? '') != (description ?? '')) {
            await update(
              roles,
            ).replace(existing.copyWith(description: Value(description)));
          }
          roleByName[roleName] = existing;
        }
      }

      await _enforceRolePermissionMatrix(
        roleByName: roleByName,
        permissionByKey: permissionByKey,
      );

      final superAdminRole = roleByName[RoleNames.superAdmin];
      if (superAdminRole == null) {
        return;
      }

      final defaultSuperAdminUserId = await _ensureDefaultSuperAdminUser();
      await _ensureSuperAdminAccessToAllCompanies(
        superAdminRoleId: superAdminRole.id,
        ensureUserIds: {defaultSuperAdminUserId},
      );
    });
  }

  Future<void> _enforceRolePermissionMatrix({
    required Map<String, Role> roleByName,
    required Map<String, Permission> permissionByKey,
  }) async {
    final allPermissionsById = permissionByKey.values
        .map((permission) => permission.id)
        .toSet();
    final restrictedPermissionIds = PermissionKeys.superAdminOnly
        .map((permissionKey) => permissionByKey[permissionKey]?.id)
        .whereType<int>()
        .toSet();

    final existingRoles = await select(roles).get();
    for (final role in existingRoles) {
      final rolePermissionsRows = await (select(
        rolePermissions,
      )..where((tbl) => tbl.roleId.equals(role.id))).get();
      final currentPermissionIds = rolePermissionsRows
          .map((row) => row.permissionId)
          .toSet();

      Set<int> targetPermissionIds;
      if (role.name == RoleNames.superAdmin) {
        targetPermissionIds = allPermissionsById;
      } else {
        final matrixPermissions = baseRolePermissionMatrix[role.name];
        if (matrixPermissions != null) {
          targetPermissionIds = matrixPermissions
              .map((permissionKey) => permissionByKey[permissionKey]?.id)
              .whereType<int>()
              .toSet();
        } else {
          targetPermissionIds = currentPermissionIds.difference(
            restrictedPermissionIds,
          );
        }
      }

      final toDelete = currentPermissionIds.difference(targetPermissionIds);
      final toInsert = targetPermissionIds.difference(currentPermissionIds);

      for (final permissionId in toDelete) {
        await (delete(rolePermissions)..where(
              (tbl) =>
                  tbl.roleId.equals(role.id) &
                  tbl.permissionId.equals(permissionId),
            ))
            .go();
      }

      for (final permissionId in toInsert) {
        await into(rolePermissions).insert(
          RolePermissionsCompanion.insert(
            roleId: role.id,
            permissionId: permissionId,
          ),
        );
      }
    }
  }

  Future<int> _ensureDefaultSuperAdminUser() async {
    final normalizedUsername = SecurityBootstrap.defaultSuperAdminUsername;
    final existing =
        await (select(users)
              ..where((tbl) => tbl.username.equals(normalizedUsername)))
            .getSingleOrNull();

    if (existing != null) {
      if (!existing.active) {
        await update(users).replace(existing.copyWith(active: true));
      }
      return existing.id;
    }

    final passwordHash = PasswordHasher.hash(
      username: normalizedUsername,
      password: SecurityBootstrap.defaultSuperAdminPassword,
    );
    return into(users).insert(
      UsersCompanion.insert(
        username: normalizedUsername,
        passwordHash: passwordHash,
        fullName: 'Super Admin',
        active: const Value(true),
      ),
    );
  }

  Future<void> _ensureSuperAdminAccessToAllCompanies({
    required int superAdminRoleId,
    required Set<int> ensureUserIds,
  }) async {
    final allCompanies = await select(companies).get();
    if (allCompanies.isEmpty) {
      return;
    }

    final existingSuperAdminAccess =
        await (select(userCompanyAccess)..where(
              (tbl) =>
                  tbl.roleId.equals(superAdminRoleId) & tbl.active.equals(true),
            ))
            .get();
    final superAdminUsers = {
      ...existingSuperAdminAccess.map((entry) => entry.userId),
      ...ensureUserIds,
    };

    for (final userId in superAdminUsers) {
      for (final company in allCompanies) {
        await into(userCompanyAccess).insert(
          UserCompanyAccessCompanion.insert(
            userId: userId,
            companyId: company.id,
            roleId: superAdminRoleId,
            active: const Value(true),
          ),
          onConflict: DoUpdate(
            (_) => UserCompanyAccessCompanion(
              roleId: Value(superAdminRoleId),
              active: const Value(true),
            ),
            target: [userCompanyAccess.userId, userCompanyAccess.companyId],
          ),
        );
      }
    }
  }

  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo<Table, dynamic> table,
    GeneratedColumn column,
  ) async {
    final rows = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    final existingColumns = rows.map((row) => row.read<String>('name')).toSet();

    if (!existingColumns.contains(column.$name)) {
      await m.addColumn(table, column);
    }
  }

  Future<void> _createTableIfMissing(
    Migrator m,
    TableInfo<Table, dynamic> table,
  ) async {
    final rows = await customSelect(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
      variables: [
        Variable.withString('table'),
        Variable.withString(table.actualTableName),
      ],
    ).get();

    if (rows.isEmpty) {
      await m.createTable(table);
    }
  }

  (String, String) _splitLegacyEmployeeName(String fullName) {
    final normalized = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return ('', '');
    }
    final parts = normalized.split(' ');
    if (parts.length == 1) {
      return (parts.first, '');
    }
    if (parts.length == 2) {
      return (parts.first, parts.last);
    }
    if (parts.length == 3) {
      return ('${parts[0]} ${parts[1]}', parts[2]);
    }
    final firstNames = parts.sublist(0, parts.length - 2).join(' ');
    final lastNames = parts.sublist(parts.length - 2).join(' ');
    return (firstNames, lastNames);
  }

  String _composeEmployeeFullName({
    required String firstNames,
    required String lastNames,
  }) {
    final normalizedFirstNames = firstNames.trim();
    final normalizedLastNames = lastNames.trim();
    if (normalizedFirstNames.isEmpty) {
      return normalizedLastNames;
    }
    if (normalizedLastNames.isEmpty) {
      return normalizedFirstNames;
    }
    return '$normalizedFirstNames $normalizedLastNames';
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDirectory = await getApplicationSupportDirectory();
    final dbFile = File(p.join(dbDirectory.path, 'rrhh_app.sqlite'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
