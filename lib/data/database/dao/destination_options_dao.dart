import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/destination_options.dart';
import '../tables/votes.dart';

part 'destination_options_dao.g.dart';

@DriftAccessor(tables: [DestinationOptions, Votes])
class DestinationOptionsDao extends DatabaseAccessor<AppDatabase>
    with _$DestinationOptionsDaoMixin {
  DestinationOptionsDao(super.attachedDatabase);

  Future<DestinationOption> addDestinationOption({
    required int tripId,
    required String destinationName,
    String? description,
    required int createdByUserId,
  }) {
    return into(destinationOptions).insertReturning(
      DestinationOptionsCompanion.insert(
        tripId: tripId,
        destinationName: destinationName,
        description: Value(description),
        createdBy: createdByUserId,
      ),
    );
  }

  Future<List<DestinationOption>> getDestinationsForTrip(int tripId) {
    return (select(destinationOptions)
          ..where((d) => d.tripId.equals(tripId))
          ..orderBy([(d) => OrderingTerm(expression: d.destinationName)]))
        .get();
  }

  Stream<List<DestinationOption>> watchDestinationsForTrip(int tripId) {
    return (select(destinationOptions)
          ..where((d) => d.tripId.equals(tripId))
          ..orderBy([(d) => OrderingTerm(expression: d.destinationName)]))
        .watch();
  }

  Future<void> voteForDestination({
    required int destinationId,
    required int userId,
  }) async {
    await into(votes).insert(
      VotesCompanion.insert(destinationId: destinationId, userId: userId),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeVote({
    required int destinationId,
    required int userId,
  }) async {
    await (delete(votes)..where(
          (v) =>
              v.destinationId.equals(destinationId) & v.userId.equals(userId),
        ))
        .go();
  }

  Future<int> getVoteCountForDestination(int destinationId) async {
    final countExpression = votes.id.count();
    final query = selectOnly(votes)
      ..addColumns([countExpression])
      ..where(votes.destinationId.equals(destinationId));

    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }

  Stream<int> watchVoteCountForDestination(int destinationId) {
    final countExpression = votes.id.count();
    final query = selectOnly(votes)
      ..addColumns([countExpression])
      ..where(votes.destinationId.equals(destinationId));

    return query.watchSingle().map((row) => row.read(countExpression) ?? 0);
  }

  Future<bool> hasUserVoted({
    required int destinationId,
    required int userId,
  }) async {
    final vote =
        await (select(votes)..where(
              (v) =>
                  v.destinationId.equals(destinationId) &
                  v.userId.equals(userId),
            ))
            .getSingleOrNull();

    return vote != null;
  }
}
