import 'package:drift/drift.dart';
import 'trips.dart';

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get tripId => integer()
      .references(Trips, #id)();

  TextColumn get nome => text()();

  DateTimeColumn get dataHora => dateTime()();

  TextColumn get local => text()();
}