import 'release_state.dart';

/// A single feature flag row — "the platform's nervous system".
/// Controlled entirely from the Nuerizo Control Center admin UI, no code
/// changes required to promote/demote a feature.
class FeatureFlag {
  final String key; // stable string used in code, e.g. "studio.ai_tutor"
  final String module;
  final String name;
  final String description;
  final ReleaseState releaseState;
  final bool killswitch;
  final int rolloutPct; // 0-100, gradual rollout within the audience
  final DateTime updatedAt;

  FeatureFlag({
    required this.key,
    required this.module,
    required this.name,
    required this.description,
    required this.releaseState,
    this.killswitch = false,
    this.rolloutPct = 100,
    required this.updatedAt,
  });

  FeatureFlag copyWith({
    ReleaseState? releaseState,
    bool? killswitch,
    int? rolloutPct,
  }) {
    return FeatureFlag(
      key: key,
      module: module,
      name: name,
      description: description,
      releaseState: releaseState ?? this.releaseState,
      killswitch: killswitch ?? this.killswitch,
      rolloutPct: rolloutPct ?? this.rolloutPct,
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
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
