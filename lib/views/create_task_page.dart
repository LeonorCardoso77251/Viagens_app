import 'package:flutter/material.dart';
import '../data/database/database_provider.dart';

class CreateTaskPage extends StatefulWidget {
  final int tripId;
  final int currentUserId;
  final List<String> participantes;

  const CreateTaskPage({
    super.key,
    required this.tripId,
    required this.currentUserId,
    required this.participantes,
  });

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String statusSelecionado = 'pending';

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> guardarTarefa() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche o título da tarefa.')),
      );
      return;
    }

    try {
      final tarefa = await appDatabase.tasksDao.createTask(
        assignedTo: widget.currentUserId, // temporary DemoUser/current user
        tripId: widget.tripId,
        title: title,
        description: description.isEmpty ? null : description,
        status: statusSelecionado,
      );

      Navigator.pop(context, tarefa);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao guardar tarefa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título da tarefa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição opcional',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: statusSelecionado,
              items: const [
                DropdownMenuItem(
                  value: 'pending',
                  child: Text('Pendente'),
                ),
                DropdownMenuItem(
                  value: 'in_progress',
                  child: Text('Em progresso'),
                ),
                DropdownMenuItem(
                  value: 'done',
                  child: Text('Concluída'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  statusSelecionado = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: guardarTarefa,
                      child: const Text('Guardar'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}