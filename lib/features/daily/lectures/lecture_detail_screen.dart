import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/lecture.dart';

/// Lecture playback screen — deliberately simple: opens the YouTube /
/// Facebook / embedded video link (and optional audio-only link) in the
/// platform browser or matching app via url_launcher. No native video
/// player, no progress tracking, no quizzes — that belongs to IQRA Studio
/// courses, not this lightweight public content library.
class LectureDetailScreen extends StatelessWidget {
  final Lecture lecture;
  const LectureDetailScreen({super.key, required this.lecture});

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final hasVideo = lecture.videoLink != null && lecture.videoLink!.isNotEmpty;
    final hasAudio = lecture.audioLink != null && lecture.audioLink!.isNotEmpty;

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: Text(lecture.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (lecture.thumbnailUrl != null && lecture.thumbnailUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  lecture.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: s.appCard2,
                    child: Icon(Icons.play_circle_outline, size: 40, color: s.appTextMuted),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(lecture.title, style: text.displayHeadline(size: 20)),
          const SizedBox(height: 6),
          Text('${lecture.scholarName} · ${lecture.category}', style: text.metaDim()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (lecture.duration.isNotEmpty) _pill(Icons.schedule, lecture.duration, s),
              _pill(Icons.language, lecture.language, s),
              if (lecture.isPremium) _pill(Icons.lock_outline, 'Premium', s, color: IqraTokens.gold),
            ],
          ),
          const SizedBox(height: 20),
          if (hasVideo)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launch(lecture.videoLink!),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Watch Video'),
              ),
            ),
          if (hasVideo && hasAudio) const SizedBox(height: 10),
          if (hasAudio)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launch(lecture.audioLink!),
                icon: const Icon(Icons.headphones_outlined),
                label: const Text('Listen (Audio only)'),
              ),
            ),
          if (!hasVideo && !hasAudio)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: IqraTokens.stateWarn.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'No video or audio link has been set for this lecture yet.',
                style: TextStyle(color: IqraTokens.stateWarn, fontSize: 12.5),
              ),
            ),
          if (lecture.description.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('ABOUT THIS LECTURE', style: text.sectionHeader),
            const SizedBox(height: 10),
            Text(lecture.description, style: text.body(size: 13.5)),
          ],
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label, IqraSurface s, {Color? color}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: (color ?? s.appTextDim).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color ?? s.appTextDim),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 11, color: color ?? s.appTextDim, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Future<void> _launch(String link) async {
    final uri = Uri.tryParse(link);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
