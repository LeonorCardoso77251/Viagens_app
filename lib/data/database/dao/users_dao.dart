import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tasks.dart';
import '../tables/trip_members.dart';
import '../tables/users.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users, TripMembers, Tasks])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.attachedDatabase);

  // CRIAR UTILIZADOR
  Future<User> createUser({
    required String firebaseUid,
    required String name,
    required String email,
    String? photoUrl,
  }) {
    return into(users).insertReturning(
      UsersCompanion.insert(
        firebaseUid: firebaseUid,
        name: name,
        email: email,
        photoUrl: Value(photoUrl),
      ),
    );
  }

  // BUSCAR POR ID LOCAL
  Future<User?> getUserById(int userId) {
    return (select(users)..where((u) => u.id.equals(userId))).getSingleOrNull();
  }

  // BUSCAR POR EMAIL
  Future<User?> getUserByEmail(String email) {
    return (select(
      users,
    )..where((u) => u.email.equals(email))).getSingleOrNull();
  }

  // BUSCAR POR FIREBASE UID
  Future<User?> getUserByFirebaseUid(String firebaseUid) {
    return (select(
      users,
    )..where((u) => u.firebaseUid.equals(firebaseUid))).getSingleOrNull();
  }

  // LISTAR TODOS
  Future<List<User>> getAllUsers() {
    return select(users).get();
  }

  // GUARDAR UTILIZADOR FIREBASE
  Future<void> saveFirebaseUser({
    required String firebaseUid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final existing = await getUserByFirebaseUid(firebaseUid);

    if (existing != null) return;

    await createUser(
      firebaseUid: firebaseUid,
      name: name,
      email: email,
      photoUrl: photoUrl,
    );
  }

  // ATUALIZAR PERFIL
  Future<void> updateProfile({
    required int userId,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    await (update(users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        name: Value(name),
        email: Value(email),
        photoUrl: Value(photoUrl),
      ),
    );
  }

  // CONTAGEM DE VIAGENS DO UTILIZADOR (todas)
  Future<int> getTripCountForUser(int userId) async {
    final count = tripMembers.id.count();

    final query = selectOnly(tripMembers)
      ..addColumns([count])
      ..where(tripMembers.userId.equals(userId));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // CONTAGEM DE TAREFAS NÃO CONCLUÍDAS DO UTILIZADOR
  Future<int> getActiveTaskCountForUser(int userId) async {
    final count = tasks.id.count();

    final query = selectOnly(tasks)
      ..addColumns([count])
      ..where(
        tasks.assignedTo.equals(userId) & tasks.status.equals('done').not(),
      );

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
