part of '../app_database.dart';

@DriftAccessor(tables: [Departments, DepartmentSectors])
class DepartmentsDao extends DatabaseAccessor<AppDatabase>
    with _$DepartmentsDaoMixin {
  DepartmentsDao(super.db);

  Future<int> insertDepartment(DepartmentsCompanion department) {
    return into(departments).insert(department);
  }

  Future<bool> updateDepartment(Department department) {
    return update(departments).replace(department);
  }

  Future<int> deleteDepartment(int departmentId) {
    return (delete(
      departments,
    )..where((tbl) => tbl.id.equals(departmentId))).go();
  }

  Future<Department?> getDepartmentById(int departmentId) {
    return (select(
      departments,
    )..where((tbl) => tbl.id.equals(departmentId))).getSingleOrNull();
  }

  Future<List<Department>> getDepartmentsByCompany(int companyId) {
    return (select(departments)
          ..where((tbl) => tbl.companyId.equals(companyId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  Future<int> insertSector(DepartmentSectorsCompanion sector) {
    return into(departmentSectors).insert(sector);
  }

  Future<bool> updateSector(DepartmentSector sector) {
    return update(departmentSectors).replace(sector);
  }

  Future<int> deleteSector(int sectorId) {
    return (delete(
      departmentSectors,
    )..where((tbl) => tbl.id.equals(sectorId))).go();
  }

  Future<DepartmentSector?> getSectorById(int sectorId) {
    return (select(
      departmentSectors,
    )..where((tbl) => tbl.id.equals(sectorId))).getSingleOrNull();
  }

  Future<List<DepartmentSector>> getSectorsByDepartment(int departmentId) {
    return (select(departmentSectors)
          ..where((tbl) => tbl.departmentId.equals(departmentId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }
}
