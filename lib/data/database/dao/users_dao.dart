import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/users.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.attachedDatabase);

  Future<User> createUser({
    required String name,
    required String email,
    required String passwordHash,
  }) {
    return into(users).insertReturning(
      UsersCompanion.insert(
        name: name,
        email: email,
        passwordHash: passwordHash,
      ),
    );
  }

  Future<User?> getUserById(int userId) {
    return (select(users)..where((u) => u.id.equals(userId))).getSingleOrNull();
  }

  Future<User?> getUserByEmail(String email) {
    return (select(
      users,
    )..where((u) => u.email.equals(email))).getSingleOrNull();
  }

  Future<void> ensureDemoUser() async {
    final existing = await getUserByEmail('demo@unitrip.local');

    if (existing != null) return;

    await createUser(
      name: 'Demo User',
      email: 'demo@unitrip.local',
      passwordHash: 'demo_hash',
    );
  }
}
