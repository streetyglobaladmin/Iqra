import 'package:hive/hive.dart';
import '../../models/class_model.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

class ClassRepository {
  static final ClassRepository instance = ClassRepository._();
  ClassRepository._();

  Box get _box => Db.box(HiveBoxes.classes);

  List<ClassSession> getAll() => _box.values
      .map((e) => ClassSession.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ClassSession> getByTeacher(String teacherId) =>
      getAll().where((c) => c.teacherId == teacherId).toList();

  List<ClassSession> getByStudent(String studentId) =>
      getAll().where((c) => c.studentIds.contains(studentId)).toList();

  ClassSession? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return ClassSession.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> upsert(ClassSession session) async {
    await _box.put(session.id, session.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> enrollStudent(String classId, String studentId) async {
    final session = getById(classId);
    if (session == null) return;
    if (session.studentIds.contains(studentId)) return;
    final updated =
        session.copyWith(studentIds: [...session.studentIds, studentId]);
    await upsert(updated);
  }
}
