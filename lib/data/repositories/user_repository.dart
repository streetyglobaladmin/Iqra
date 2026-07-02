import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_account.dart';
import '../../models/app_role.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';
import '../../services/auth/password_hasher.dart';

/// Real, working local persistence for user accounts. No mock users are
/// pre-seeded — the platform starts with 0 users, per the "no fake data"
/// requirement. Every account here was actually registered through the
/// sign-up flow.
class UserRepository {
  static final UserRepository instance = UserRepository._();
  UserRepository._();

  final _uuid = const Uuid();

  Box get _box => Db.box(HiveBoxes.users);
  Box get _sessionBox => Db.box(HiveBoxes.session);

  List<UserAccount> getAll() {
    return _box.values
        .map((e) => UserAccount.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  UserAccount? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return UserAccount.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  UserAccount? getByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    try {
      return getAll().firstWhere((u) => u.email.toLowerCase() == normalized);
    } catch (_) {
      return null;
    }
  }

  Future<UserAccount> register({
    required String email,
    required String password,
    required String name,
    required List<AppRole> roles,
    String? referredByCode,
  }) async {
    final existing = getByEmail(email);
    if (existing != null) {
      throw Exception('An account with this email already exists.');
    }
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);
    final now = DateTime.now();
    final id = _uuid.v4();
    final referralCode = _generateReferralCode(id);
    final user = UserAccount(
      id: id,
      email: email.trim(),
      name: name.trim(),
      passwordHash: hash,
      passwordSalt: salt,
      roles: roles,
      referralCode: referralCode,
      referredByCode: referredByCode,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(id, user.toMap());
    await _sessionBox.put('currentUserId', id);
    return user;
  }

  Future<UserAccount> login({
    required String email,
    required String password,
  }) async {
    final user = getByEmail(email);
    if (user == null) {
      throw Exception('No account found for this email.');
    }
    if (!PasswordHasher.verify(password, user.passwordSalt, user.passwordHash)) {
      throw Exception('Incorrect password.');
    }
    await _sessionBox.put('currentUserId', user.id);
    return user;
  }

  Future<void> logout() async {
    await _sessionBox.delete('currentUserId');
  }

  UserAccount? get currentUser {
    final id = _sessionBox.get('currentUserId') as String?;
    if (id == null) return null;
    return getById(id);
  }

  Future<void> update(UserAccount user) async {
    await _box.put(user.id, user.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  String _generateReferralCode(String seed) {
    final code = seed.replaceAll('-', '').substring(0, 8).toUpperCase();
    return 'IQRA-$code';
  }
}
