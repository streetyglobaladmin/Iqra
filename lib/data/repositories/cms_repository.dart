import 'package:hive/hive.dart';
import '../../models/cms_page.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

/// Real CMS storage for blog posts / static pages. Starts empty — the
/// admin authors real content through the Nuerizo Control Center CMS
/// editor; nothing here is placeholder marketing copy pretending to be
/// live data.
class CmsRepository {
  static final CmsRepository instance = CmsRepository._();
  CmsRepository._();

  Box get _box => Db.box(HiveBoxes.cmsPages);

  List<CmsPage> getAll() => _box.values
      .map((e) => CmsPage.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<CmsPage> getPublished() =>
      getAll().where((p) => p.status == CmsStatus.published).toList();

  List<CmsPage> getBlogPosts() =>
      getPublished().where((p) => p.isBlogPost).toList();

  CmsPage? getBySlug(String slug) {
    try {
      return getAll().firstWhere((p) => p.slug == slug);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert(CmsPage page) async {
    await _box.put(page.id, page.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
