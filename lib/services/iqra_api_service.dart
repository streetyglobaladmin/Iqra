import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../data/local/db.dart';
import '../data/local/hive_boxes.dart';

// ===========================================================================
// IQRA Production API Service
// ===========================================================================
// A thin, typed wrapper around https://iqra.nuerizo.cloud/api/v1.
// All endpoints return the server envelope { "ok": true, "data": ..., "meta": ... }
// or throw [IqraApiException] on failure.
//
// Auth tokens are read from / written to the Hive session box by
// [IqraAuthTokenStore], keeping this class focused on HTTP.
// ===========================================================================

const String _defaultBaseUrl = 'https://iqra.nuerizo.cloud/api/v1';

/// Allows overriding the base URL at build time, e.g.
/// `--dart-define=IQRA_API_URL=https://staging.iqra.nuerizo.cloud/api/v1`.
const String iqraApiBaseUrl = String.fromEnvironment(
  'IQRA_API_URL',
  defaultValue: _defaultBaseUrl,
);

class IqraApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? type;
  final String? detail;

  const IqraApiException({
    required this.message,
    this.statusCode,
    this.type,
    this.detail,
  });

  @override
  String toString() => message;
}

/// Lightweight persistence for the JWT access token.
class IqraAuthTokenStore {
  IqraAuthTokenStore._();
  static final IqraAuthTokenStore instance = IqraAuthTokenStore._();

  static const _tokenKey = 'accessToken';
  static const _tokenTypeKey = 'tokenType';

  Box get _box => Db.box(HiveBoxes.session);

  String? get token => _box.get(_tokenKey) as String?;
  String? get tokenType => _box.get(_tokenTypeKey) as String? ?? 'Bearer';

  Future<void> save(String token, {String tokenType = 'Bearer'}) async {
    await _box.put(_tokenKey, token);
    await _box.put(_tokenTypeKey, tokenType);
  }

  Future<void> clear() async {
    await _box.delete(_tokenKey);
    await _box.delete(_tokenTypeKey);
  }

  bool get hasToken => token != null && token!.isNotEmpty;
}

/// Simple offline cache backed by Hive. Any module can read cached data
/// when the API is unreachable; callers decide whether stale data is usable.
class IqraApiCache {
  IqraApiCache._();
  static final IqraApiCache instance = IqraApiCache._();

  Box get _box => Db.box(HiveBoxes.appSettings);

  String _key(String endpoint) => 'api_cache:$endpoint';

