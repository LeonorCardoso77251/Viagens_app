import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/trips.dart';
import '../tables/trip_members.dart';

part 'trips_dao.g.dart';

@DriftAccessor(tables: [Trips, TripMembers])
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
}
