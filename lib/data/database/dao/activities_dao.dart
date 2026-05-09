import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/activities.dart';

part 'activities_dao.g.dart';

@DriftAccessor(tables: [Activities])
class ActivitiesDao extends DatabaseAccessor<AppDatabase>
    with _$ActivitiesDaoMixin {
  ActivitiesDao(super.db);

  Stream<List<Activity>> watchActivitiesForTrip(int tripId) {
    return (select(activities)
      ..where((a) => a.tripId.equals(tripId))
      ..orderBy([
            (a) => OrderingTerm.asc(a.dataHora),
      ]))
        .watch();
  }

  Future<List<Activity>> getActivitiesForTrip(int tripId) {
    return (select(activities)
      ..where((a) => a.tripId.equals(tripId))
      ..orderBy([
            (a) => OrderingTerm.asc(a.dataHora),
      ]))
        .get();
  }

  Future<int> insertActivity(ActivitiesCompanion activity) {
    return into(activities).insert(activity);
  }

  Future<bool> updateActivity(Activity activity) {
    return update(activities).replace(activity);
  }

  Future<int> deleteActivity(int id) {
    return (delete(activities)..where((a) => a.id.equals(id))).go();
  }
}