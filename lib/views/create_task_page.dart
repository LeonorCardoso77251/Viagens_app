import 'package:flutter/material.dart';
import '../models/task.dart';
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
  final descricaoController = TextEditingController();
  String? responsavelSelecionado;

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> guardarTarefa() async {
    final descricao = descricaoController.text.trim();
    final responsavel = responsavelSelecionado;

    if (descricao.isEmpty || responsavel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche todos os campos.')),
      );
      return;
    }

    try {
      // Save task to database
      final novaTask = await appDatabase.tasksDao.createTask(
        assignedTo: widget.currentUserId,
        tripId: widget.tripId,
        title: descricao,
        description: responsavel,
        status: 'pending',
      );

      // Create app-level task object
      final tarefa = Task(
        id: novaTask.id,
        tripId: novaTask.tripId,
        assignedToUserId: novaTask.assignedTo,
        descricao: descricao,
        responsavel: responsavel,
        status: 'pending',
      );

      Navigator.pop(context, tarefa);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao guardar tarefa: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição da tarefa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: responsavelSelecionado,
              items: widget.participantes.map((participante) {
                return DropdownMenuItem<String>(
                  value: participante,
                  child: Text(participante),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  responsavelSelecionado = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Responsável',
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
