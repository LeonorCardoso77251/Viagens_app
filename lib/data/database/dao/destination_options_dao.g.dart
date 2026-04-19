// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_options_dao.dart';

// ignore_for_file: type=lint
mixin _$DestinationOptionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $TripsTable get trips => attachedDatabase.trips;
  $DestinationOptionsTable get destinationOptions =>
      attachedDatabase.destinationOptions;
  $VotesTable get votes => attachedDatabase.votes;
  DestinationOptionsDaoManager get managers =>
      DestinationOptionsDaoManager(this);
}

class DestinationOptionsDaoManager {
  final _$DestinationOptionsDaoMixin _db;
  DestinationOptionsDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
  $$DestinationOptionsTableTableManager get destinationOptions =>
      $$DestinationOptionsTableTableManager(
        _db.attachedDatabase,
        _db.destinationOptions,
      );
  $$VotesTableTableManager get votes =>
      $$VotesTableTableManager(_db.attachedDatabase, _db.votes);
}
