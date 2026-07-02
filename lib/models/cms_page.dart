enum CmsStatus { draft, review, published }

class CmsPage {
  final String id;
  final String slug;
  final String title;
  final String body;
  final CmsStatus status;
  final bool isBlogPost;
  final String? coverUrl;
  final List<String> tags;
  final DateTime updatedAt;

  CmsPage({
    required this.id,
    required this.slug,
    required this.title,
    required this.body,
    required this.status,
    this.isBlogPost = false,
    this.coverUrl,
    this.tags = const [],
    required this.updatedAt,
  });

  CmsPage copyWith({
    String? title,
    String? body,
    CmsStatus? status,
    List<String>? tags,
  }) {
    return CmsPage(
      id: id,
      slug: slug,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      isBlogPost: isBlogPost,
      coverUrl: coverUrl,
      tags: tags ?? this.tags,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'slug': slug,
        'title': title,
        'body': body,
        'status': status.name,
        'isBlogPost': isBlogPost,
        'coverUrl': coverUrl,
        'tags': tags,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CmsPage.fromMap(Map map) => CmsPage(
        id: map['id'] as String,
        slug: map['slug'] as String,
        title: map['title'] as String,
        body: map['body'] as String? ?? '',
        status: CmsStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => CmsStatus.draft,
        ),
        isBlogPost: map['isBlogPost'] as bool? ?? false,
        coverUrl: map['coverUrl'] as String?,
        tags: List<String>.from(map['tags'] as List? ?? []),
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
