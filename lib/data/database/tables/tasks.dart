import 'package:drift/drift.dart';
import 'users.dart';
import 'trips.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get assignedTo =>
      integer().named('assigned_to').references(Users, #id)();

  IntColumn get tripId => integer()
      .named('trip_id')
      .references(Trips, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().withLength(min: 1, max: 150)();

  TextColumn get description => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('pending'))();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    "CHECK (status IN ('pending', 'in_progress', 'done'))",
  ];
}
