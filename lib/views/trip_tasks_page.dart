import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';
import '../data/database/dao/tasks_dao.dart';

import '../widgets/tasks/task_card.dart';
import '../widgets/tasks/task_edit_dialog.dart';

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
    // UTILIZADOR FIREBASE
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    // UTILIZADOR SQLITE
    final user = await appDatabase.usersDao.getUserByFirebaseUid(
      firebaseUser.uid,
    );

    if (user == null) {
      return;
    }

    setState(() {
      _currentUserId = user.id;

      _userLoaded = true;
    });
  }

  Future<void> abrirCriarTarefa() async {
    await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) => CreateTaskPage(
          tripId: widget.trip.id,

          currentUserId: _currentUserId,

          participantes: const [],
        ),
      ),
    );

    setState(() {});
  }

  Future<void> _abrirEditarTarefa(Task tarefa) async {
    final result = await showDialog<EditTaskResult>(
      context: context,
      builder: (context) {
        return EditTaskDialog(task: tarefa);
      },
    );

    if (result == null) return;

    await appDatabase.tasksDao.updateTask(
      taskId: tarefa.id,
      title: result.title,
      description: result.description,
      status: result.status,
      assignedTo: result.assignedTo,
    );
  }

  Future<void> _alternarConclusao(Task tarefa) async {
    final newStatus = tarefa.status == 'done' ? 'pending' : 'done';

    await appDatabase.tasksDao.updateTaskStatus(
      taskId: tarefa.id,

      status: newStatus,
    );
  }

  Future<void> _removerTarefa(int taskId) async {
    await appDatabase.tasksDao.deleteTask(taskId);
  }

  String statusLabel(String status) {
    switch (status) {
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
    // LOADING USER
    if (!_userLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text('Tarefas - ${widget.trip.name}')),

        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Tarefas - ${widget.trip.name}')),

      body: StreamBuilder<List<TaskWithAssignee>>(
        stream: appDatabase.tasksDao.watchTasksWithAssigneeForTrip(
          widget.trip.id,
        ),

        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERRO
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];

          // SEM TAREFAS
          if (tasks.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa adicionada.'));
          }

          // LISTA
          return ListView.builder(
            itemCount: tasks.length,

            itemBuilder: (context, index) {
              final item = tasks[index];
              final tarefa = item.task;
              final assignee = item.assignee;

              final isDone = tarefa.status == 'done';

              return TaskCard(
                task: tarefa,
                assigneeName: assignee.name,
                onToggleDone: () {
                  _alternarConclusao(tarefa);
                },
                onEdit: () {
                  _abrirEditarTarefa(tarefa);
                },
                onDelete: () {
                  _removerTarefa(tarefa.id);
                },
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
