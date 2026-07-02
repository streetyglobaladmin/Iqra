class Academy {
  final String id;
  final String name;
  final String slug;
  final String region;
  final String plan; // free, teacher_pro, academy, enterprise
  final DateTime createdAt;

  Academy({
    required this.id,
    required this.name,
    required this.slug,
    required this.region,
    required this.plan,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'slug': slug,
        'region': region,
        'plan': plan,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Academy.fromMap(Map map) => Academy(
        id: map['id'] as String,
        name: map['name'] as String,
        slug: map['slug'] as String,
        region: map['region'] as String? ?? '',
        plan: map['plan'] as String? ?? 'free',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
