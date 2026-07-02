import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/release_badge.dart';
import '../../../models/release_state.dart';
import '../../../data/repositories/feature_flag_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../data/repositories/user_repository.dart';

/// Real feature-flag admin: every major module can be promoted/demoted
/// between the six release states with one tap, plus a killswitch and
/// rollout % slider — no code changes, no redeploy.
class FeatureFlagsPage extends StatefulWidget {
  const FeatureFlagsPage({super.key});

  @override
  State<FeatureFlagsPage> createState() => _FeatureFlagsPageState();
}

class _FeatureFlagsPageState extends State<FeatureFlagsPage> {
  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final flags = FeatureFlagRepository.instance.getAll();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Feature Flags', style: text.cardTitle(size: 20)),
        const SizedBox(height: 4),
        Text('The platform\'s nervous system — promote, demote, or kill any feature instantly.', style: text.metaDim()),
        const SizedBox(height: 20),
        ...flags.map((flag) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: s.appBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(flag.name, style: text.body(size: 14, weight: FontWeight.w700)),
                            Text(flag.module, style: text.metaDim()),
                          ],
                        ),
                      ),
                      ReleaseBadge(state: flag.releaseState),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(flag.description, style: text.bodyDim(size: 12)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ReleaseState.values.map((state) {
                      final selected = flag.releaseState == state;
                      return ChoiceChip(
                        label: Text(state.label, style: const TextStyle(fontSize: 10.5)),
                        selected: selected,
                        onSelected: (_) async {
                          await FeatureFlagRepository.instance.updateReleaseState(flag.key, state);
                          await AuditLogRepository.instance.record(
                            actorId: UserRepository.instance.currentUser?.id ?? 'admin',
                            actorName: UserRepository.instance.currentUser?.name ?? 'Admin',
                            action: 'flag.promote',
                            subjectType: 'feature_flag',
                            subjectId: flag.key,
                            summary: 'Set "${flag.name}" to ${state.label}',
                          );
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.dangerous_outlined, size: 15, color: IqraTokens.stateDanger),
                      const SizedBox(width: 6),
                      Text('Kill switch', style: text.metaDim()),
                      const Spacer(),
                      Switch(
                        value: flag.killswitch,
                        onChanged: (v) async {
                          await FeatureFlagRepository.instance.updateKillswitch(flag.key, v);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
