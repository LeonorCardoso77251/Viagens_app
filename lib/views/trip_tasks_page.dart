import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/trip.dart';
import '../data/database/database_provider.dart';
import 'create_task_page.dart';

class TripTasksPage extends StatefulWidget {
  final Trip trip;

  const TripTasksPage({super.key, required this.trip});

  @override
  State<TripTasksPage> createState() => _TripTasksPageState();
}

class _TripTasksPageState extends State<TripTasksPage> {
  late int _currentUserId;
  bool _userLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await appDatabase.usersDao.getUserByEmail(
      'demo@unitrip.local',
    );
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
        _userLoaded = true;
      });
    }
  }

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
          tripId: widget.trip.id,
          participantes: widget.trip.participantes,
          currentUserId: _currentUserId,
        ),
      ),
    );

    if (novaTarefa != null) {
      // Task was saved to database, stream will update automatically
    }
  }

  Future<void> _alternarConclusao(Task tarefa) async {
    final newStatus = tarefa.isDone ? 'pending' : 'done';
    await appDatabase.tasksDao.updateTaskStatus(
      taskId: tarefa.id,
      status: newStatus,
    );
  }

  Future<void> _removerTarefa(int taskId) async {
    await appDatabase.tasksDao.deleteTask(taskId);
  }

  @override
  Widget build(BuildContext context) {
    if (!_userLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text('Tarefas - ${widget.trip.nome}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Tarefas - ${widget.trip.nome}')),
      body: StreamBuilder<List<dynamic>>(
        stream: appDatabase.tasksDao.watchTasksForTrip(widget.trip.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa adicionada.'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final dbTask = tasks[index];
              final isDone = dbTask.status == 'done';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: isDone,
                    onChanged: (_) {
                      _alternarConclusao(
                        Task(
                          id: dbTask.id,
                          tripId: dbTask.tripId,
                          assignedToUserId: dbTask.assignedTo,
                          descricao: dbTask.title,
                          responsavel: dbTask.title,
                          status: dbTask.status,
                        ),
                      );
                    },
                  ),
                  title: Text(
                    dbTask.title,
                    style: TextStyle(
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: dbTask.description != null
                      ? Text(dbTask.description)
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _removerTarefa(dbTask.id);
                    },
                  ),
                ),
              );
            },
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
