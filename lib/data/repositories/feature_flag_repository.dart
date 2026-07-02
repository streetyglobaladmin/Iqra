import 'package:hive/hive.dart';
import '../../models/feature_flag.dart';
import '../../models/release_state.dart';
import '../../models/feature_access_level.dart';
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
        allowedAccessLevels: {FeatureAccessLevel.publicGuest},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'studio.app',
        module: 'IQRA Studio',
        name: 'Teacher / Scholar Studio',
        description: 'Workspace for independent Quran teachers: classes, students, live sessions, earnings.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.teacher, FeatureAccessLevel.academyAdmin, FeatureAccessLevel.superAdmin},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'student.portal',
        module: 'Student',
        name: 'Student experience',
        description: 'Enrolled classes, memorization tracker, homework, live class join.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.student, FeatureAccessLevel.superAdmin},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'parent.portal',
        module: 'Parent Portal',
        name: 'Parent dashboard',
        description: "Child progress, attendance, homework, invoices.",
        releaseState: ReleaseState.beta,
        allowedAccessLevels: {FeatureAccessLevel.parent, FeatureAccessLevel.superAdmin},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'website.public',
        module: 'Public Website',
        name: 'Public marketing website',
        description: 'nuerizo.cloud + IQRA marketing site.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.publicGuest},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'hub.app',
        module: 'IQRA Hub',
        name: 'IQRA Hub (ecosystem launcher)',
        description: 'Cross-surface launcher — guests see Daily; signed-in users additionally see the modules their roles unlock.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.publicGuest},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'admin.control_center',
        module: 'Nuerizo Control Center',
        name: 'Admin dashboard',
        description: 'Internal operator console.',
        releaseState: ReleaseState.internal,
        allowedAccessLevels: {FeatureAccessLevel.academyAdmin, FeatureAccessLevel.superAdmin},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'kids.app',
        module: 'IQRA Kids',
        name: 'IQRA Kids (gamified learning)',
        description: 'Gamified self-paced learning for younger students.',
        releaseState: ReleaseState.hidden,
        allowedAccessLevels: {FeatureAccessLevel.publicGuest},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'academy.multiTeacher',
        module: 'IQRA Academy',
        name: 'Multi-teacher Academy / white-label',
        description: 'Enterprise multi-teacher workspace.',
        releaseState: ReleaseState.hidden,
        allowedAccessLevels: {FeatureAccessLevel.academyAdmin, FeatureAccessLevel.enterprise},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'marketplace.discovery',
        module: 'Marketplace',
        name: 'Teacher discovery marketplace',
        description: 'Parents discover and book independent teachers.',
        releaseState: ReleaseState.hidden,
        allowedAccessLevels: {FeatureAccessLevel.publicGuest},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'community.qa',
        module: 'Community',
        name: 'Scholarly Q&A + study circles',
        description: 'Moderated community Q&A.',
        releaseState: ReleaseState.hidden,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'studio.ai_tutor',
        module: 'IQRA Studio',
        name: 'AI tutor inside lessons',
        description: "Lets teachers ask an LLM about a student's progress.",
        releaseState: ReleaseState.beta,
        rolloutPct: 25,
        allowedAccessLevels: {FeatureAccessLevel.teacher},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'payments.stripe',
        module: 'Billing',
        name: 'Stripe payments',
        description: 'Global card payments via Stripe. Simulated until API keys are added.',
        releaseState: ReleaseState.internal,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'payments.razorpay',
        module: 'Billing',
        name: 'Razorpay payments',
        description: 'India UPI/card payments via Razorpay. Simulated until API keys are added.',
        releaseState: ReleaseState.internal,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'payments.manual',
        module: 'Billing',
        name: 'Manual / local payments',
        description: 'Bank transfer / cash reference tracked manually by the teacher.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'notifications.push',
        module: 'Notifications',
        name: 'Push notifications',
        description: 'Firebase Cloud Messaging push. Architecture only until credentials are added.',
        releaseState: ReleaseState.internal,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'liveclass.livekit',
        module: 'Live Classes',
        name: 'LiveKit native video',
        description: 'In-app video classes via LiveKit. Zoom/Meet links used until this ships.',
        releaseState: ReleaseState.hidden,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'donations.sadaqah',
        module: 'Billing',
        name: 'Sadaqah donation flow',
        description: 'First-class donation primitive at emotionally-resonant moments.',
        releaseState: ReleaseState.beta,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'referrals.program',
        module: 'Growth',
        name: 'Referral program',
        description: 'Invite-a-friend rewards.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'ads.enabled',
        module: 'Growth',
        name: 'In-app advertisements',
        description: 'Sponsored placements on Home / Learn / Website.',
        releaseState: ReleaseState.hidden,
        allowedAccessLevels: {FeatureAccessLevel.publicGuest},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'content.public_lectures',
        module: 'IQRA Daily',
        name: 'Public Lectures',
        description: 'Guest-accessible recorded lecture library (YouTube/Facebook/embedded links). Admin manages via Nuerizo Control Center.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.publicGuest},
        updatedAt: now,
      ),
      // ── Guest-first action gates ──────────────────────────────────
      // Fine-grained per-action flags so admin can flip exactly which
      // identity-bound actions require login, independent of the
      // module-level flags above.
      FeatureFlag(
        key: 'action.class_enrollment',
        module: 'Guest Access Rules',
        name: 'Enrolling in a class',
        description: 'Whether a visitor must be signed in to enroll in a class.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'action.live_class_join',
        module: 'Guest Access Rules',
        name: 'Joining a live class',
        description: 'Whether a visitor must be signed in to join a scheduled live session.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.student, FeatureAccessLevel.superAdmin},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'action.book_teacher',
        module: 'Guest Access Rules',
        name: 'Booking a teacher',
        description: 'Whether a visitor must be signed in to book a teacher/session.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'action.save_progress',
        module: 'Guest Access Rules',
        name: 'Saving progress',
        description: 'Whether progress (memorization, bookmarks, streaks) requires an account to persist across devices.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'action.homework_submission',
        module: 'Guest Access Rules',
        name: 'Submitting homework',
        description: 'Whether a visitor must be signed in as a student to submit homework.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.student},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'action.certificates',
        module: 'Guest Access Rules',
        name: 'Certificates',
        description: 'Whether certificates require a signed-in student account.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.student},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'action.private_messaging',
        module: 'Guest Access Rules',
        name: 'Private messages',
        description: 'Whether direct messaging between users requires login.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
        updatedAt: now,
      ),
      FeatureFlag(
        key: 'action.personalized_notifications',
        module: 'Guest Access Rules',
        name: 'Personalized notifications',
        description: 'Whether targeted/personalized notifications require an account.',
        releaseState: ReleaseState.public,
        allowedAccessLevels: {FeatureAccessLevel.loggedInUser},
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
  /// (admin/teacher-internal), [isPremiumUser], and [callerAccessLevels]
  /// context. This is the real evaluation logic the whole app runs
  /// through — no UI ever hardcodes visibility.
  ///
  /// Two independent gates must BOTH pass:
  ///  1. [ReleaseState] — is this feature released to anyone yet?
  ///  2. [FeatureAccessLevel] — does this specific caller qualify for the
  ///     audience the admin configured (Public Guest, Logged-in User,
  ///     Student, Parent, Teacher, Academy Admin, Super Admin, Premium,
  ///     Enterprise)?
  bool isEnabled(
    String key, {
    bool isStaff = false,
    bool isPremiumUser = false,
    Set<FeatureAccessLevel>? callerAccessLevels,
  }) {
    final flag = getByKey(key);
    if (flag == null) return false;
    if (flag.killswitch) return false;

    final releaseOk = switch (flag.releaseState) {
      ReleaseState.hidden => false,
      ReleaseState.internal => isStaff,
      ReleaseState.beta => isStaff || true, // rollout% handled by caller/UI badge
      ReleaseState.public => true,
      ReleaseState.premium => isStaff || isPremiumUser,
      ReleaseState.enterprise => isStaff,
    };
    if (!releaseOk) return false;

    // Staff (admin/super admin) can always see everything for
    // moderation/support purposes, regardless of configured access level.
    if (isStaff) return true;

    final callerLevels = callerAccessLevels ?? {FeatureAccessLevel.publicGuest};
    return flag.allowedAccessLevels.any(callerLevels.contains);
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

  /// Admin-panel entry point for changing WHO can access a feature —
  /// e.g. flipping "Enrolling in a class" from Logged-in User to Public
  /// Guest, or restricting a module to Premium only. No code changes,
  /// no redeploy.
  Future<void> updateAccessLevels(String key, Set<FeatureAccessLevel> levels) async {
    final flag = getByKey(key);
    if (flag == null) return;
    await _box.put(key, flag.copyWith(allowedAccessLevels: levels).toMap());
  }
}
