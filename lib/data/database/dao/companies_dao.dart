part of '../app_database.dart';

@DriftAccessor(tables: [Companies])
class CompaniesDao extends DatabaseAccessor<AppDatabase>
    with _$CompaniesDaoMixin {
  CompaniesDao(super.db);

  Future<int> insertCompany(CompaniesCompanion company) {
    return into(companies).insert(company);
  }

  Future<bool> updateCompany(Company company) {
    return update(companies).replace(company);
  }

  Future<int> deleteCompany(int companyId) {
    return (delete(companies)..where((tbl) => tbl.id.equals(companyId))).go();
  }

  Future<bool> hasMovements(int companyId) async {
    final hasAttendance =
        await (select(db.attendanceEvents)
              ..where((tbl) => tbl.companyId.equals(companyId))
              ..limit(1))
            .getSingleOrNull();
    if (hasAttendance != null) {
      return true;
    }

    final hasAdvances =
        await (select(db.advances)
              ..where((tbl) => tbl.companyId.equals(companyId))
              ..limit(1))
            .getSingleOrNull();
    if (hasAdvances != null) {
      return true;
    }

    final hasPayrollRuns =
        await (select(db.payrollRuns)
              ..where((tbl) => tbl.companyId.equals(companyId))
              ..limit(1))
            .getSingleOrNull();
    if (hasPayrollRuns != null) {
      return true;
    }

    final hasPayrollItems =
        await (select(db.payrollItems)
              ..where((tbl) => tbl.companyId.equals(companyId))
              ..limit(1))
            .getSingleOrNull();
    return hasPayrollItems != null;
  }

  Future<Company?> getCompanyById(int companyId) {
    return (select(
      companies,
    )..where((tbl) => tbl.id.equals(companyId))).getSingleOrNull();
  }

  Future<List<Company>> getCompanies() {
    return (select(
      companies,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.name)])).get();
  }
}
