import 'package:drift/drift.dart';
import 'users.dart';
import 'trips.dart';

class TripMembers extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()
      .named('user_id')
      .references(Users, #id, onDelete: KeyAction.cascade)();

  IntColumn get tripId => integer()
      .named('trip_id')
      .references(Trips, #id, onDelete: KeyAction.cascade)();

  BoolColumn get isAdmin =>
      boolean().named('is_admin').withDefault(const Constant(false))();

  DateTimeColumn get joinedAt =>
      dateTime().named('joined_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {tripId, userId},
  ];
}
