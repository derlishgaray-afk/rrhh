import 'package:drift/drift.dart';

import '../data/database/app_database.dart';

class AdvancesService {
  AdvancesService(this._advancesDao);

  final AdvancesDao _advancesDao;

  Future<int> createAdvance({
    required int companyId,
    required int employeeId,
    required DateTime date,
    required double amount,
    String? reason,
  }) {
    final input = _sanitizeAndValidate(
      companyId: companyId,
      employeeId: employeeId,
      date: date,
      amount: amount,
      reason: reason,
    );

    return _advancesDao.insertAdvance(
      AdvancesCompanion.insert(
        companyId: input.companyId,
        employeeId: input.employeeId,
        date: input.date,
        amount: input.amount,
        reason: Value(input.reason),
      ),
    );
  }

  Future<bool> updateAdvance({
    required Advance currentAdvance,
    required int employeeId,
    required DateTime date,
    required double amount,
    String? reason,
  }) {
    final input = _sanitizeAndValidate(
      companyId: currentAdvance.companyId,
      employeeId: employeeId,
      date: date,
      amount: amount,
      reason: reason,
    );

    final updatedAdvance = currentAdvance.copyWith(
      employeeId: input.employeeId,
      date: input.date,
      amount: input.amount,
      reason: Value(input.reason),
    );

    return _advancesDao.updateAdvance(updatedAdvance);
  }

  Future<int> deleteAdvance(int advanceId) {
    if (advanceId <= 0) {
      throw ArgumentError('El anticipo no es valido.');
    }

    return _advancesDao.deleteAdvance(advanceId);
  }

  Future<List<Advance>> listAdvancesByMonth({
    required int companyId,
    required int year,
    required int month,
  }) {
    if (companyId <= 0) {
      throw ArgumentError('La empresa no es valida.');
    }
    if (year < 2000 || year > 2200) {
      throw ArgumentError('El ano no es valido.');
    }
    if (month < 1 || month > 12) {
      throw ArgumentError('El mes no es valido.');
    }

    return _advancesDao.getAdvancesByMonth(
      companyId: companyId,
      year: year,
      month: month,
    );
  }

  _AdvanceInput _sanitizeAndValidate({
    required int companyId,
    required int employeeId,
    required DateTime date,
    required double amount,
    String? reason,
  }) {
    if (companyId <= 0 || employeeId <= 0) {
      throw ArgumentError('La empresa o empleado no es valido.');
    }

    if (amount <= 0) {
      throw ArgumentError('El monto debe ser mayor que cero.');
    }

    return _AdvanceInput(
      companyId: companyId,
      employeeId: employeeId,
      date: DateTime(date.year, date.month, date.day),
      amount: amount,
      reason: _normalizeOptional(reason),
    );
  }

  String? _normalizeOptional(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}

class _AdvanceInput {
  const _AdvanceInput({
    required this.companyId,
    required this.employeeId,
    required this.date,
    required this.amount,
    required this.reason,
  });

  final int companyId;
  final int employeeId;
  final DateTime date;
  final double amount;
  final String? reason;
}
