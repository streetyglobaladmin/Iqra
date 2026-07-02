import 'release_state.dart';
import 'feature_access_level.dart';

/// A single feature flag row — "the platform's nervous system".
/// Controlled entirely from the Nuerizo Control Center admin UI, no code
/// changes required to promote/demote a feature or change who can see it.
///
/// Two independent axes:
///  - [releaseState]: what stage of rollout the feature is in (Hidden /
///    Internal Testing / Beta / Public / Premium / Enterprise).
///  - [allowedAccessLevels]: WHO is allowed to use it once released (Public
///    Guest, Logged-in User, Student, Parent, Teacher, Academy Admin,
///    Super Admin, Premium, Enterprise). A caller passes if they satisfy
///    ANY of the levels in this set.
class FeatureFlag {
  final String key; // stable string used in code, e.g. "studio.ai_tutor"
  final String module;
  final String name;
  final String description;
  final ReleaseState releaseState;
  final bool killswitch;
  final int rolloutPct; // 0-100, gradual rollout within the audience
  final Set<FeatureAccessLevel> allowedAccessLevels;
  final DateTime updatedAt;

  FeatureFlag({
    required this.key,
    required this.module,
    required this.name,
    required this.description,
    required this.releaseState,
    this.killswitch = false,
    this.rolloutPct = 100,
    Set<FeatureAccessLevel>? allowedAccessLevels,
    required this.updatedAt,
  }) : allowedAccessLevels = allowedAccessLevels ?? {FeatureAccessLevel.publicGuest};

  /// True if guests (no account) can use this feature at all — used by
  /// the guest-first launch flow to decide whether to show a login prompt.
  bool get isGuestAccessible => allowedAccessLevels.contains(FeatureAccessLevel.publicGuest);

  FeatureFlag copyWith({
    ReleaseState? releaseState,
    bool? killswitch,
    int? rolloutPct,
    Set<FeatureAccessLevel>? allowedAccessLevels,
  }) {
    return FeatureFlag(
      key: key,
      module: module,
      name: name,
      description: description,
      releaseState: releaseState ?? this.releaseState,
      killswitch: killswitch ?? this.killswitch,
      rolloutPct: rolloutPct ?? this.rolloutPct,
      allowedAccessLevels: allowedAccessLevels ?? this.allowedAccessLevels,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'key': key,
        'module': module,
        'name': name,
        'description': description,
        'releaseState': releaseState.name,
        'killswitch': killswitch,
        'rolloutPct': rolloutPct,
        'allowedAccessLevels': allowedAccessLevels.map((a) => a.name).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory FeatureFlag.fromMap(Map map) => FeatureFlag(
        key: map['key'] as String,
        module: map['module'] as String,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        releaseState: ReleaseState.fromKey(map['releaseState'] as String),
        killswitch: map['killswitch'] as bool? ?? false,
        rolloutPct: map['rolloutPct'] as int? ?? 100,
        allowedAccessLevels: ((map['allowedAccessLevels'] as List?) ?? [])
            .map((e) => FeatureAccessLevel.fromKey(e as String))
            .toSet()
          ..addAll(
            // Legacy rows written before this field existed have no
            // allowedAccessLevels key at all — default them to Logged-in
            // User so nothing silently becomes public that wasn't meant to.
            (map['allowedAccessLevels'] == null) ? {FeatureAccessLevel.loggedInUser} : {},
          ),
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
