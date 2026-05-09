import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

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

    return Scaffold(

      body: FutureBuilder(

        future: () async {

          // UTILIZADOR FIREBASE
          final firebaseUser =
              FirebaseAuth
                  .instance
                  .currentUser;

          if (firebaseUser == null) {
            return null;
          }

          // UTILIZADOR SQLITE
          return await appDatabase
              .usersDao
              .getUserByFirebaseUid(
            firebaseUser.uid,
          );
        }(),

        builder: (
            context,
            userSnapshot,
            ) {

          // LOADING
          if (userSnapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          // UTILIZADOR NÃO ENCONTRADO
          if (!userSnapshot.hasData ||
              userSnapshot.data == null) {

            return const Center(
              child: Text(
                'Erro ao carregar utilizador.',
              ),
            );
          }

          final user =
          userSnapshot.data!;

          return FutureBuilder<List<Task>>(

            future: appDatabase
                .tasksDao
                .getTasksForUser(
              user.id,
            ),

            builder: (
                context,
                tasksSnapshot,
                ) {

              // LOADING
              if (tasksSnapshot
                  .connectionState ==
                  ConnectionState.waiting) {

                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              }

              // ERRO
              if (tasksSnapshot.hasError) {

                return Center(
                  child: Text(
                    'Erro: ${tasksSnapshot.error}',
                  ),
                );
              }

              final tasks =
                  tasksSnapshot.data ?? [];

              final uncompletedTasks =
              tasks.where(
                    (task) =>
                task.status != 'done',
              ).toList();

              // SEM TAREFAS
              if (uncompletedTasks.isEmpty) {

                return const Center(
                  child: Text(
                    'Nenhuma tarefa ainda',

                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              }

              // LISTA TAREFAS
              return ListView.builder(

                itemCount:
                uncompletedTasks.length,

                itemBuilder: (
                    context,
                    index,
                    ) {

                  final task =
                  uncompletedTasks[index];

                  return ListTile(

                    leading: const Icon(
                      Icons
                          .check_box_outline_blank,
                    ),

                    title:
                    Text(task.title),

                    subtitle: Text(

                      [
                        if (task.description !=
                            null &&
                            task.description!
                                .isNotEmpty)
                          task.description!,

                        'Estado: ${statusLabel(task.status)}',
                      ].join('\n'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}