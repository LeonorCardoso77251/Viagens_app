import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tasks.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.attachedDatabase);

  Future<Task> createTask({
    required int assignedTo,
    required int tripId,
    required String title,
    String? description,
    String status = 'pending',
  }) {
    return into(tasks).insertReturning(
      TasksCompanion.insert(
        assignedTo: assignedTo,
        tripId: tripId,
        title: title,
        description: Value(description),
        status: Value(status),
      ),
    );
  }

  Future<List<Task>> getTasksForTrip(int tripId) {
    return (select(tasks)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
  }

  Stream<List<Task>> watchTasksForTrip(int tripId) {
    return (select(tasks)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .watch();
  }

  Future<List<Task>> getTasksForUser(int userId) {
    return (select(tasks)..where((t) => t.assignedTo.equals(userId))).get();
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
