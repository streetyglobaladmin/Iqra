import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/repositories/audit_log_repository.dart';

/// Real audit log — every admin mutation (flag change, user suspension,
/// etc.) writes here automatically. Starts empty.
class AuditLogPage extends StatelessWidget {
  const AuditLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final entries = AuditLogRepository.instance.getAll();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Audit Log', style: text.cardTitle(size: 20)),
        const SizedBox(height: 4),
        Text('Every admin action is recorded automatically.', style: text.metaDim()),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          const IqraEmptyState(
            icon: Icons.history_outlined,
            title: 'No audit entries yet',
            subtitle: 'Actions taken in the Control Center (flag changes, user suspensions, etc.) will be logged here.',
          )
        else
          ...entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: s.appBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.summary, style: text.body(size: 12.5, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${e.actorName} · ${e.action} · ${e.at.toString().split('.').first}', style: text.metaDim()),
                  ],
                ),
              )),
      ],
    );
  }
}
