import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String assigneeName;

  final VoidCallback onToggleDone;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.assigneeName,
    required this.onToggleDone,
    required this.onDelete,
    required this.onEdit,
  });

  bool get isDone => task.status == 'done';

  String get statusLabel {
    switch (task.status) {
      case 'in_progress':
        return 'Em progresso';
      case 'done':
        return 'Concluída';
      case 'pending':
      default:
        return 'Pendente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: Checkbox(value: isDone, onChanged: (_) => onToggleDone()),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          [
            if (task.description != null && task.description!.isNotEmpty)
              task.description!,
            'Responsável: ${assigneeName}',
          ].join('\n'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
