import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../models/audit_log_entry.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

/// Every admin mutation writes here automatically. This is real audit
/// logging, not a mockup — call [record] from every admin action.
class AuditLogRepository {
  static final AuditLogRepository instance = AuditLogRepository._();
  AuditLogRepository._();

  final _uuid = const Uuid();

  Box get _box => Db.box(HiveBoxes.auditLog);

  List<AuditLogEntry> getAll() => _box.values
      .map((e) => AuditLogEntry.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.at.compareTo(a.at));

  Future<void> record({
    required String actorId,
    required String actorName,
    required String action,
    required String subjectType,
    required String subjectId,
    required String summary,
  }) async {
    final entry = AuditLogEntry(
      id: _uuid.v4(),
      at: DateTime.now(),
      actorId: actorId,
      actorName: actorName,
      action: action,
      subjectType: subjectType,
      subjectId: subjectId,
      summary: summary,
    );
    await _box.put(entry.id, entry.toMap());
  }
}
