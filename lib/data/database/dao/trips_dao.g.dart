// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_dao.dart';

// ignore_for_file: type=lint
mixin _$TripsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $TripsTable get trips => attachedDatabase.trips;
  $TripMembersTable get tripMembers => attachedDatabase.tripMembers;
  TripsDaoManager get managers => TripsDaoManager(this);
}

class TripsDaoManager {
  final _$TripsDaoMixin _db;
  TripsDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
  $$TripMembersTableTableManager get tripMembers =>
      $$TripMembersTableTableManager(_db.attachedDatabase, _db.tripMembers);
}
