import 'app_role.dart';

enum AccountStatus { active, suspended, pendingVerification }

class UserAccount {
  final String id;
  final String email;
  final String name;
  final String passwordHash;
  final String passwordSalt;
  final List<AppRole> roles;
  final AccountStatus status;
  final String locale;
  final String? academyId; // for teachers/students tied to an academy
  final String? parentId; // for students linked to a parent account
  final String referralCode;
  final String? referredByCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAccount({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    required this.passwordSalt,
    required this.roles,
    this.status = AccountStatus.active,
    this.locale = 'en',
    this.academyId,
    this.parentId,
    required this.referralCode,
    this.referredByCode,
    required this.createdAt,
    required this.updatedAt,
  });

  bool hasRole(AppRole role) => roles.contains(role);
  bool get isAdmin =>
      hasRole(AppRole.admin) || hasRole(AppRole.superAdmin);

  UserAccount copyWith({
    String? name,
    List<AppRole>? roles,
    AccountStatus? status,
    String? locale,
    String? academyId,
    String? parentId,
    DateTime? updatedAt,
  }) {
    return UserAccount(
      id: id,
      email: email,
      name: name ?? this.name,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      locale: locale ?? this.locale,
      academyId: academyId ?? this.academyId,
      parentId: parentId ?? this.parentId,
      referralCode: referralCode,
      referredByCode: referredByCode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'name': name,
        'passwordHash': passwordHash,
        'passwordSalt': passwordSalt,
        'roles': roles.map((r) => r.name).toList(),
        'status': status.name,
        'locale': locale,
        'academyId': academyId,
        'parentId': parentId,
        'referralCode': referralCode,
        'referredByCode': referredByCode,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserAccount.fromMap(Map map) => UserAccount(
        id: map['id'] as String,
        email: map['email'] as String,
        name: map['name'] as String,
        passwordHash: map['passwordHash'] as String,
        passwordSalt: map['passwordSalt'] as String,
        roles: ((map['roles'] as List?) ?? [])
            .map((e) => AppRole.fromKey(e as String))
            .toList(),
        status: AccountStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => AccountStatus.active,
        ),
        locale: map['locale'] as String? ?? 'en',
        academyId: map['academyId'] as String?,
        parentId: map['parentId'] as String?,
        referralCode: map['referralCode'] as String? ?? '',
        referredByCode: map['referredByCode'] as String?,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
