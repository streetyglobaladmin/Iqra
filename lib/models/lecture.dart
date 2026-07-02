/// Publish-state for a single public lecture — mirrors the CMS pattern
/// (draft/published) plus an explicit "hidden" state so the admin can take
/// a live lecture down without deleting it.
enum LecturePublishStatus { draft, published, hidden }

extension LecturePublishStatusX on LecturePublishStatus {
  String get label {
    switch (this) {
      case LecturePublishStatus.draft:
        return 'Draft';
      case LecturePublishStatus.published:
        return 'Published';
      case LecturePublishStatus.hidden:
        return 'Hidden';
    }
  }

  static LecturePublishStatus fromKey(String key) =>
      LecturePublishStatus.values.firstWhere(
        (s) => s.name == key,
        orElse: () => LecturePublishStatus.draft,
      );
}

/// A single public lecture — deliberately lightweight (no modules, no
/// progress tracking, no quizzes). This is content playback + metadata
/// only; real course logic belongs to IQRA Studio classes, not here.
///
/// Video/audio are external links (YouTube, Facebook, or any embeddable
/// URL) opened via the platform browser/app — no native player is bundled
/// in this first version.
class Lecture {
  final String id;
  final String title;
  final String scholarName;
  final String category;
  final String? thumbnailUrl;
  final String description;
  final String? videoLink;
  final String? audioLink;
  final String duration; // free text, e.g. "42 min"
  final String language;
  final LecturePublishStatus status;

  /// If true, a visitor must be signed in to open this specific lecture —
  /// lets the admin mark individual lectures "private/premium" without a
  /// separate course-access system. Public Lectures overall stay
  /// guest-accessible; this is a per-item override, off by default.
  final bool isPremium;
  final DateTime updatedAt;

  Lecture({
    required this.id,
    required this.title,
    required this.scholarName,
    required this.category,
    this.thumbnailUrl,
    this.description = '',
    this.videoLink,
    this.audioLink,
    this.duration = '',
    this.language = 'Arabic',
    this.status = LecturePublishStatus.draft,
    this.isPremium = false,
    required this.updatedAt,
  });

  bool get isPublished => status == LecturePublishStatus.published;

  Lecture copyWith({
    String? title,
    String? scholarName,
    String? category,
    String? thumbnailUrl,
    String? description,
    String? videoLink,
    String? audioLink,
    String? duration,
    String? language,
    LecturePublishStatus? status,
    bool? isPremium,
  }) {
    return Lecture(
      id: id,
      title: title ?? this.title,
      scholarName: scholarName ?? this.scholarName,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      videoLink: videoLink ?? this.videoLink,
      audioLink: audioLink ?? this.audioLink,
      duration: duration ?? this.duration,
      language: language ?? this.language,
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'scholarName': scholarName,
        'category': category,
        'thumbnailUrl': thumbnailUrl,
        'description': description,
        'videoLink': videoLink,
        'audioLink': audioLink,
        'duration': duration,
        'language': language,
        'status': status.name,
        'isPremium': isPremium,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Lecture.fromMap(Map map) => Lecture(
        id: map['id'] as String,
        title: map['title'] as String? ?? '',
        scholarName: map['scholarName'] as String? ?? '',
        category: map['category'] as String? ?? 'General',
        thumbnailUrl: map['thumbnailUrl'] as String?,
        description: map['description'] as String? ?? '',
        videoLink: map['videoLink'] as String?,
        audioLink: map['audioLink'] as String?,
        duration: map['duration'] as String? ?? '',
        language: map['language'] as String? ?? 'Arabic',
        status: LecturePublishStatusX.fromKey(map['status'] as String? ?? 'draft'),
        isPremium: map['isPremium'] as bool? ?? false,
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
