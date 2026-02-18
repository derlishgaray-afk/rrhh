part of '../app_database.dart';

class PayrollItemWithEmployee {
  PayrollItemWithEmployee({
    required this.item,
    required this.employee,
    required this.run,
    required this.departmentName,
  });

  final PayrollItem item;
  final Employee employee;
  final PayrollRun run;
  final String? departmentName;
}

@DriftAccessor(tables: [PayrollRuns, PayrollItems, Employees, Departments])
class PayrollDao extends DatabaseAccessor<AppDatabase> with _$PayrollDaoMixin {
  PayrollDao(super.db);

  Future<PayrollRun?> getPayrollRunByPeriod({
    required int companyId,
    required int year,
    required int month,
  }) {
    return (select(payrollRuns)..where(
          (tbl) =>
              tbl.companyId.equals(companyId) &
              tbl.year.equals(year) &
              tbl.month.equals(month),
        ))
        .getSingleOrNull();
  }

  Future<int> insertPayrollRun(PayrollRunsCompanion run) {
    return into(payrollRuns).insert(run);
  }

  Future<bool> updatePayrollRun(PayrollRun run) {
    return update(payrollRuns).replace(run);
  }

  Future<int> deleteItemsByRun(int payrollRunId) {
    return (delete(
      payrollItems,
    )..where((tbl) => tbl.payrollRunId.equals(payrollRunId))).go();
  }

  Future<void> insertPayrollItems(List<PayrollItemsCompanion> items) async {
    if (items.isEmpty) {
      return;
    }

    await batch((batch) {
      batch.insertAll(payrollItems, items);
    });
  }

  Future<PayrollItem?> getPayrollItemById(int payrollItemId) {
    return (select(
      payrollItems,
    )..where((tbl) => tbl.id.equals(payrollItemId))).getSingleOrNull();
  }

  Future<bool> updatePayrollItem(PayrollItem item) {
    return update(payrollItems).replace(item);
  }

  Future<List<PayrollItemWithEmployee>> getPayrollItemsByPeriod({
    required int companyId,
    required int year,
    required int month,
  }) async {
    final query =
        select(payrollItems).join([
            innerJoin(
              payrollRuns,
              payrollRuns.id.equalsExp(payrollItems.payrollRunId),
            ),
            innerJoin(
              employees,
              employees.id.equalsExp(payrollItems.employeeId),
            ),
            leftOuterJoin(
              departments,
              departments.id.equalsExp(employees.departmentId),
            ),
          ])
          ..where(
            payrollItems.companyId.equals(companyId) &
                payrollRuns.year.equals(year) &
                payrollRuns.month.equals(month),
          )
          ..orderBy([
            OrderingTerm.asc(departments.name),
            OrderingTerm.asc(employees.fullName),
          ]);

    final rows = await query.get();

    return rows
        .map(
          (row) => PayrollItemWithEmployee(
            item: row.readTable(payrollItems),
            employee: row.readTable(employees),
            run: row.readTable(payrollRuns),
            departmentName: row.readTableOrNull(departments)?.name,
          ),
        )
        .toList();
  }
}
