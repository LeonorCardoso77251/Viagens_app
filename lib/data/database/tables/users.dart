import 'package:drift/drift.dart';

class Users extends Table {

  // ID LOCAL SQLITE
  IntColumn get id => integer().autoIncrement()();

  // UID DO FIREBASE
  TextColumn get firebaseUid =>
      text().named('firebase_uid').unique()();

  // NOME
  TextColumn get name =>
      text().withLength(min: 1, max: 100)();

  // EMAIL
  TextColumn get email =>
      text()
          .withLength(min: 1, max: 255)
          .customConstraint('UNIQUE NOT NULL')();


  TextColumn get photoUrl =>
      text().nullable()();


  DateTimeColumn get createdAt =>
      dateTime()
          .named('created_at')
          .withDefault(currentDateAndTime)();
}