import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/expenses.dart';
import '../tables/expense_splits.dart';

part 'expenses_dao.g.dart';

class ExpenseSplitInput {
  final int userId;
  final int amountCents;

  const ExpenseSplitInput({required this.userId, required this.amountCents});
}

@DriftAccessor(tables: [Expenses, ExpenseSplits])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.attachedDatabase);

  Future<Expense> createExpense({
    required int paidBy,
    required int tripId,
    required String title,
    String? description,
    required int amountCents,
    required List<ExpenseSplitInput> splits,
  }) async {
    final splitTotal = splits.fold<int>(
      0,
      (sum, split) => sum + split.amountCents,
    );

    if (splitTotal != amountCents) {
      throw ArgumentError(
        'The sum of expense splits must equal the total expense amount.',
      );
    }

    return transaction(() async {
      final expense = await into(expenses).insertReturning(
        ExpensesCompanion.insert(
          paidBy: paidBy,
          tripId: tripId,
          title: title,
          description: Value(description),
          amountCents: amountCents,
        ),
      );

      for (final split in splits) {
        await into(expenseSplits).insert(
          ExpenseSplitsCompanion.insert(
            expenseId: expense.id,
            userId: split.userId,
            amountCents: split.amountCents,
          ),
        );
      }

      return expense;
    });
  }

  Future<List<Expense>> getExpensesForTrip(int tripId) {
    return (select(expenses)
          ..where((e) => e.tripId.equals(tripId))
          ..orderBy([(e) => OrderingTerm(expression: e.createdAt)]))
        .get();
  }

  Stream<List<Expense>> watchExpensesForTrip(int tripId) {
    return (select(expenses)
          ..where((e) => e.tripId.equals(tripId))
          ..orderBy([(e) => OrderingTerm(expression: e.createdAt)]))
        .watch();
  }

  Future<List<ExpenseSplit>> getSplitsForExpense(int expenseId) {
    return (select(
      expenseSplits,
    )..where((s) => s.expenseId.equals(expenseId))).get();
  }

  Future<void> deleteExpense(int expenseId) async {
    await (delete(expenses)..where((e) => e.id.equals(expenseId))).go();
  }

  Future<int> getTotalExpensesForTrip(int tripId) async {
    final totalExpression = expenses.amountCents.sum();
    final query = selectOnly(expenses)
      ..addColumns([totalExpression])
      ..where(expenses.tripId.equals(tripId));

    final row = await query.getSingle();
    return row.read(totalExpression) ?? 0;
  }

  Stream<int> watchTotalExpensesForTrip(int tripId) {
    final totalExpression = expenses.amountCents.sum();
    final query = selectOnly(expenses)
      ..addColumns([totalExpression])
      ..where(expenses.tripId.equals(tripId));

    return query.watchSingle().map((row) => row.read(totalExpression) ?? 0);
  }
}
