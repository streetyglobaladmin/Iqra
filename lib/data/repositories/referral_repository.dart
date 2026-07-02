import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../models/referral.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

class ReferralRepository {
  static final ReferralRepository instance = ReferralRepository._();
  ReferralRepository._();

  final _uuid = const Uuid();

  Box get _box => Db.box(HiveBoxes.referrals);

  List<Referral> getAll() => _box.values
      .map((e) => Referral.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Referral> getByReferrer(String userId) =>
      getAll().where((r) => r.referrerUserId == userId).toList();

  Future<Referral> recordSignupWithCode({
    required String code,
    required String inviteeUserId,
    required String referrerUserId,
  }) async {
    final referral = Referral(
      id: _uuid.v4(),
      referrerUserId: referrerUserId,
      code: code,
      inviteeUserId: inviteeUserId,
      status: ReferralStatus.pending,
      createdAt: DateTime.now(),
    );
    await _box.put(referral.id, referral.toMap());
    return referral;
  }

  Future<void> markRewarded(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final r = Referral.fromMap(Map<String, dynamic>.from(raw as Map));
    await _box.put(id, r.copyWith(status: ReferralStatus.rewarded).toMap());
  }
}
