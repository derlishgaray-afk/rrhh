import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../security/security_constants.dart';
import 'authorization_service.dart';

class DepartmentService {
  DepartmentService(this._departmentsDao, this._authorizationService);

  final DepartmentsDao _departmentsDao;
  final AuthorizationService _authorizationService;

  Future<int> createDepartment({
    required int companyId,
    required String name,
    String? description,
    bool active = true,
  }) async {
    _validateCompanyId(companyId);
    await _authorizationService.ensurePermission(
      PermissionKeys.companiesUpdate,
      companyId: companyId,
    );
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
  }) async {
    await _authorizationService.ensurePermission(
      PermissionKeys.companiesUpdate,
      companyId: currentDepartment.companyId,
    );
    final normalizedName = _normalizeName(name, 'departamento');
    final updatedDepartment = currentDepartment.copyWith(
      name: normalizedName,
      description: Value(_toOptionalString(description)),
      active: active,
    );
    return _departmentsDao.updateDepartment(updatedDepartment);
  }

  Future<int> deleteDepartment(int departmentId) async {
    _validateEntityId(departmentId, 'departamento');
    final department = await _departmentsDao.getDepartmentById(departmentId);
    if (department != null) {
      await _authorizationService.ensurePermission(
        PermissionKeys.companiesDelete,
        companyId: department.companyId,
      );
    }

    final hasMovements = await _departmentsDao.departmentHasMovements(
      departmentId,
    );
    if (hasMovements) {
      throw ArgumentError(
        'No se puede eliminar el departamento porque tiene movimientos registrados.',
      );
    }

    return _departmentsDao.deleteDepartment(departmentId);
  }

  Future<List<Department>> listDepartmentsByCompany(int companyId) async {
    _validateCompanyId(companyId);
    await _authorizationService.ensurePermission(
      PermissionKeys.employeesRead,
      companyId: companyId,
    );
    return _departmentsDao.getDepartmentsByCompany(companyId);
  }

  Future<int> createSector({
    required int departmentId,
    required String name,
    bool active = true,
  }) async {
    _validateEntityId(departmentId, 'departamento');
    final department = await _departmentsDao.getDepartmentById(departmentId);
    if (department != null) {
      await _authorizationService.ensurePermission(
        PermissionKeys.companiesUpdate,
        companyId: department.companyId,
      );
    }
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
  }) async {
    final department = await _departmentsDao.getDepartmentById(
      currentSector.departmentId,
    );
    if (department != null) {
      await _authorizationService.ensurePermission(
        PermissionKeys.companiesUpdate,
        companyId: department.companyId,
      );
    }
    final normalizedName = _normalizeName(name, 'sector');
    final updatedSector = currentSector.copyWith(
      name: normalizedName,
      active: active,
    );
    return _departmentsDao.updateSector(updatedSector);
  }

  Future<int> deleteSector(int sectorId) async {
    _validateEntityId(sectorId, 'sector');
    final sector = await _departmentsDao.getSectorById(sectorId);
    if (sector != null) {
      final department = await _departmentsDao.getDepartmentById(
        sector.departmentId,
      );
      if (department != null) {
        await _authorizationService.ensurePermission(
          PermissionKeys.companiesDelete,
          companyId: department.companyId,
        );
      }
    }

    final hasMovements = await _departmentsDao.sectorHasMovements(sectorId);
    if (hasMovements) {
      throw ArgumentError(
        'No se puede eliminar el sector porque tiene movimientos registrados.',
      );
    }

    return _departmentsDao.deleteSector(sectorId);
  }

  Future<List<DepartmentSector>> listSectorsByDepartment(
    int departmentId,
  ) async {
    _validateEntityId(departmentId, 'departamento');
    final department = await _departmentsDao.getDepartmentById(departmentId);
    if (department != null) {
      await _authorizationService.ensurePermission(
        PermissionKeys.employeesRead,
        companyId: department.companyId,
      );
    }
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
