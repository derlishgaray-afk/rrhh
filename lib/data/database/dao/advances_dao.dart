part of '../app_database.dart';

@DriftAccessor(tables: [Advances])
class AdvancesDao extends DatabaseAccessor<AppDatabase>
    with _$AdvancesDaoMixin {
  AdvancesDao(super.db);

  Future<int> insertAdvance(AdvancesCompanion advance) {
    return into(advances).insert(advance);
  }

  Future<bool> updateAdvance(Advance advance) {
    return update(advances).replace(advance);
  }

  Future<int> deleteAdvance(int advanceId) {
    return (delete(advances)..where((tbl) => tbl.id.equals(advanceId))).go();
  }

  Future<List<Advance>> getAdvancesByMonth({
    required int companyId,
    required int year,
    required int month,
  }) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    return (select(advances)
          ..where(
            (tbl) =>
                tbl.companyId.equals(companyId) &
                tbl.date.isBiggerOrEqualValue(start) &
                tbl.date.isSmallerThanValue(end),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.date),
            (tbl) => OrderingTerm.asc(tbl.id),
          ]))
        .get();
  }
}
