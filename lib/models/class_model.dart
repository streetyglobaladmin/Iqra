/// A recurring class run by a teacher, with a live-class link.
/// [videoProvider] / [videoLink] implement the "Zoom/Meet now, LiveKit
/// later" provider-abstraction requirement — see [LiveClassProvider].
enum LiveClassProvider { zoom, googleMeet, liveKit, none }

class ClassSession {
  final String id;
  final String teacherId;
  final String title;
  final String level; // beginner, intermediate, advanced
  final String scheduleSummary; // human-readable e.g. "Mon/Wed 6:00 PM"
  final LiveClassProvider provider;
  final String? meetingLink;
  final int priceAmountMinor; // 0 = free
  final String priceCurrency; // ISO 4217, e.g. USD, INR, PKR
  final List<String> studentIds;
  final DateTime createdAt;

  ClassSession({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.level,
    required this.scheduleSummary,
    required this.provider,
    this.meetingLink,
    this.priceAmountMinor = 0,
    this.priceCurrency = 'USD',
    this.studentIds = const [],
    required this.createdAt,
  });

  ClassSession copyWith({
    String? title,
    String? level,
    String? scheduleSummary,
    LiveClassProvider? provider,
    String? meetingLink,
    int? priceAmountMinor,
    String? priceCurrency,
    List<String>? studentIds,
  }) {
    return ClassSession(
      id: id,
      teacherId: teacherId,
      title: title ?? this.title,
      level: level ?? this.level,
      scheduleSummary: scheduleSummary ?? this.scheduleSummary,
      provider: provider ?? this.provider,
      meetingLink: meetingLink ?? this.meetingLink,
      priceAmountMinor: priceAmountMinor ?? this.priceAmountMinor,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'teacherId': teacherId,
        'title': title,
        'level': level,
        'scheduleSummary': scheduleSummary,
        'provider': provider.name,
        'meetingLink': meetingLink,
        'priceAmountMinor': priceAmountMinor,
        'priceCurrency': priceCurrency,
        'studentIds': studentIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ClassSession.fromMap(Map map) => ClassSession(
        id: map['id'] as String,
        teacherId: map['teacherId'] as String,
        title: map['title'] as String,
        level: map['level'] as String? ?? 'beginner',
        scheduleSummary: map['scheduleSummary'] as String? ?? '',
        provider: LiveClassProvider.values.firstWhere(
          (p) => p.name == map['provider'],
          orElse: () => LiveClassProvider.none,
        ),
        meetingLink: map['meetingLink'] as String?,
        priceAmountMinor: map['priceAmountMinor'] as int? ?? 0,
        priceCurrency: map['priceCurrency'] as String? ?? 'USD',
        studentIds: List<String>.from(map['studentIds'] as List? ?? []),
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
