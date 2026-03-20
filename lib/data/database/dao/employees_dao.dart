part of '../app_database.dart';

@DriftAccessor(tables: [Employees])
class EmployeesDao extends DatabaseAccessor<AppDatabase>
    with _$EmployeesDaoMixin {
  EmployeesDao(super.db);

  Future<int> insertEmployee(EmployeesCompanion employee) {
    return into(employees).insert(employee);
  }

  Future<bool> updateEmployee(Employee employee) {
    return update(employees).replace(employee);
  }

  Future<int> deleteEmployee(int employeeId) {
    return (delete(employees)..where((tbl) => tbl.id.equals(employeeId))).go();
  }

  Future<bool> hasMovements(int employeeId) async {
    final hasAttendance =
        await (select(db.attendanceEvents)
              ..where((tbl) => tbl.employeeId.equals(employeeId))
              ..limit(1))
            .getSingleOrNull();
    if (hasAttendance != null) {
      return true;
    }

    final hasAdvances =
        await (select(db.advances)
              ..where((tbl) => tbl.employeeId.equals(employeeId))
              ..limit(1))
            .getSingleOrNull();
    if (hasAdvances != null) {
      return true;
    }

    final hasPayrollItems =
        await (select(db.payrollItems)
              ..where((tbl) => tbl.employeeId.equals(employeeId))
              ..limit(1))
            .getSingleOrNull();
    return hasPayrollItems != null;
  }

  Future<Employee?> getEmployeeById(int employeeId) {
    return (select(
      employees,
    )..where((tbl) => tbl.id.equals(employeeId))).getSingleOrNull();
  }

  Future<List<Employee>> getEmployeesByCompany(int companyId) {
    return (select(employees)
          ..where((tbl) => tbl.companyId.equals(companyId))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.lastNames),
            (tbl) => OrderingTerm.asc(tbl.firstNames),
          ]))
        .get();
  }

  Future<List<Employee>> getEmployees() {
    return (select(employees)..orderBy([
          (tbl) => OrderingTerm.asc(tbl.companyId),
          (tbl) => OrderingTerm.asc(tbl.lastNames),
          (tbl) => OrderingTerm.asc(tbl.firstNames),
        ]))
        .get();
  }

  Future<List<Employee>> getActiveEmployeesByCompany(int companyId) {
    return (select(employees)
          ..where(
            (tbl) => tbl.companyId.equals(companyId) & tbl.active.equals(true),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.lastNames),
            (tbl) => OrderingTerm.asc(tbl.firstNames),
          ]))
        .get();
  }

  Future<List<Employee>> searchEmployeesByName(int companyId, String query) {
    final normalizedQuery = _normalizeSearchText(query);
    if (normalizedQuery.isEmpty) {
      return getEmployeesByCompany(companyId);
    }

    return getEmployeesByCompany(companyId).then(
      (rows) => rows.where((employee) {
        final searchableValues = <String>[
          employee.firstNames,
          employee.lastNames,
          employee.fullName,
          employee.documentNumber,
          employee.workLocation ?? '',
        ];
        return searchableValues.any(
          (value) => _normalizeSearchText(value).contains(normalizedQuery),
        );
      }).toList(),
    );
  }

  String _normalizeSearchText(String value) {
    var normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }

    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    replacements.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });

    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    return normalized;
  }
}
