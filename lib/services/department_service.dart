import 'package:drift/drift.dart';

import '../data/database/app_database.dart';

class DepartmentService {
  DepartmentService(this._departmentsDao);

  final DepartmentsDao _departmentsDao;

  Future<int> createDepartment({
    required int companyId,
    required String name,
    String? description,
    bool active = true,
  }) {
    _validateCompanyId(companyId);
    final normalizedName = _normalizeName(name, 'departamento');

    return _departmentsDao.insertDepartment(
      DepartmentsCompanion.insert(
        companyId: companyId,
        name: normalizedName,
        description: Value(_toOptionalString(description)),
        active: Value(active),
      ),
    );
  }

  Future<bool> updateDepartment({
    required Department currentDepartment,
    required String name,
    String? description,
    required bool active,
  }) {
    final normalizedName = _normalizeName(name, 'departamento');
    final updatedDepartment = currentDepartment.copyWith(
      name: normalizedName,
      description: Value(_toOptionalString(description)),
      active: active,
    );
    return _departmentsDao.updateDepartment(updatedDepartment);
  }

  Future<int> deleteDepartment(int departmentId) {
    _validateEntityId(departmentId, 'departamento');
    return _departmentsDao.deleteDepartment(departmentId);
  }

  Future<List<Department>> listDepartmentsByCompany(int companyId) {
    _validateCompanyId(companyId);
    return _departmentsDao.getDepartmentsByCompany(companyId);
  }

  Future<int> createSector({
    required int departmentId,
    required String name,
    bool active = true,
  }) {
    _validateEntityId(departmentId, 'departamento');
    final normalizedName = _normalizeName(name, 'sector');

    return _departmentsDao.insertSector(
      DepartmentSectorsCompanion.insert(
        departmentId: departmentId,
        name: normalizedName,
        active: Value(active),
      ),
    );
  }

  Future<bool> updateSector({
    required DepartmentSector currentSector,
    required String name,
    required bool active,
  }) {
    final normalizedName = _normalizeName(name, 'sector');
    final updatedSector = currentSector.copyWith(
      name: normalizedName,
      active: active,
    );
    return _departmentsDao.updateSector(updatedSector);
  }

  Future<int> deleteSector(int sectorId) {
    _validateEntityId(sectorId, 'sector');
    return _departmentsDao.deleteSector(sectorId);
  }

  Future<List<DepartmentSector>> listSectorsByDepartment(int departmentId) {
    _validateEntityId(departmentId, 'departamento');
    return _departmentsDao.getSectorsByDepartment(departmentId);
  }

  void _validateCompanyId(int companyId) {
    if (companyId <= 0) {
      throw ArgumentError('La empresa seleccionada no es valida.');
    }
  }

  void _validateEntityId(int id, String entityName) {
    if (id <= 0) {
      throw ArgumentError('El id de $entityName no es valido.');
    }
  }

  String _normalizeName(String value, String entityName) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('El nombre de $entityName es obligatorio.');
    }
    return normalized;
  }

  String? _toOptionalString(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
