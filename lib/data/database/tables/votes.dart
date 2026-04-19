import 'package:drift/drift.dart';
import 'destination_options.dart';
import 'users.dart';

class Votes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get destinationId => integer()
      .named('destination_id')
      .references(DestinationOptions, #id, onDelete: KeyAction.cascade)();

  IntColumn get userId => integer()
      .named('user_id')
      .references(Users, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {destinationId, userId},
  ];
}
