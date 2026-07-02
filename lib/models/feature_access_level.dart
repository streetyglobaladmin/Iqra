/// The audience axis for a feature flag — answers "who is allowed to use
/// this, once it's released?" This is separate from [ReleaseState], which
/// answers "what stage of rollout is this in?". A flag can be e.g.
/// `ReleaseState.public` + `{FeatureAccessLevel.student}` — fully shipped,
/// but only visible to logged-in students.
///
/// Admin-controlled from Nuerizo Control Center → Feature Flags. No code
/// changes required to change who can see a feature.
enum FeatureAccessLevel {
  publicGuest,
  loggedInUser,
  student,
  parent,
  teacher,
  academyAdmin,
  superAdmin,
  premium,
  enterprise;

  String get label {
    switch (this) {
      case FeatureAccessLevel.publicGuest:
        return 'Public Guest';
      case FeatureAccessLevel.loggedInUser:
        return 'Logged-in User';
      case FeatureAccessLevel.student:
        return 'Student';
      case FeatureAccessLevel.parent:
        return 'Parent';
      case FeatureAccessLevel.teacher:
        return 'Teacher';
      case FeatureAccessLevel.academyAdmin:
        return 'Academy Admin';
      case FeatureAccessLevel.superAdmin:
        return 'Super Admin';
      case FeatureAccessLevel.premium:
        return 'Premium';
      case FeatureAccessLevel.enterprise:
        return 'Enterprise';
    }
  }

  String get description {
    switch (this) {
      case FeatureAccessLevel.publicGuest:
        return 'No account needed — anyone who opens the app can use this.';
      case FeatureAccessLevel.loggedInUser:
        return 'Any signed-in account, regardless of role.';
      case FeatureAccessLevel.student:
        return 'Accounts holding the Student role.';
      case FeatureAccessLevel.parent:
        return 'Accounts holding the Parent role.';
      case FeatureAccessLevel.teacher:
        return 'Accounts holding the Teacher / Scholar role.';
      case FeatureAccessLevel.academyAdmin:
        return 'Academy-level administrators.';
      case FeatureAccessLevel.superAdmin:
        return 'Nuerizo super administrators only.';
      case FeatureAccessLevel.premium:
        return 'Requires an active premium subscription.';
      case FeatureAccessLevel.enterprise:
        return 'Reserved for enterprise academy contracts.';
    }
  }

  static FeatureAccessLevel fromKey(String key) => FeatureAccessLevel.values.firstWhere(
        (r) => r.name == key,
        orElse: () => FeatureAccessLevel.loggedInUser,
      );
}
