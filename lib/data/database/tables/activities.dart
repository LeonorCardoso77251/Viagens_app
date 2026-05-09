import 'package:drift/drift.dart';
import 'trips.dart';

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get tripId => integer()
      .named('trip_id')
      .references(Trips, #id, onDelete: KeyAction.cascade)();

  TextColumn get nome => text()();

  DateTimeColumn get dataHora => dateTime()();

  TextColumn get local => text()();
}