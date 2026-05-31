import 'package:drift/drift.dart';

import '../app_database.dart';

import '../tables/trip_members.dart';
import '../tables/trips.dart';
import '../tables/users.dart';

part 'trips_dao.g.dart';

@DriftAccessor(tables: [Trips, TripMembers, Users])
class TripsDao extends DatabaseAccessor<AppDatabase> with _$TripsDaoMixin {
  TripsDao(super.attachedDatabase);

  // CRIAR VIAGEM
  Future<Trip> createTrip({
    required String name,

    String? description,

    String? destination,

    required DateTime startDate,

    required DateTime endDate,

    required int createdByUserId,
  }) async {
    return transaction(() async {
      // CRIAR VIAGEM
      final trip = await into(trips).insertReturning(
        TripsCompanion.insert(
          name: name,

          description: Value(description),

          destination: Value(destination),

          startDate: startDate,

          endDate: endDate,

          createdBy: createdByUserId,
        ),
      );

      // ADICIONAR CRIADOR
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

  // VIAGENS DO UTILIZADOR
  Stream<List<Trip>> watchTripsForUser(int userId) {
    final query = select(trips).join([
      innerJoin(tripMembers, tripMembers.tripId.equalsExp(trips.id)),
    ])..where(tripMembers.userId.equals(userId));

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(trips)).toList(),
    );
  }

  // NOMES PARTICIPANTES
  Future<List<String>> getParticipantNamesForTrip(int tripId) {
    final query = select(users).join([
      innerJoin(tripMembers, tripMembers.userId.equalsExp(users.id)),
    ])..where(tripMembers.tripId.equals(tripId));

    return query.get().then(
      (rows) => rows.map((row) => row.readTable(users).name).toList(),
    );
  }

  // UTILIZADORES DA VIAGEM
  Future<List<User>> getUsersForTrip(int tripId) async {
    final query = select(users).join([
      innerJoin(tripMembers, tripMembers.userId.equalsExp(users.id)),
    ])..where(tripMembers.tripId.equals(tripId));

    final rows = await query.get();

    return rows.map((row) => row.readTable(users)).toList();
  }

  // ADICIONAR UTILIZADOR À VIAGEM
  Future<void> addUserToTrip({
    required int tripId,

    required int userId,

    bool isAdmin = false,
  }) async {
    await into(tripMembers).insert(
      TripMembersCompanion.insert(
        tripId: tripId,

        userId: userId,

        isAdmin: Value(isAdmin),
      ),
    );
  }

  // ATUALIZAR VIAGEM
  Future<void> updateTrip({
    required int tripId,

    required String name,

    String? description,

    String? destination,

    required DateTime startDate,

    required DateTime endDate,
  }) async {
    await (update(trips)..where((t) => t.id.equals(tripId))).write(
      TripsCompanion(
        name: Value(name),

        description: Value(description),

        destination: Value(destination),

        startDate: Value(startDate),

        endDate: Value(endDate),
      ),
    );
  }

  // ATUALIZAR PARTICIPANTES DA VIAGEM
  // Preserva o criador (isAdmin=true) e sincroniza os restantes
  Future<void> updateTripParticipants({
    required int tripId,

    required int createdByUserId,

    required List<int> userIds,
  }) async {
    await transaction(() async {
      // REMOVER membros que não estão na nova lista (exceto o criador)
      await (delete(tripMembers)..where(
            (tm) =>
                tm.tripId.equals(tripId) &
                tm.userId.isNotIn(userIds) &
                tm.userId.equals(createdByUserId).not(),
          ))
          .go();

      // ADICIONAR membros novos (que ainda não existem)
      for (final userId in userIds) {
        final jaExiste =
            await (select(tripMembers)..where(
                  (tm) => tm.tripId.equals(tripId) & tm.userId.equals(userId),
                ))
                .getSingleOrNull();

        if (jaExiste == null) {
          await into(
            tripMembers,
          ).insert(TripMembersCompanion.insert(tripId: tripId, userId: userId));
        }
      }
    });
  }

  // BUSCAR VIAGEM POR ID
  Future<Trip?> getTripById(int tripId) async {
    return (select(trips)..where((t) => t.id.equals(tripId))).getSingleOrNull();
  }
}
