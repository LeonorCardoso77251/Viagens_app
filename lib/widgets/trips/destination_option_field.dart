import 'package:flutter/material.dart';

/// Uma linha da lista de opções de destino na criação de viagem (modo votação).
class DestinationOptionField extends StatelessWidget {
  final String name;
  final VoidCallback onRemover;

  const DestinationOptionField({
    super.key,
    required this.name,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.place_outlined),
        title: Text(name),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onRemover,
        ),
      ),
    );
  }
}
