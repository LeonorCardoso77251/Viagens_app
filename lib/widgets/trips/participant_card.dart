import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';

class ParticipantCard extends StatelessWidget {
  final User user;

  // Se for null, o botão de remover não é mostrado
  final VoidCallback? onRemover;

  const ParticipantCard({super.key, required this.user, this.onRemover});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.name.substring(0, 1).toUpperCase()),
        ),

        title: Text(user.name),

        subtitle: Text(user.email),

        trailing: onRemover != null
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onRemover,
              )
            : null,
      ),
    );
  }
}
