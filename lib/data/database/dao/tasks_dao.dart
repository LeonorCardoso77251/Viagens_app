import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tasks.dart';
import '../../../models/task.dart' as app_model;

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.attachedDatabase);

  app_model.Task _toAppTask(Task dbTask) {
    return app_model.Task(
      id: dbTask.id,
      tripId: dbTask.tripId,
      assignedToUserId: dbTask.assignedTo,
      descricao: dbTask.title,
      responsavel: dbTask.description ?? 'User ${dbTask.assignedTo}',
      concluida: dbTask.status == 'done',
      status: dbTask.status,
    );
  }

  Future<app_model.Task> createTask({
    required int assignedTo,
    required int tripId,
    required String title,
    String? description,
    String status = 'pending',
  }) async {
    final dbTask = await into(tasks).insertReturning(
      TasksCompanion.insert(
        assignedTo: assignedTo,
        tripId: tripId,
        title: title,
        description: Value(description),
        status: Value(status),
      ),
    );

    return _toAppTask(dbTask);
  }

  Future<List<app_model.Task>> getTasksForTrip(int tripId) async {
    final dbTasks =
        await (select(tasks)
              ..where((t) => t.tripId.equals(tripId))
              ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
            .get();

    return dbTasks.map(_toAppTask).toList();
  }

  Stream<List<app_model.Task>> watchTasksForTrip(int tripId) {
    return (select(tasks)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch()
        .map((dbTasks) => dbTasks.map(_toAppTask).toList());
  }

  Future<List<app_model.Task>> getTasksForUser(int userId) async {
    final dbTasks = await (select(
      tasks,
    )..where((t) => t.assignedTo.equals(userId))).get();

    return dbTasks.map(_toAppTask).toList();
  }

  Future<void> updateTaskStatus({
    required int taskId,
    required String status,
  }) async {
    await (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(status: Value(status)),
    );
  }

  Future<void> updateTask({
    required int taskId,
    String? title,
    String? description,
    String? status,
    int? assignedTo,
  }) async {
    await (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description: description != null
            ? Value(description)
            : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        assignedTo: assignedTo != null
            ? Value(assignedTo)
            : const Value.absent(),
      ),
    );
  }

  Future<void> deleteTask(int taskId) async {
    await (delete(tasks)..where((t) => t.id.equals(taskId))).go();
  }
}
