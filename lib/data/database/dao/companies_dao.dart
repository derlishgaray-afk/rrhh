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
