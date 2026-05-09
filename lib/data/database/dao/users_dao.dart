import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/users.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase>
    with _$UsersDaoMixin {

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
    return (select(users)
      ..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
  }

  // BUSCAR POR EMAIL
  Future<User?> getUserByEmail(String email) {
    return (select(users)
      ..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  // BUSCAR POR FIREBASE UID
  Future<User?> getUserByFirebaseUid(String firebaseUid) {
    return (select(users)
      ..where((u) => u.firebaseUid.equals(firebaseUid)))
        .getSingleOrNull();
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

    final existing =
    await getUserByFirebaseUid(firebaseUid);

    if (existing != null) return;

    await createUser(
      firebaseUid: firebaseUid,
      name: name,
      email: email,
      photoUrl: photoUrl,
    );
  }
}
