import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/trip_members.dart';
import '../tables/trips.dart';
import '../tables/users.dart';

part 'trips_dao.g.dart';

@DriftAccessor(tables: [Trips, TripMembers, Users])
class TripsDao extends DatabaseAccessor<AppDatabase> with _$TripsDaoMixin {
  TripsDao(super.attachedDatabase);

  Future<Trip> createTrip({
    required String name,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    required int createdByUserId,
  }) async {
    return transaction(() async {
      final trip = await into(trips).insertReturning(
        TripsCompanion.insert(
          name: name,
          description: Value(description),
          startDate: startDate,
          endDate: endDate,
          createdBy: createdByUserId,
        ),
      );

      await into(tripMembers).insert(
        TripMembersCompanion.insert(
          userId: createdByUserId,
          tripId: trip.id,
          isAdmin: const Value(true),
        ),
      );

      final demoUser = await (select(
        users,
      )..where((u) => u.email.equals('demo@unitrip.local'))).getSingleOrNull();

      if (demoUser != null && demoUser.id != createdByUserId) {
        await into(tripMembers).insert(
          TripMembersCompanion.insert(
            userId: demoUser.id,
            tripId: trip.id,
            isAdmin: const Value(false),
          ),
        );
      }

      return trip;
    });
  }

  Stream<List<Trip>> watchTripsForUser(int userId) {
    final query = select(trips).join([
      innerJoin(tripMembers, tripMembers.tripId.equalsExp(trips.id)),
    ])..where(tripMembers.userId.equals(userId));

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(trips)).toList(),
    );
  }

  Future<List<String>> getParticipantNamesForTrip(int tripId) {
    final query = select(users).join([
      innerJoin(tripMembers, tripMembers.userId.equalsExp(users.id)),
    ])..where(tripMembers.tripId.equals(tripId));

    return query.get().then(
      (rows) => rows.map((row) => row.readTable(users).name).toList(),
    );
  }
}
