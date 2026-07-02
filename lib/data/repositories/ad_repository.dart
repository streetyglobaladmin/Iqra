import 'package:hive/hive.dart';
import '../../models/advertisement.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

class AdRepository {
  static final AdRepository instance = AdRepository._();
  AdRepository._();

  Box get _box => Db.box(HiveBoxes.advertisements);

  List<Advertisement> getAll() => _box.values
      .map((e) => Advertisement.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.startsAt.compareTo(a.startsAt));

  List<Advertisement> getActiveFor(AdPlacement placement) => getAll()
      .where((a) => a.active && a.placement == placement)
      .toList();

  Future<void> upsert(Advertisement ad) async {
    await _box.put(ad.id, ad.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> recordImpression(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final ad = Advertisement.fromMap(Map<String, dynamic>.from(raw as Map));
    await upsert(ad.copyWith(impressions: ad.impressions + 1));
  }

  Future<void> recordClick(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final ad = Advertisement.fromMap(Map<String, dynamic>.from(raw as Map));
    await upsert(ad.copyWith(clicks: ad.clicks + 1));
  }
}
