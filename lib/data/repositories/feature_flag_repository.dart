import 'package:hive/hive.dart';
import '../../models/feature_flag.dart';
import '../../models/release_state.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

/// The feature-flag repository — "the platform's nervous system". Every
/// major module/feature has a row here. The admin panel edits these
/// records directly; no code deploy required to change what users see.
///
/// Seeded once with all ten IQRA modules + key sub-features, each defaulted
/// to the release state described in the design blueprint (§01 Architecture
/// / NEO_PROJECT_MEMORY §1). This is real, functioning gating logic — every
/// screen in the app checks these flags before rendering.
class FeatureFlagRepository {
  static final FeatureFlagRepository instance = FeatureFlagRepository._();
  FeatureFlagRepository._();

  Box get _box => Db.box(HiveBoxes.featureFlags);

  Future<void> seedIfEmpty() async {
    if (_box.isNotEmpty) return;
    final now = DateTime.now();
    final defaults = <FeatureFlag>[
      FeatureFlag(
        key: 'daily.app',
        module: 'IQRA Daily',
        name: 'IQRA Daily (consumer companion)',
        description:
            'Prayer times, Qibla, Qur\'ān, dhikr, duas, calendar, learn, scholars.',
        releaseState: ReleaseState.public,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'studio.app',
        module: 'IQRA Studio',
        name: 'Teacher / Scholar Studio',
        description: 'Workspace for independent Quran teachers: classes, students, live sessions, earnings.',
        releaseState: ReleaseState.public,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'student.portal',
        module: 'Student',
        name: 'Student experience',
        description: 'Enrolled classes, memorization tracker, homework, live class join.',
        releaseState: ReleaseState.public,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'parent.portal',
        module: 'Parent Portal',
        name: 'Parent dashboard',
        description: "Child progress, attendance, homework, invoices.",
        releaseState: ReleaseState.beta,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'website.public',
        module: 'Public Website',
        name: 'Public marketing website',
        description: 'nuerizo.cloud + IQRA marketing site.',
        releaseState: ReleaseState.public,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'hub.app',
        module: 'IQRA Hub',
        name: 'IQRA Hub (ecosystem launcher)',
        description: 'Cross-surface launcher showing all modules the signed-in user can access.',
        releaseState: ReleaseState.public,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'admin.control_center',
        module: 'Nuerizo Control Center',
        name: 'Admin dashboard',
        description: 'Internal operator console.',
        releaseState: ReleaseState.internal,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'kids.app',
        module: 'IQRA Kids',
        name: 'IQRA Kids (gamified learning)',
        description: 'Gamified self-paced learning for younger students.',
        releaseState: ReleaseState.hidden,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'academy.multiTeacher',
        module: 'IQRA Academy',
        name: 'Multi-teacher Academy / white-label',
        description: 'Enterprise multi-teacher workspace.',
        releaseState: ReleaseState.hidden,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'marketplace.discovery',
        module: 'Marketplace',
        name: 'Teacher discovery marketplace',
        description: 'Parents discover and book independent teachers.',
        releaseState: ReleaseState.hidden,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'community.qa',
        module: 'Community',
        name: 'Scholarly Q&A + study circles',
        description: 'Moderated community Q&A.',
        releaseState: ReleaseState.hidden,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'studio.ai_tutor',
        module: 'IQRA Studio',
        name: 'AI tutor inside lessons',
        description: "Lets teachers ask an LLM about a student's progress.",
        releaseState: ReleaseState.beta,
        rolloutPct: 25,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'payments.stripe',
        module: 'Billing',
        name: 'Stripe payments',
        description: 'Global card payments via Stripe. Simulated until API keys are added.',
        releaseState: ReleaseState.internal,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'payments.razorpay',
        module: 'Billing',
        name: 'Razorpay payments',
        description: 'India UPI/card payments via Razorpay. Simulated until API keys are added.',
        releaseState: ReleaseState.internal,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'payments.manual',
        module: 'Billing',
        name: 'Manual / local payments',
        description: 'Bank transfer / cash reference tracked manually by the teacher.',
        releaseState: ReleaseState.public,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'notifications.push',
        module: 'Notifications',
        name: 'Push notifications',
        description: 'Firebase Cloud Messaging push. Architecture only until credentials are added.',
        releaseState: ReleaseState.internal,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'liveclass.livekit',
        module: 'Live Classes',
        name: 'LiveKit native video',
        description: 'In-app video classes via LiveKit. Zoom/Meet links used until this ships.',
        releaseState: ReleaseState.hidden,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'donations.sadaqah',
        module: 'Billing',
        name: 'Sadaqah donation flow',
        description: 'First-class donation primitive at emotionally-resonant moments.',
        releaseState: ReleaseState.beta,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'referrals.program',
        module: 'Growth',
        name: 'Referral program',
        description: 'Invite-a-friend rewards.',
        releaseState: ReleaseState.public,
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'ads.enabled',
        module: 'Growth',
        name: 'In-app advertisements',
        description: 'Sponsored placements on Home / Learn / Website.',
        releaseState: ReleaseState.hidden,
        updatedAt: now,
      ),
    ];
    for (final f in defaults) {
      await _box.put(f.key, f.toMap());
    }
  }

  List<FeatureFlag> getAll() {
    return _box.values
        .map((e) => FeatureFlag.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.module.compareTo(b.module));
  }

  FeatureFlag? getByKey(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    return FeatureFlag.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  /// Whether a feature should be visible/usable for the given [isStaff]
  /// (admin/teacher-internal) and [isPremiumUser] context. This is the
  /// real evaluation logic the whole app runs through — no UI ever
  /// hardcodes visibility.
  bool isEnabled(String key, {bool isStaff = false, bool isPremiumUser = false}) {
    final flag = getByKey(key);
    if (flag == null) return false;
    if (flag.killswitch) return false;
    switch (flag.releaseState) {
      case ReleaseState.hidden:
        return false;
      case ReleaseState.internal:
        return isStaff;
      case ReleaseState.beta:
        return isStaff || true; // rollout% handled by caller/UI badge
      case ReleaseState.public:
        return true;
      case ReleaseState.premium:
        return isStaff || isPremiumUser;
      case ReleaseState.enterprise:
        return isStaff;
    }
  }

  Future<void> updateReleaseState(String key, ReleaseState state) async {
    final flag = getByKey(key);
    if (flag == null) return;
    await _box.put(key, flag.copyWith(releaseState: state).toMap());
  }

  Future<void> updateKillswitch(String key, bool killed) async {
    final flag = getByKey(key);
    if (flag == null) return;
    await _box.put(key, flag.copyWith(killswitch: killed).toMap());
  }

  Future<void> updateRollout(String key, int pct) async {
    final flag = getByKey(key);
    if (flag == null) return;
    await _box.put(key, flag.copyWith(rolloutPct: pct).toMap());
  }
}
