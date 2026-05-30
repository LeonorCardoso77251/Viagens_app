import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';

class EditTaskResult {
  final String title;
  final String? description;
  final String status;
  final int assignedTo;

  EditTaskResult({
    required this.title,
    required this.description,
    required this.status,
    required this.assignedTo,
  });
}

class EditTaskDialog extends StatefulWidget {
  final Task task;

  const EditTaskDialog({super.key, required this.task});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late String _status;
  late int _assignedTo;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);

    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );

    _status = widget.task.status;
    _assignedTo = widget.task.assignedTo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();

    if (title.isEmpty) return;

    Navigator.pop(
      context,
      EditTaskResult(
        title: title,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _status,
        assignedTo: _assignedTo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar tarefa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Descrição'),
          ),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Estado'),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pendente')),
              DropdownMenuItem(
                value: 'in_progress',
                child: Text('Em progresso'),
              ),
              DropdownMenuItem(value: 'done', child: Text('Concluída')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _status = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
