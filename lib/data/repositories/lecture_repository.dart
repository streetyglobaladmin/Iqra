import 'package:hive/hive.dart';
import '../../models/lecture.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

/// Public Lectures storage — same lightweight CMS pattern as
/// [CmsRepository]. Starts empty; the admin (Nuerizo Control Center)
/// authors real lectures, nothing here is placeholder content.
class LectureRepository {
  static final LectureRepository instance = LectureRepository._();
  LectureRepository._();

  Box get _box => Db.box(HiveBoxes.lectures);

  List<Lecture> getAll() => _box.values
      .map((e) => Lecture.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  /// Lectures visible on the guest-accessible Public Lectures screen:
  /// published and not marked premium/private.
  List<Lecture> getPublicPublished() => getAll()
      .where((l) => l.isPublished && !l.isPremium)
      .toList();

  /// Published lectures marked premium — still "published" so admin sees
  /// them in listings, but require login to open per the access rule.
  List<Lecture> getPremiumPublished() =>
      getAll().where((l) => l.isPublished && l.isPremium).toList();

  Lecture? getById(String id) {
    try {
      return getAll().firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> categories() =>
      getAll().map((l) => l.category).toSet().toList()..sort();

  Future<void> upsert(Lecture lecture) async {
    await _box.put(lecture.id, lecture.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
