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

  Future<Employee?> getEmployeeById(int employeeId) {
    return (select(
      employees,
    )..where((tbl) => tbl.id.equals(employeeId))).getSingleOrNull();
  }

  Future<List<Employee>> getEmployeesByCompany(int companyId) {
    return (select(employees)
          ..where((tbl) => tbl.companyId.equals(companyId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fullName)]))
        .get();
  }

  Future<List<Employee>> getEmployees() {
    return (select(employees)..orderBy([
          (tbl) => OrderingTerm.asc(tbl.companyId),
          (tbl) => OrderingTerm.asc(tbl.fullName),
        ]))
        .get();
  }

  Future<List<Employee>> getActiveEmployeesByCompany(int companyId) {
    return (select(employees)
          ..where(
            (tbl) => tbl.companyId.equals(companyId) & tbl.active.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fullName)]))
        .get();
  }

  Future<List<Employee>> searchEmployeesByName(int companyId, String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return getEmployeesByCompany(companyId);
    }

    return (select(employees)
          ..where(
            (tbl) =>
                tbl.companyId.equals(companyId) &
                tbl.fullName.like('%$normalizedQuery%'),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.fullName)]))
        .get();
  }
}
