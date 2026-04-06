import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/trip.dart';
import 'create_task_page.dart';

class TripTasksPage extends StatefulWidget {
  final Trip trip;

  const TripTasksPage({super.key, required this.trip});

  @override
  State<TripTasksPage> createState() => _TripTasksPageState();
}

class _TripTasksPageState extends State<TripTasksPage> {
  final List<Task> tarefas = [];

  Future<void> abrirCriarTarefa() async {
    if (widget.trip.participantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adiciona participantes antes de criar tarefas.'),
        ),
      );
      return;
    }

    final Task? novaTarefa = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskPage(
          participantes: widget.trip.participantes,
        ),
      ),
    );

    if (novaTarefa != null) {
      setState(() {
        tarefas.add(novaTarefa);
      });
    }
  }

  void alternarConclusao(int index) {
    setState(() {
      tarefas[index].concluida = !tarefas[index].concluida;
    });
  }

  void removerTarefa(int index) {
    setState(() {
      tarefas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas - ${widget.trip.nome}'),
      ),
      body: tarefas.isEmpty
          ? const Center(
              child: Text('Nenhuma tarefa adicionada.'),
            )
          : ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = tarefas[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: tarefa.concluida,
                      onChanged: (_) {
                        alternarConclusao(index);
                      },
                    ),
                    title: Text(
                      tarefa.descricao,
                      style: TextStyle(
                        decoration: tarefa.concluida
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text('Responsável: ${tarefa.responsavel}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        removerTarefa(index);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCriarTarefa,
        child: const Icon(Icons.add),
      ),
    );
  }
}