import 'package:flutter/material.dart';

import '../../data/database/dao/destination_options_dao.dart';

/// Painel de votação mostrado quando a viagem ainda não tem destino definido.
/// Recebe a lista já combinada (destino + votos + hasVoted) via stream da página.
class TripVotingPanel extends StatelessWidget {
  final List<DestinationWithVotes> destinations;
  final bool isCreator;
  final void Function(int destinationId) onVotar;
  final VoidCallback onFecharVotacao;

  const TripVotingPanel({
    super.key,
    required this.destinations,
    required this.isCreator,
    required this.onVotar,
    required this.onFecharVotacao,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // TÍTULO
        const Text(
          'Votação de destino',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        const Text(
          'Vota no destino que preferes para esta viagem.',
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 12),

        // LISTA DE OPÇÕES
        if (destinations.isEmpty)
          const Text('Nenhuma opção de destino adicionada.')
        else
          ...destinations.map(
            (item) => _DestinationVoteCard(
              item: item,
              onVotar: () => onVotar(item.destination.id),
            ),
          ),

        // FECHAR VOTAÇÃO (apenas criador)
        if (isCreator && destinations.isNotEmpty) ...[
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onFecharVotacao,
              icon: const Icon(Icons.how_to_vote_outlined),
              label: const Text('Fechar votação'),
            ),
          ),
        ],
      ],
    );
  }
}

class _DestinationVoteCard extends StatelessWidget {
  final DestinationWithVotes item;
  final VoidCallback onVotar;

  const _DestinationVoteCard({required this.item, required this.onVotar});

  @override
  Widget build(BuildContext context) {
    final destination = item.destination;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.place_outlined),

        title: Text(destination.destinationName),

        subtitle: destination.description != null
            ? Text(destination.description!)
            : null,

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CONTAGEM DE VOTOS
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.voteCount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'votos',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // BOTÃO DE VOTO
            IconButton(
              icon: Icon(
                item.hasVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
              ),
              color: item.hasVoted
                  ? Theme.of(context).colorScheme.primary
                  : null,
              tooltip: item.hasVoted ? 'O teu voto' : 'Votar',
              onPressed: onVotar,
            ),
          ],
        ),
      ),
    );
  }
}
