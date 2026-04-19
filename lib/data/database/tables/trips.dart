import 'package:drift/drift.dart';
import 'users.dart';

class Trips extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 150)();

  TextColumn get description => text().nullable()();

  DateTimeColumn get startDate => dateTime().named('start_date')();

  DateTimeColumn get endDate => dateTime().named('end_date')();

  IntColumn get createdBy =>
      integer().named('created_by').references(Users, #id)();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => ['CHECK (end_date >= start_date)'];
}
