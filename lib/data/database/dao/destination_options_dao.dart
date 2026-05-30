import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/destination_options.dart';
import '../tables/trips.dart';
import '../tables/votes.dart';

part 'destination_options_dao.g.dart';

class DestinationWithVotes {
  final DestinationOption destination;
  final int voteCount;
  final bool hasVoted;

  DestinationWithVotes({
    required this.destination,
    required this.voteCount,
    required this.hasVoted,
  });
}

@DriftAccessor(tables: [DestinationOptions, Votes, Trips])
class DestinationOptionsDao extends DatabaseAccessor<AppDatabase>
    with _$DestinationOptionsDaoMixin {
  DestinationOptionsDao(super.attachedDatabase);

  // ADICIONAR OPÇÃO DE DESTINO
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

  // DESTINOS COM VOTOS (stream único para a UI)
  Stream<List<DestinationWithVotes>> watchDestinationsWithVotes({
    required int tripId,
    required int currentUserId,
  }) {
    final voteCount = votes.id.count();
    final hasVoted = votes.userId.equals(currentUserId).cast<bool>();

    final query =
        select(destinationOptions).join([
            leftOuterJoin(
              votes,
              votes.destinationId.equalsExp(destinationOptions.id),
            ),
          ])
          ..where(destinationOptions.tripId.equals(tripId))
          ..addColumns([voteCount, hasVoted])
          ..groupBy([destinationOptions.id])
          ..orderBy([
            OrderingTerm(expression: destinationOptions.destinationName),
          ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return DestinationWithVotes(
          destination: row.readTable(destinationOptions),
          voteCount: row.read(voteCount) ?? 0,
          hasVoted: row.read(hasVoted) ?? false,
        );
      }).toList();
    });
  }

  // VOTAR (um voto por viagem — remove voto anterior se existir)
  Future<void> voteForDestination({
    required int tripId,
    required int destinationId,
    required int userId,
  }) async {
    await transaction(() async {
      // REMOVER VOTO ANTERIOR nesta viagem
      await (delete(
        votes,
      )..where((v) => v.tripId.equals(tripId) & v.userId.equals(userId))).go();

      // INSERIR NOVO VOTO
      await into(votes).insert(
        VotesCompanion.insert(
          tripId: tripId,
          destinationId: destinationId,
          userId: userId,
        ),
      );
    });
  }

  // FECHAR VOTAÇÃO — define o destino vencedor na viagem e limpa as opções
  Future<void> closeVoting(int tripId) async {
    await transaction(() async {
      // CONTAR VOTOS POR DESTINO
      final voteCount = votes.id.count();

      final query =
          select(destinationOptions).join([
              leftOuterJoin(
                votes,
                votes.destinationId.equalsExp(destinationOptions.id),
              ),
            ])
            ..where(destinationOptions.tripId.equals(tripId))
            ..addColumns([voteCount])
            ..groupBy([destinationOptions.id])
            ..orderBy([
              OrderingTerm(expression: voteCount, mode: OrderingMode.desc),
            ])
            ..limit(1);

      final rows = await query.get();

      if (rows.isEmpty) return;

      final winner = rows.first.readTable(destinationOptions);

      // DEFINIR DESTINO VENCEDOR NA VIAGEM
      await (update(trips)..where((t) => t.id.equals(tripId))).write(
        TripsCompanion(destination: Value(winner.destinationName)),
      );

      // APAGAR OPÇÕES DE DESTINO (já não são necessárias)
      await (delete(
        destinationOptions,
      )..where((d) => d.tripId.equals(tripId))).go();
    });
  }
}
