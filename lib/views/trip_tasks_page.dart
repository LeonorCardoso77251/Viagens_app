import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';

import 'create_task_page.dart';

class TripTasksPage extends StatefulWidget {
  final Trip trip;

  const TripTasksPage({
    super.key,
    required this.trip,
  });

  @override
  State<TripTasksPage> createState() =>
      _TripTasksPageState();
}

class _TripTasksPageState
    extends State<TripTasksPage> {

  late int _currentUserId;

  bool _userLoaded = false;

  @override
  void initState() {
    super.initState();

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {

    // UTILIZADOR FIREBASE
    final firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    // UTILIZADOR SQLITE
    final user =
    await appDatabase.usersDao
        .getUserByFirebaseUid(
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
        builder: (context) =>
            CreateTaskPage(

              tripId:
              widget.trip.id,

              currentUserId:
              _currentUserId,

              participantes:
              const [],
            ),
      ),
    );

    setState(() {});
  }

  Future<void> _alternarConclusao(
      Task tarefa,
      ) async {

    final newStatus =
    tarefa.status == 'done'
        ? 'pending'
        : 'done';

    await appDatabase.tasksDao
        .updateTaskStatus(

      taskId: tarefa.id,

      status: newStatus,
    );
  }

  Future<void> _removerTarefa(
      int taskId,
      ) async {

    await appDatabase.tasksDao
        .deleteTask(taskId);
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

        appBar: AppBar(
          title: Text(
            'Tarefas - ${widget.trip.name}',
          ),
        ),

        body: const Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: Text(
          'Tarefas - ${widget.trip.name}',
        ),
      ),

      body: StreamBuilder<List<Task>>(

        stream: appDatabase
            .tasksDao
            .watchTasksForTrip(
          widget.trip.id,
        ),

        builder: (
            context,
            snapshot,
            ) {

          // LOADING
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          // ERRO
          if (snapshot.hasError) {

            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
              ),
            );
          }

          final tasks =
              snapshot.data ?? [];

          // SEM TAREFAS
          if (tasks.isEmpty) {

            return const Center(
              child: Text(
                'Nenhuma tarefa adicionada.',
              ),
            );
          }

          // LISTA
          return ListView.builder(

            itemCount: tasks.length,

            itemBuilder: (
                context,
                index,
                ) {

              final tarefa =
              tasks[index];

              final isDone =
                  tarefa.status == 'done';

              return Card(

                margin:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                child: ListTile(

                  leading: Checkbox(

                    value: isDone,

                    onChanged: (_) {
                      _alternarConclusao(
                        tarefa,
                      );
                    },
                  ),

                  title: Text(

                    tarefa.title,

                    style: TextStyle(
                      decoration: isDone
                          ? TextDecoration
                          .lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  subtitle: Text(

                    [
                      if (tarefa.description !=
                          null &&
                          tarefa.description!
                              .isNotEmpty)
                        tarefa.description!,

                      'Estado: ${statusLabel(tarefa.status)}',

                      'Responsável: ${tarefa.assignedTo}',
                    ].join('\n'),
                  ),

                  trailing: IconButton(

                    icon: const Icon(
                      Icons.delete,
                    ),

                    onPressed: () {
                      _removerTarefa(
                        tarefa.id,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton:
      FloatingActionButton(

        onPressed:
        abrirCriarTarefa,

        child:
        const Icon(Icons.add),
      ),
    );
  }
}