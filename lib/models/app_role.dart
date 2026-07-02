/// The roles a user account can hold inside the IQRA ecosystem.
/// A single account may hold multiple roles via [UserAccount.roles]
/// (e.g. a parent who is also a student, or a teacher who is also an admin).
enum AppRole {
  student,
  parent,
  teacher,
  admin,
  superAdmin;

  String get label {
    switch (this) {
      case AppRole.student:
        return 'Student';
      case AppRole.parent:
        return 'Parent';
      case AppRole.teacher:
        return 'Teacher / Scholar';
      case AppRole.admin:
        return 'Admin';
      case AppRole.superAdmin:
        return 'Super Admin (Nuerizo)';
    }
  }

  static AppRole fromKey(String key) => AppRole.values.firstWhere(
        (r) => r.name == key,
        orElse: () => AppRole.student,
      );
}
