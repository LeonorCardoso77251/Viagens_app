import 'package:drift/drift.dart';
import 'users.dart';
import 'trips.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get paidBy => integer().named('paid_by').references(Users, #id)();

  IntColumn get tripId => integer()
      .named('trip_id')
      .references(Trips, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().withLength(min: 1, max: 150)();

  TextColumn get description => text().nullable()();

  IntColumn get amountCents => integer().named('amount_cents')();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => ['CHECK (amount_cents >= 0)'];
}
