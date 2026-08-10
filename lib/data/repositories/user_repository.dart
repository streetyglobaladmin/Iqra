import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_account.dart';
import '../../models/app_role.dart';
import '../../services/iqra_api_service.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';
import '../../services/auth/password_hasher.dart';

/// User accounts backed by the production PHP/MySQL API.
///
/// Login and registration are performed against `iqra.nuerizo.cloud`;
/// on success the JWT is stored in the Hive session box and a local
/// [UserAccount] mirror is kept so the rest of the app (Provider,
/// dashboards, local persistence) continues to work unchanged.
///
/// Local-only accounts created before API integration remain readable
/// via [getAll]/[getById] for data continuity, but authentication always
/// goes through the server.
class UserRepository {
  static final UserRepository instance = UserRepository._();
  UserRepository._();

  final _uuid = const Uuid();
  final _api = IqraApiService.instance;

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

  /// Register a new student account via the production API.
  Future<UserAccount> register({
    required String email,
    required String password,
    required String name,
    required List<AppRole> roles,
    String? referredByCode,
  }) async {
    final result = await _api.studentRegister(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
    return _persistApiUser(result.user, referralCode: referredByCode);
  }

  /// Authenticate against the production API.
  Future<UserAccount> login({
    required String email,
    required String password,
  }) async {
    final result = await _api.studentLogin(
      email: email.trim(),
      password: password,
    );
    return _persistApiUser(result.user);
  }

  /// Refresh the current profile from `/me`. Called during bootstrap.
  /// Returns `null` when the token is missing or invalid.
  Future<UserAccount?> refreshCurrentUser() async {
    if (!_api.tokenStore.hasToken) {
      await logout();
      return null;
    }
    try {
      final apiUser = await _api.getMe();
      return _persistApiUser(apiUser);
    } on IqraApiException catch (e) {
      if (e.statusCode == 401) {
        await logout();
      }
      return null;
    }
  }

  Future<UserAccount> _persistApiUser(ApiUser apiUser, {String? referralCode}) async {
    final now = DateTime.now();
    final localId = apiUser.id.toString();
    final existing = getById(localId);

    final user = UserAccount(
      id: localId,
      email: apiUser.email,
      name: apiUser.name,
      passwordHash: existing?.passwordHash ?? '',
      passwordSalt: existing?.passwordSalt ?? '',
      roles: [AppRole.fromKey(apiUser.role)],
      status: AccountStatus.values.firstWhere(
        (s) => s.name == apiUser.status,
        orElse: () => AccountStatus.active,
      ),
      locale: 'en',
      referralCode: existing?.referralCode ?? _generateReferralCode(localId),
      referredByCode: existing?.referredByCode ?? referralCode,
      createdAt: existing?.createdAt ?? apiUser.createdAt ?? now,
      updatedAt: now,
    );

    await _box.put(localId, user.toMap());
    await _sessionBox.put('currentUserId', localId);
    return user;
  }

  Future<void> logout() async {
    await _api.logout();
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

  // ---------------------------------------------------------------------------
  // Local-only helpers (kept for backward compatibility / offline data)
  // ---------------------------------------------------------------------------

  /// Creates a purely local account. Used only by internal seeding/tests;
  /// the app UI always calls [register] which hits the API.
  Future<UserAccount> localRegister({
    required String email,
    required String password,
    required String name,
    required List<AppRole> roles,
  }) async {
    final existing = getByEmail(email);
    if (existing != null) {
      throw Exception('An account with this email already exists.');
    }
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);
    final now = DateTime.now();
    final id = _uuid.v4();
    final user = UserAccount(
      id: id,
      email: email.trim(),
      name: name.trim(),
      passwordHash: hash,
      passwordSalt: salt,
      roles: roles,
      referralCode: _generateReferralCode(id),
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(id, user.toMap());
    await _sessionBox.put('currentUserId', id);
    return user;
  }

  String _generateReferralCode(String seed) {
    final code = seed.replaceAll('-', '').substring(0, 8).toUpperCase();
    return 'IQRA-$code';
  }
}
