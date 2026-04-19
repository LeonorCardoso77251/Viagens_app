import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/users.dart';
import 'tables/trips.dart';
import 'tables/trip_members.dart';
import 'tables/destination_options.dart';
import 'tables/votes.dart';
import 'tables/tasks.dart';
import 'tables/expenses.dart';
import 'tables/expense_splits.dart';

import 'dao/trips_dao.dart';
import 'dao/users_dao.dart';
import 'dao/destination_options_dao.dart';
import 'dao/tasks_dao.dart';
import 'dao/expenses_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Trips,
    TripMembers,
    DestinationOptions,
    Votes,
    Tasks,
    Expenses,
    ExpenseSplits,
  ],
  daos: [UsersDao, TripsDao, DestinationOptionsDao, TasksDao, ExpensesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'trip_planner.sqlite'));
      return NativeDatabase(file);
    });
  }
}