  Future<void> set(String endpoint, dynamic data) async {
    await _box.put(_key(endpoint), {
      'cachedAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  Map<String, dynamic>? get(String endpoint) {
    final raw = _box.get(_key(endpoint));
    if (raw is! Map) return null;
    try {
      return Map<String, dynamic>.from(raw as Map);
    } catch (_) {
      return null;
    }
  }

  dynamic getData(String endpoint) {
    final entry = get(endpoint);
    return entry?['data'];
  }

  Future<void> invalidate(String endpoint) async {
    await _box.delete(_key(endpoint));
  }
}

/// Typed API service. Instantiate with [IqraApiService()] or use
/// [IqraApiService.instance].
class IqraApiService {
  static final IqraApiService instance = IqraApiService._();
  IqraApiService._();

  final http.Client _client = http.Client();
  final _tokenStore = IqraAuthTokenStore.instance;
  final _cache = IqraApiCache.instance;

  String get baseUrl => iqraApiBaseUrl;

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  Future<AuthResult> studentLogin({
    required String email,
    required String password,
  }) async {
    final data = await _post(
      '/auth/student/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );
    return _handleAuthResponse(data);
  }

  Future<AuthResult> studentRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _post(
      '/auth/student/register',
      body: {'name': name, 'email': email, 'password': password},
      requiresAuth: false,
    );
    return _handleAuthResponse(data);
  }

  Future<void> logout() async {
    await _tokenStore.clear();
  }

  AuthResult _handleAuthResponse(Map<String, dynamic> data) {
    final token = data['access_token'] as String?;
    final tokenType = data['token_type'] as String? ?? 'Bearer';
    final user = data['user'] as Map<String, dynamic>?;
    if (token == null || token.isEmpty || user == null) {
      throw const IqraApiException(
        message: 'Invalid response from server: missing token or user.',
        statusCode: 200,
        type: 'invalid_response',
      );
    }
    _tokenStore.save(token, tokenType: tokenType);
    return AuthResult(
      token: token,
      tokenType: tokenType,
      user: ApiUser.fromJson(user),
    );
  }

  // ---------------------------------------------------------------------------
  // Me / Profile
  // ---------------------------------------------------------------------------

  Future<ApiUser> getMe() async {
    final data = await _get('/me');
    return ApiUser.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Home
  // ---------------------------------------------------------------------------

  Future<AppHomeResponse> getAppHome() async {
    final data = await _get('/app/home', cacheKey: '/app/home');
    return AppHomeResponse.fromJson(data);
  }

  AppHomeResponse? getAppHomeCached() {
    final cached = _cache.getData('/app/home');
    if (cached == null) return null;
    try {
      return AppHomeResponse.fromJson(Map<String, dynamic>.from(cached as Map));
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Scholars
  // ---------------------------------------------------------------------------

  Future<List<ApiScholar>> getScholars({
    String? status,
    String? query,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (status != null && status.isNotEmpty) 'status': status,
      if (query != null && query.isNotEmpty) 'q': query,
    };
    final data = await _get('/scholars', query: params, cacheKey: '/scholars');
    return (data as List)
        .map((e) => ApiScholar.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  List<ApiScholar>? getScholarsCached() {
    final cached = _cache.getData('/scholars');
    if (cached == null) return null;
    try {
      return (cached as List)
          .map((e) => ApiScholar.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<ApiScholarDetail> getScholar(int id) async {
    final data = await _get('/scholars/$id', cacheKey: '/scholars/$id');
    return ApiScholarDetail.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Classes
  // ---------------------------------------------------------------------------

  Future<List<ApiClass>> getClasses({
    String? track,
    int? scholarId,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (track != null && track.isNotEmpty) 'track': track,
      if (scholarId != null) 'scholar_id': '$scholarId',
    };
    final data = await _get('/classes', query: params, cacheKey: '/classes');
    return (data as List)
        .map((e) => ApiClass.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  List<ApiClass>? getClassesCached() {
    final cached = _cache.getData('/classes');
    if (cached == null) return null;
    try {
      return (cached as List)
          .map((e) => ApiClass.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<ApiClassDetail> getClass(int id) async {
    final data = await _get('/classes/$id', cacheKey: '/classes/$id');
    return ApiClassDetail.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Videos / Lessons
  // ---------------------------------------------------------------------------

  Future<List<ApiLesson>> getVideos({
    int? classId,
    int? scholarId,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (classId != null) 'class_id': '$classId',
      if (scholarId != null) 'scholar_id': '$scholarId',
    };
    final data = await _get('/videos', query: params, cacheKey: '/videos');
    return (data as List)
        .map((e) => ApiLesson.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<ApiLesson> getVideo(int id) async {
    final data = await _get('/videos/$id', cacheKey: '/videos/$id');
    return ApiLesson.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Enrollments
  // ---------------------------------------------------------------------------

  Future<ApiEnrollmentResult> enroll({required int classId}) async {
    final data = await _post(
      '/enrollments',
      body: {'class_id': classId},
    );
    return ApiEnrollmentResult.fromJson(data);
  }

  Future<List<ApiEnrollment>> getEnrollments() async {
    final data = await _get('/enrollments');
    return (data as List)
        .map((e) => ApiEnrollment.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Live sessions
  // ---------------------------------------------------------------------------

  Future<List<ApiLiveSession>> getLiveSessions({
    int? classId,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (classId != null) 'class_id': '$classId',
    };
    final data = await _get('/live-sessions', query: params, cacheKey: '/live-sessions');
    return (data as List)
        .map((e) => ApiLiveSession.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<ApiLiveSession> getLiveSession(int id) async {
    final data = await _get('/live-sessions/$id', cacheKey: '/live-sessions/$id');
    return ApiLiveSession.fromJson(data);
  }

  Future<ApiLiveJoinResult> joinLiveSession(int id) async {
    final data = await _post('/live-sessions/$id/join', body: {});
    return ApiLiveJoinResult.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Payments
  // ---------------------------------------------------------------------------

  Future<ApiPaymentSettings> getPaymentSettings({
    int? classId,
    int? subscriptionId,
  }) async {
    final params = <String, String>{
      if (classId != null) 'class_id': '$classId',
      if (subscriptionId != null) 'subscription_id': '$subscriptionId',
    };
    final data = await _get('/payments/settings', query: params);
    return ApiPaymentSettings.fromJson(data);
  }

  Future<ApiPaymentSubmitResult> submitPayment({
    int? classId,
    int? subscriptionId,
    required int amountCents,
    required String utr,
    String? payerNotes,
    String currency = 'INR',
  }) async {
    final body = <String, dynamic>{
      'amount_cents': amountCents,
      'utr': utr,
      'currency': currency,
      if (classId != null) 'class_id': classId,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (payerNotes != null && payerNotes.isNotEmpty) 'payer_notes': payerNotes,
    };
    final data = await _post('/payments/submit', body: body);
    return ApiPaymentSubmitResult.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getSettings() async {
    final data = await _get('/settings', cacheKey: '/settings');
    return Map<String, dynamic>.from(data as Map);
  }

  // ---------------------------------------------------------------------------
  // HTTP plumbing
  // ---------------------------------------------------------------------------

  Future<dynamic> _get(
    String path, {
    Map<String, String>? query,
    String? cacheKey,
  }) async {
    final uri = _uri(path, query);
    final response = await _client.get(uri, headers: _headers(requiresAuth: true));
    return _processResponse(response, cacheKey: cacheKey);
  }

  Future<dynamic> _post(
    String path, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
    String? cacheKey,
  }) async {
    final uri = _uri(path);
    final response = await _client.post(
      uri,
      headers: _headers(requiresAuth: requiresAuth),
      body: jsonEncode(body),
    );
    return _processResponse(response, cacheKey: cacheKey);
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(baseUrl);
    final segments = [...base.pathSegments, ...path.split('/').where((s) => s.isNotEmpty)];
    return base.replace(
      pathSegments: segments,
      queryParameters: query?.isNotEmpty == true ? query : null,
    );
  }

  Map<String, String> _headers({required bool requiresAuth}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = _tokenStore.token;
      if (token == null || token.isEmpty) {
        throw const IqraApiException(
          message: 'Not authenticated.',
          statusCode: 401,
          type: 'unauthenticated',
        );
      }
      headers['Authorization'] = '${_tokenStore.tokenType} $token';
    }
    return headers;
  }

  Future<dynamic> _processResponse(
    http.Response response, {
    String? cacheKey,
  }) async {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>?;
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final ok = body?['ok'] as bool? ?? true;
      if (!ok) {
        throw _errorFromBody(body, response.statusCode);
      }
      final data = body?['data'];
      if (cacheKey != null && data != null) {
        await _cache.set(cacheKey, data);
      }
      return data;
    }

    throw _errorFromBody(body, response.statusCode, fallback: response.body);
  }

  IqraApiException _errorFromBody(
    Map<String, dynamic>? body,
    int statusCode, {
    String? fallback,
  }) {
    final error = body?['error'] as Map<String, dynamic>?;
    String title = error?['title'] as String? ??
        error?['message'] as String? ??
        fallback ??
        'Request failed.';
    if (statusCode == 401) title = title;
    return IqraApiException(
      message: title,
      statusCode: statusCode,
      type: error?['type'] as String?,
      detail: error?['detail'] as String?,
    );
  }
}

// ===========================================================================
// Response models
// ===========================================================================

class AuthResult {
  final String token;
  final String tokenType;
  final ApiUser user;

  const AuthResult({
    required this.token,
    required this.tokenType,
    required this.user,
  });
}

class ApiUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? avatarUrl;
  final String status;
  final DateTime? createdAt;
  final Map<String, dynamic>? scholarProfile;

  const ApiUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.status = 'active',
    this.createdAt,
    this.scholarProfile,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      scholarProfile: json['scholar_profile'] as Map<String, dynamic>?,
    );
  }
}

class AppHomeResponse {
  final Map<String, dynamic> appSettings;
  final Map<String, dynamic> featureFlags;
  final List<ApiScholar> featuredScholars;
  final List<ApiClass> featuredClasses;
  final List<ApiLesson> latestLessons;

  const AppHomeResponse({
    required this.appSettings,
    required this.featureFlags,
    required this.featuredScholars,
    required this.featuredClasses,
    required this.latestLessons,
  });

  factory AppHomeResponse.fromJson(Map<String, dynamic> json) {
    return AppHomeResponse(
      appSettings: Map<String, dynamic>.from(json['app_settings'] as Map? ?? {}),
      featureFlags: Map<String, dynamic>.from(json['feature_flags'] as Map? ?? {}),
      featuredScholars: ((json['featured_scholars'] as List?) ?? [])
          .map((e) => ApiScholar.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      featuredClasses: ((json['featured_classes'] as List?) ?? [])
          .map((e) => ApiClass.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      latestLessons: ((json['latest_lessons'] as List?) ?? [])
          .map((e) => ApiLesson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class ApiScholar {
  final int id;
  final String slug;
  final String name;
  final String? kunya;
  final String? bio;
  final List<String> specialties;
  final List<String> languages;
  final String? madhab;
  final String? city;
  final String? country;
  final bool verified;
  final double ratingAvg;
  final int sessionCount;
  final String? avatarUrl;
  final String? coverUrl;
  final String? status;

  const ApiScholar({
    required this.id,
    required this.slug,
    required this.name,
    this.kunya,
    this.bio,
    this.specialties = const [],
    this.languages = const [],
    this.madhab,
    this.city,
    this.country,
    this.verified = false,
    this.ratingAvg = 0,
    this.sessionCount = 0,
    this.avatarUrl,
    this.coverUrl,
    this.status,
  });

  factory ApiScholar.fromJson(Map<String, dynamic> json) {
    return ApiScholar(
      id: json['id'] as int,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? json['user_name'] as String? ?? '',
      kunya: json['kunya'] as String?,
      bio: json['bio'] as String?,
      specialties: _stringList(json['specialties']),
      languages: _stringList(json['languages']),
      madhab: json['madhab'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      verified: json['verified'] as bool? ?? false,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      sessionCount: json['session_count'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      status: json['status'] as String?,
    );
  }
}

class ApiScholarDetail extends ApiScholar {
  final List<ApiClass> classes;

  const ApiScholarDetail({
    required super.id,
    required super.slug,
    required super.name,
    super.kunya,
    super.bio,
    super.specialties,
    super.languages,
    super.madhab,
    super.city,
    super.country,
    super.verified,
    super.ratingAvg,
    super.sessionCount,
    super.avatarUrl,
    super.coverUrl,
    super.status,
    this.classes = const [],
  });

  factory ApiScholarDetail.fromJson(Map<String, dynamic> json) {
    final base = ApiScholar.fromJson(json);
    return ApiScholarDetail(
      id: base.id,
      slug: base.slug,
      name: base.name,
      kunya: base.kunya,
      bio: base.bio,
      specialties: base.specialties,
      languages: base.languages,
      madhab: base.madhab,
      city: base.city,
      country: base.country,
      verified: base.verified,
      ratingAvg: base.ratingAvg,
      sessionCount: base.sessionCount,
      avatarUrl: base.avatarUrl,
      coverUrl: base.coverUrl,
      status: base.status,
      classes: ((json['classes'] as List?) ?? [])
          .map((e) => ApiClass.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class ApiClass {
  final int id;
  final int scholarId;
  final String? scholarName;
  final String? scholarSlug;
  final String title;
  final String? slug;
  final String? description;
  final String? track;
  final String? level;
  final String? scheduleText;
  final int? capacity;
  final int priceCents;
  final String currency;
  final String? coverUrl;
  final String? status;
  final int studentsEnrolled;

  const ApiClass({
    required this.id,
    required this.scholarId,
    this.scholarName,
    this.scholarSlug,
    required this.title,
    this.slug,
    this.description,
    this.track,
    this.level,
    this.scheduleText,
    this.capacity,
    this.priceCents = 0,
    this.currency = 'INR',
    this.coverUrl,
    this.status,
    this.studentsEnrolled = 0,
  });

  factory ApiClass.fromJson(Map<String, dynamic> json) {
    return ApiClass(
      id: json['id'] as int,
      scholarId: json['scholar_id'] as int,
      scholarName: json['scholar_name'] as String?,
      scholarSlug: json['scholar_slug'] as String?,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      track: json['track'] as String?,
      level: json['level'] as String? ?? 'beginner',
      scheduleText: json['schedule_text'] as String?,
      capacity: json['capacity'] as int?,
      priceCents: json['price_cents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      coverUrl: json['cover_url'] as String?,
      status: json['status'] as String?,
      studentsEnrolled: json['students_enrolled'] as int? ?? 0,
    );
  }

  bool get isFree => priceCents == 0;
}

class ApiClassDetail extends ApiClass {
  final List<ApiLesson> lessons;

  const ApiClassDetail({
    required super.id,
    required super.scholarId,
    super.scholarName,
    super.scholarSlug,
    required super.title,
    super.slug,
    super.description,
    super.track,
    super.level,
    super.scheduleText,
    super.capacity,
    super.priceCents,
    super.currency,
    super.coverUrl,
    super.status,
    super.studentsEnrolled,
    this.lessons = const [],
  });

  factory ApiClassDetail.fromJson(Map<String, dynamic> json) {
    final base = ApiClass.fromJson(json);
    return ApiClassDetail(
      id: base.id,
      scholarId: base.scholarId,
      scholarName: base.scholarName,
      scholarSlug: base.scholarSlug,
      title: base.title,
      slug: base.slug,
      description: base.description,
      track: base.track,
      level: base.level,
      scheduleText: base.scheduleText,
      capacity: base.capacity,
      priceCents: base.priceCents,
      currency: base.currency,
      coverUrl: base.coverUrl,
      status: base.status,
      studentsEnrolled: base.studentsEnrolled,
      lessons: ((json['lessons'] as List?) ?? [])
          .map((e) => ApiLesson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class ApiLesson {
  final int id;
  final int? classId;
  final int scholarId;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? videoStatus;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final bool isPublished;
  final int viewsCount;

  const ApiLesson({
    required this.id,
    this.classId,
    required this.scholarId,
    required this.title,
    this.description,
    this.videoUrl,
    this.videoStatus,
    this.thumbnailUrl,
    this.durationSeconds,
    this.isPublished = false,
    this.viewsCount = 0,
  });

  factory ApiLesson.fromJson(Map<String, dynamic> json) {
    return ApiLesson(
      id: json['id'] as int,
      classId: json['class_id'] as int?,
      scholarId: json['scholar_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String?,
      videoStatus: json['video_status'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      isPublished: json['is_published'] as bool? ?? false,
      viewsCount: json['views_count'] as int? ?? 0,
    );
  }
}

class ApiEnrollmentResult {
  final int id;
  final int classId;
  final String status;
  final bool paymentRequired;
  final String? paymentNote;

  const ApiEnrollmentResult({
    required this.id,
    required this.classId,
    required this.status,
    required this.paymentRequired,
    this.paymentNote,
  });

  factory ApiEnrollmentResult.fromJson(Map<String, dynamic> json) {
    return ApiEnrollmentResult(
      id: json['id'] as int,
      classId: json['class_id'] as int,
      status: json['status'] as String? ?? 'pending',
      paymentRequired: json['payment_required'] as bool? ?? false,
      paymentNote: json['payment_note'] as String?,
    );
  }
}

class ApiEnrollment {
  final int id;
  final int classId;
  final String? classTitle;
  final String? classSlug;
  final String? coverUrl;
  final String status;
  final int progressPct;
  final DateTime? enrolledAt;

  const ApiEnrollment({
    required this.id,
    required this.classId,
    this.classTitle,
    this.classSlug,
    this.coverUrl,
    required this.status,
    this.progressPct = 0,
    this.enrolledAt,
  });

  factory ApiEnrollment.fromJson(Map<String, dynamic> json) {
    return ApiEnrollment(
      id: json['id'] as int,
      classId: json['class_id'] as int,
      classTitle: json['class_title'] as String?,
      classSlug: json['class_slug'] as String?,
      coverUrl: json['cover_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      progressPct: json['progress_pct'] as int? ?? 0,
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.tryParse(json['enrolled_at'] as String)
          : null,
    );
  }
}

class ApiLiveSession {
  final int id;
  final int classId;
  final String? classTitle;
  final int scholarId;
  final String? scholarName;
  final String title;
  final DateTime? scheduledAt;
  final int durationMinutes;
  final String status;
  final String? roomId;
  final String provider;
  final String? joinUrl;
  final bool isPlaceholder;
  final String? joinNote;

  const ApiLiveSession({
    required this.id,
    required this.classId,
    this.classTitle,
    required this.scholarId,
    this.scholarName,
    required this.title,
    this.scheduledAt,
    this.durationMinutes = 0,
    this.status = 'scheduled',
    this.roomId,
    this.provider = 'jitsi',
    this.joinUrl,
    this.isPlaceholder = false,
    this.joinNote,
  });

  factory ApiLiveSession.fromJson(Map<String, dynamic> json) {
    return ApiLiveSession(
      id: json['id'] as int,
      classId: json['class_id'] as int,
      classTitle: json['class_title'] as String?,
      scholarId: json['scholar_id'] as int,
      scholarName: json['scholar_name'] as String?,
      title: json['title'] as String? ?? '',
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      status: json['status'] as String? ?? 'scheduled',
      roomId: json['room_id'] as String?,
      provider: json['provider'] as String? ?? 'jitsi',
      joinUrl: json['join_url'] as String?,
      isPlaceholder: json['is_placeholder'] as bool? ?? false,
      joinNote: json['join_note'] as String?,
    );
  }

  bool get isLive => status == 'live';
  bool get isJoinable => status == 'live' || status == 'scheduled';
}

class ApiLiveJoinResult {
  final int sessionId;
  final String? roomId;
  final String provider;
  final String? joinUrl;
  final String status;
  final String role;

  const ApiLiveJoinResult({
    required this.sessionId,
    this.roomId,
    required this.provider,
    this.joinUrl,
    required this.status,
    required this.role,
  });

  factory ApiLiveJoinResult.fromJson(Map<String, dynamic> json) {
    return ApiLiveJoinResult(
      sessionId: json['session_id'] as int,
      roomId: json['room_id'] as String?,
      provider: json['provider'] as String? ?? 'jitsi',
      joinUrl: json['join_url'] as String?,
      status: json['status'] as String? ?? 'scheduled',
      role: json['role'] as String? ?? 'student',
    );
  }
}

class ApiPaymentSettings {
  final bool paymentsEnabled;
  final String? paymentsMode;
  final String? upiId;
  final String? upiPayeeName;
  final String? upiQrUrl;
  final String? upiInstructions;
  final String? supportWhatsapp;
  final int? amountCents;
  final String currency;
  final int? classId;
  final int? subscriptionId;

  const ApiPaymentSettings({
    required this.paymentsEnabled,
    this.paymentsMode,
    this.upiId,
    this.upiPayeeName,
    this.upiQrUrl,
    this.upiInstructions,
    this.supportWhatsapp,
    this.amountCents,
    this.currency = 'INR',
    this.classId,
    this.subscriptionId,
  });

  factory ApiPaymentSettings.fromJson(Map<String, dynamic> json) {
    return ApiPaymentSettings(
      paymentsEnabled: json['payments_enabled'] as bool? ?? false,
      paymentsMode: json['payments_mode'] as String?,
      upiId: json['upi_id'] as String?,
      upiPayeeName: json['upi_payee_name'] as String?,
      upiQrUrl: json['upi_qr_url'] as String?,
      upiInstructions: json['upi_instructions'] as String?,
      supportWhatsapp: json['support_whatsapp'] as String?,
      amountCents: json['amount_cents'] as int?,
      currency: json['currency'] as String? ?? 'INR',
      classId: json['class_id'] as int?,
      subscriptionId: json['subscription_id'] as int?,
    );
  }
}

class ApiPaymentSubmitResult {
  final int id;
  final String status;
  final String message;

  const ApiPaymentSubmitResult({
    required this.id,
    required this.status,
    required this.message,
  });

  factory ApiPaymentSubmitResult.fromJson(Map<String, dynamic> json) {
    return ApiPaymentSubmitResult(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? 'Payment request submitted.',
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<String> _stringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
  }
  if (value is String) {
    return value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
  return [];
}
