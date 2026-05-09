// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activities_dao.dart';

// ignore_for_file: type=lint
mixin _$ActivitiesDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $TripsTable get trips => attachedDatabase.trips;
  $ActivitiesTable get activities => attachedDatabase.activities;
  ActivitiesDaoManager get managers => ActivitiesDaoManager(this);
}

class ActivitiesDaoManager {
  final _$ActivitiesDaoMixin _db;
  ActivitiesDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db.attachedDatabase, _db.activities);
}
