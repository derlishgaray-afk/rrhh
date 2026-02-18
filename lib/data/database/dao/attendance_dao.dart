part of '../app_database.dart';

@DriftAccessor(tables: [AttendanceEvents])
class AttendanceDao extends DatabaseAccessor<AppDatabase>
    with _$AttendanceDaoMixin {
  AttendanceDao(super.db);

  Future<int> insertAttendanceEvent(AttendanceEventsCompanion event) {
    return into(attendanceEvents).insert(event);
  }

  Future<bool> updateAttendanceEvent(AttendanceEvent event) {
    return update(attendanceEvents).replace(event);
  }

  Future<int> deleteAttendanceEvent(int eventId) {
    return (delete(
      attendanceEvents,
    )..where((tbl) => tbl.id.equals(eventId))).go();
  }

  Future<List<AttendanceEvent>> getAttendanceByMonth({
    required int companyId,
    required int year,
    required int month,
  }) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    return (select(attendanceEvents)
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

  Future<AttendanceEvent?> getAttendanceByEmployeeAndDate({
    required int companyId,
    required int employeeId,
    required DateTime date,
  }) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final nextDay = dayStart.add(const Duration(days: 1));

    return (select(attendanceEvents)
          ..where(
            (tbl) =>
                tbl.companyId.equals(companyId) &
                tbl.employeeId.equals(employeeId) &
                tbl.date.isBiggerOrEqualValue(dayStart) &
                tbl.date.isSmallerThanValue(nextDay),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.id)])
          ..limit(1))
        .getSingleOrNull();
  }
}
