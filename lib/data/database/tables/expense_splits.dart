import 'package:drift/drift.dart';
import 'expenses.dart';
import 'users.dart';

class ExpenseSplits extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get expenseId => integer()
      .named('expense_id')
      .references(Expenses, #id, onDelete: KeyAction.cascade)();

  IntColumn get userId => integer().named('user_id').references(Users, #id)();

  IntColumn get amountCents => integer().named('amount_cents')();

  @override
  List<Set<Column>> get uniqueKeys => [
    {expenseId, userId},
  ];

  @override
  List<String> get customConstraints => ['CHECK (amount_cents >= 0)'];
}
