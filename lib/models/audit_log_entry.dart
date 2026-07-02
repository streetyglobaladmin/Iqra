class AuditLogEntry {
  final String id;
  final DateTime at;
  final String actorId;
  final String actorName;
  final String action; // e.g. "flag.promote", "user.suspend"
  final String subjectType;
  final String subjectId;
  final String summary;

  AuditLogEntry({
    required this.id,
    required this.at,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.subjectType,
    required this.subjectId,
    required this.summary,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'at': at.toIso8601String(),
        'actorId': actorId,
        'actorName': actorName,
        'action': action,
        'subjectType': subjectType,
        'subjectId': subjectId,
        'summary': summary,
      };

  factory AuditLogEntry.fromMap(Map map) => AuditLogEntry(
        id: map['id'] as String,
        at: DateTime.tryParse(map['at'] as String? ?? '') ?? DateTime.now(),
        actorId: map['actorId'] as String,
        actorName: map['actorName'] as String? ?? 'Unknown',
        action: map['action'] as String,
        subjectType: map['subjectType'] as String? ?? '',
        subjectId: map['subjectId'] as String? ?? '',
        summary: map['summary'] as String? ?? '',
      );
}
