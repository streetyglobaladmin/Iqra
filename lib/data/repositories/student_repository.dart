import 'package:hive/hive.dart';
import '../../models/student_profile.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

class StudentRepository {
  static final StudentRepository instance = StudentRepository._();
  StudentRepository._();

  Box get _box => Db.box(HiveBoxes.students);

  List<StudentProfile> getAll() => _box.values
      .map((e) => StudentProfile.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();

  StudentProfile? getByUserId(String userId) {
    try {
      return getAll().firstWhere((s) => s.userId == userId);
    } catch (_) {
      return null;
    }
  }

  List<StudentProfile> getByParentId(String parentId) =>
      getAll().where((s) => s.parentId == parentId).toList();

  Future<void> upsert(StudentProfile profile) async {
    await _box.put(profile.id, profile.toMap());
  }
}
