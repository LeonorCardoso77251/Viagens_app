import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import 'participant_card.dart';

class TripParticipantsList extends StatelessWidget {
  final List<User> participantes;
  final int createdByUserId;
  final bool editMode;

  // APENAS EM MODO DE EDIÇÃO
  final List<User> todosUsers;
  final void Function(User user)? onRemover;
  final void Function(User user)? onAdicionar;

  const TripParticipantsList({
    super.key,
    required this.participantes,
    required this.createdByUserId,
    this.editMode = false,
    this.todosUsers = const [],
    this.onRemover,
    this.onAdicionar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // TÍTULO
        const Text(
          'Participantes:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        // AUTOCOMPLETE (apenas em edição)
        if (editMode) ...[
          Autocomplete<User>(
            displayStringForOption: (User user) => user.name,

            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<User>.empty();
              }

              return todosUsers.where((user) {
                final jaParticipa = participantes.any((p) => p.id == user.id);

                return !jaParticipa &&
                    user.name.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
              });
            },

            onSelected: (User user) {
              onAdicionar?.call(user);
            },

            fieldViewBuilder:
                (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Adicionar participante',
                      suffixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  );
                },
          ),

          const SizedBox(height: 10),
        ],

        // LISTA
        if (participantes.isEmpty)
          const Text('Nenhum participante.')
        else
          ...participantes.map(
            (user) => ParticipantCard(
              user: user,
              // O criador não pode ser removido
              onRemover: editMode && user.id != createdByUserId
                  ? () => onRemover?.call(user)
                  : null,
            ),
          ),
      ],
    );
  }
}
