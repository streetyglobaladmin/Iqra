import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/state/app_state.dart';
import '../../../core/auth/login_gate.dart';
import '../../../models/lecture.dart';
import '../../../data/repositories/lecture_repository.dart';
import 'lecture_detail_screen.dart';

/// Public Lectures — guest-accessible recorded lecture library. Same
/// lightweight pattern as Articles/Hadith: no login required to browse or
/// watch a public lecture. Only opening a lecture explicitly marked
/// "premium/private" by the admin, or bookmarking/saving progress, asks
/// the visitor to sign in.
class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = context.surface;
    final text = IqraText(s);

    final allPublished = LectureRepository.instance.getAll()
        .where((l) => l.isPublished)
        .toList();
    final categories = allPublished.map((l) => l.category).toSet().toList()..sort();
    final visible = _category == null
        ? allPublished
        : allPublished.where((l) => l.category == _category).toList();

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Public Lectures')),
      body: allPublished.isEmpty
          ? Center(
              child: IqraEmptyState(
                icon: Icons.play_circle_outline,
                title: 'No lectures yet',
                subtitle: 'Lectures published from the Nuerizo Control Center will appear here — free to watch, no account needed.',
              ),
            )
          : Column(
              children: [
                if (categories.isNotEmpty)
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: _category == null,
                            onSelected: (_) => setState(() => _category = null),
                          ),
                        ),
                        ...categories.map((c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(c),
                                selected: _category == c,
                                onSelected: (_) => setState(() => _category = _category == c ? null : c),
                              ),
                            )),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _lectureCard(context, visible[i], s, text, appState),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _lectureCard(BuildContext context, Lecture l, IqraSurface s, IqraText text, AppState appState) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        void open() => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LectureDetailScreen(lecture: l)),
            );
        // Guest-first: only lectures the admin explicitly marked premium
        // require sign-in. Regular public lectures always open directly.
        if (l.isPremium) {
          requireLogin(
            context,
            isLoggedIn: !appState.isGuest,
            title: 'Sign in to watch',
            message: 'This lecture has been marked premium/private by the academy.',
            onAuthenticated: open,
          );
        } else {
          open();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: s.appCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: s.appBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: s.appCard2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: l.thumbnailUrl != null && l.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      l.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.play_circle_outline, color: s.appTextMuted),
                    )
                  : Icon(Icons.play_circle_outline, color: s.appTextMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(l.title, style: text.body(size: 14, weight: FontWeight.w700))),
                      if (l.isPremium) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.lock_outline, size: 13, color: IqraTokens.gold),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(l.scholarName, style: text.metaDim()),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _pill(l.category, IqraTokens.emeraldLt),
                      if (l.duration.isNotEmpty) _pill(l.duration, IqraTokens.lapisLt),
                      _pill(l.language, IqraTokens.goldLt),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
      );
}
