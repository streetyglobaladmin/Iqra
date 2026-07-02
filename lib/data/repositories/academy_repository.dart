import 'package:hive/hive.dart';
import '../../models/academy.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

/// Real local persistence for academies. Starts empty — "0 academies"
/// until an admin or teacher actually creates one.
class AcademyRepository {
  static final AcademyRepository instance = AcademyRepository._();
  AcademyRepository._();

  Box get _box => Db.box(HiveBoxes.academies);

  List<Academy> getAll() => _box.values
      .map((e) => Academy.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> upsert(Academy academy) async {
    await _box.put(academy.id, academy.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
