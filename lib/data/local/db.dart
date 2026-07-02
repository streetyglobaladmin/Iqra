import 'package:hive_flutter/hive_flutter.dart';
import 'hive_boxes.dart';

/// Thin wrapper around Hive box lifecycle. Called once from `main()`.
class Db {
  Db._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(HiveBoxes.users),
      Hive.openBox(HiveBoxes.session),
      Hive.openBox(HiveBoxes.featureFlags),
      Hive.openBox(HiveBoxes.academies),
      Hive.openBox(HiveBoxes.classes),
      Hive.openBox(HiveBoxes.students),
      Hive.openBox(HiveBoxes.pricingPlans),
      Hive.openBox(HiveBoxes.currencies),
      Hive.openBox(HiveBoxes.cmsPages),
      Hive.openBox(HiveBoxes.advertisements),
      Hive.openBox(HiveBoxes.referrals),
      Hive.openBox(HiveBoxes.auditLog),
      Hive.openBox(HiveBoxes.payments),
      Hive.openBox(HiveBoxes.prayerSettings),
      Hive.openBox(HiveBoxes.tasbihState),
      Hive.openBox(HiveBoxes.readerState),
      Hive.openBox(HiveBoxes.bookmarks),
      Hive.openBox(HiveBoxes.appSettings),
      Hive.openBox(HiveBoxes.teachers),
    ]);
  }

  static Box box(String name) => Hive.box(name);
}
