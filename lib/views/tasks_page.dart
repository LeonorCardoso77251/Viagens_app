import 'package:flutter/material.dart';
import '../data/database/database_provider.dart';
import '../models/task.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: appDatabase.usersDao.getUserByEmail('demo@unitrip.local'),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userId = userSnapshot.data!.id;

          return FutureBuilder(
            future: appDatabase.tasksDao.getTasksForUser(userId),
            builder: (context, tasksSnapshot) {
              if (!tasksSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = tasksSnapshot.data!;

              final uncompletedTasks =
              tasks.where((task) => !task.isDone).toList();

              if (uncompletedTasks.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma tarefa ainda',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                itemCount: uncompletedTasks.length,
                itemBuilder: (context, index) {
                  final task = uncompletedTasks[index];

                  return ListTile(
                    leading: const Icon(Icons.check_box_outline_blank),
                    title: Text(task.descricao),
                    subtitle: Text('Responsável: ${task.responsavel}'),
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