// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_dao.dart';

// ignore_for_file: type=lint
mixin _$TasksDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $TripsTable get trips => attachedDatabase.trips;
  $TasksTable get tasks => attachedDatabase.tasks;
  TasksDaoManager get managers => TasksDaoManager(this);
}

class TasksDaoManager {
  final _$TasksDaoMixin _db;
  TasksDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
}
