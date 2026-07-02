enum AdPlacement { homeBanner, learnFeed, websiteHero }

class Advertisement {
  final String id;
  final String title;
  final String body;
  final AdPlacement placement;
  final String? targetUrl;
  final bool active;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int impressions;
  final int clicks;

  Advertisement({
    required this.id,
    required this.title,
    required this.body,
    required this.placement,
    this.targetUrl,
    this.active = true,
    required this.startsAt,
    this.endsAt,
    this.impressions = 0,
    this.clicks = 0,
  });

  Advertisement copyWith({
    String? title,
    String? body,
    bool? active,
    int? impressions,
    int? clicks,
  }) {
    return Advertisement(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      placement: placement,
      targetUrl: targetUrl,
      active: active ?? this.active,
      startsAt: startsAt,
      endsAt: endsAt,
      impressions: impressions ?? this.impressions,
      clicks: clicks ?? this.clicks,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'placement': placement.name,
        'targetUrl': targetUrl,
        'active': active,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt?.toIso8601String(),
        'impressions': impressions,
        'clicks': clicks,
      };

  factory Advertisement.fromMap(Map map) => Advertisement(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String? ?? '',
        placement: AdPlacement.values.firstWhere(
          (p) => p.name == map['placement'],
          orElse: () => AdPlacement.homeBanner,
        ),
        targetUrl: map['targetUrl'] as String?,
        active: map['active'] as bool? ?? true,
        startsAt: DateTime.tryParse(map['startsAt'] as String? ?? '') ??
            DateTime.now(),
        endsAt: map['endsAt'] != null
            ? DateTime.tryParse(map['endsAt'] as String)
            : null,
        impressions: map['impressions'] as int? ?? 0,
        clicks: map['clicks'] as int? ?? 0,
      );
}
