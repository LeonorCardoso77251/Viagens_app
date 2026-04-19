import 'package:drift/drift.dart';
import 'trips.dart';
import 'users.dart';

class DestinationOptions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get tripId => integer()
      .named('trip_id')
      .references(Trips, #id, onDelete: KeyAction.cascade)();

  TextColumn get destinationName =>
      text().named('destination_name').withLength(min: 1, max: 150)();

  TextColumn get description => text().nullable()();

  IntColumn get createdBy =>
      integer().named('created_by').references(Users, #id)();
}
