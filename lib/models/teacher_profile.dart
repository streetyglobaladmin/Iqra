class TeacherProfile {
  final String id;
  final String userId;
  final String name;
  final String bio;
  final List<String> specialties;
  final bool verified;
  final bool online;
  final DateTime createdAt;

  TeacherProfile({
    required this.id,
    required this.userId,
    required this.name,
    this.bio = '',
    this.specialties = const [],
    this.verified = false,
    this.online = false,
    required this.createdAt,
  });

  TeacherProfile copyWith({
    String? bio,
    List<String>? specialties,
    bool? verified,
    bool? online,
  }) {
    return TeacherProfile(
      id: id,
      userId: userId,
      name: name,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      verified: verified ?? this.verified,
      online: online ?? this.online,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'bio': bio,
        'specialties': specialties,
        'verified': verified,
        'online': online,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TeacherProfile.fromMap(Map map) => TeacherProfile(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        bio: map['bio'] as String? ?? '',
        specialties: List<String>.from(map['specialties'] as List? ?? []),
        verified: map['verified'] as bool? ?? false,
        online: map['online'] as bool? ?? false,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
