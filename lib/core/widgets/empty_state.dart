import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A genuine empty-state widget — used everywhere data legitimately
/// doesn't exist yet ("0 users", "No data yet", "Waiting for first
/// activity"), per the no-fake-data requirement.
class IqraEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const IqraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: s.appCard2,
              shape: BoxShape.circle,
              border: Border.all(color: s.appBorder),
            ),
            child: Icon(icon, color: IqraTokens.gold, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: text.cardTitle(size: 16), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: text.bodyDim(size: 12.5),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
