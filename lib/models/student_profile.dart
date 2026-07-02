class StudentProfile {
  final String id;
  final String userId;
  final String name;
  final String? parentId;
  final String level; // beginner, intermediate, advanced, hafiz-track
  final int versesMemorized;
  final int streakDays;
  final DateTime? lastActivityAt;
  final List<String> enrolledClassIds;

  StudentProfile({
    required this.id,
    required this.userId,
    required this.name,
    this.parentId,
    this.level = 'beginner',
    this.versesMemorized = 0,
    this.streakDays = 0,
    this.lastActivityAt,
    this.enrolledClassIds = const [],
  });

  StudentProfile copyWith({
    int? versesMemorized,
    int? streakDays,
    DateTime? lastActivityAt,
    List<String>? enrolledClassIds,
    String? level,
  }) {
    return StudentProfile(
      id: id,
      userId: userId,
      name: name,
      parentId: parentId,
      level: level ?? this.level,
      versesMemorized: versesMemorized ?? this.versesMemorized,
      streakDays: streakDays ?? this.streakDays,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      enrolledClassIds: enrolledClassIds ?? this.enrolledClassIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'parentId': parentId,
        'level': level,
        'versesMemorized': versesMemorized,
        'streakDays': streakDays,
        'lastActivityAt': lastActivityAt?.toIso8601String(),
        'enrolledClassIds': enrolledClassIds,
      };

  factory StudentProfile.fromMap(Map map) => StudentProfile(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        parentId: map['parentId'] as String?,
        level: map['level'] as String? ?? 'beginner',
        versesMemorized: map['versesMemorized'] as int? ?? 0,
        streakDays: map['streakDays'] as int? ?? 0,
        lastActivityAt: map['lastActivityAt'] != null
            ? DateTime.tryParse(map['lastActivityAt'] as String)
            : null,
        enrolledClassIds:
            List<String>.from(map['enrolledClassIds'] as List? ?? []),
      );
}
