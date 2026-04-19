// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_dao.dart';

// ignore_for_file: type=lint
mixin _$ExpensesDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $TripsTable get trips => attachedDatabase.trips;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  $ExpenseSplitsTable get expenseSplits => attachedDatabase.expenseSplits;
  ExpensesDaoManager get managers => ExpensesDaoManager(this);
}

class ExpensesDaoManager {
  final _$ExpensesDaoMixin _db;
  ExpensesDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
  $$ExpenseSplitsTableTableManager get expenseSplits =>
      $$ExpenseSplitsTableTableManager(_db.attachedDatabase, _db.expenseSplits);
}
