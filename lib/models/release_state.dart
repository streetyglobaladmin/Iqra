/// The six release states every IQRA feature flag can be in.
/// This is "the platform's nervous system" per the design blueprint —
/// promotion/demotion is one click from the admin panel, no code changes.
enum ReleaseState {
  hidden,
  internal,
  beta,
  public,
  premium,
  enterprise;

  String get label {
    switch (this) {
      case ReleaseState.hidden:
        return 'Hidden';
      case ReleaseState.internal:
        return 'Internal Testing';
      case ReleaseState.beta:
        return 'Beta';
      case ReleaseState.public:
        return 'Public';
      case ReleaseState.premium:
        return 'Premium';
      case ReleaseState.enterprise:
        return 'Enterprise';
    }
  }

  String get description {
    switch (this) {
      case ReleaseState.hidden:
        return 'No one sees this. Exists in code/DB but invisible to all users.';
      case ReleaseState.internal:
        return 'Visible only to admin/staff roles.';
      case ReleaseState.beta:
        return 'Visible to a named beta cohort or rollout %.';
      case ReleaseState.public:
        return 'Available to all users, including the free tier.';
      case ReleaseState.premium:
        return 'Gated by subscription tier.';
      case ReleaseState.enterprise:
        return 'Reserved for enterprise academies & contracts.';
    }
  }

  static ReleaseState fromKey(String key) => ReleaseState.values.firstWhere(
        (r) => r.name == key,
        orElse: () => ReleaseState.hidden,
      );
}
