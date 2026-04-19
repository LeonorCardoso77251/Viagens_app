import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get email =>
      text().withLength(min: 1, max: 255).customConstraint('UNIQUE NOT NULL')();

  TextColumn get passwordHash => text().named('password_hash')();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
}
