import 'package:hive/hive.dart';
import '../../models/teacher_profile.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

/// Teachers are stored in their own Hive box. Starts empty — the Scholar
/// directory shows "No scholars yet" until a real teacher registers
/// through the Studio onboarding flow.
class TeacherRepository {
  static final TeacherRepository instance = TeacherRepository._();
  TeacherRepository._();

  Box get _box => Db.box(HiveBoxes.teachers);

  List<TeacherProfile> getAll() => _box.values
      .map((e) => TeacherProfile.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  TeacherProfile? getByUserId(String userId) {
    try {
      return getAll().firstWhere((t) => t.userId == userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(TeacherProfile profile) async {
    await _box.put(profile.id, profile.toMap());
  }
}
