import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/class_model.dart';

/// The join screen for a scheduled class. Uses Zoom/Google Meet external
/// links today (provider abstraction ready for LiveKit later — see
/// [LiveClassAdapter]).
class LiveClassView extends StatelessWidget {
  final ClassSession session;
  const LiveClassView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final hasLink = session.meetingLink != null && session.meetingLink!.isNotEmpty;

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: Text(session.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: s.appCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: s.appBorder),
              ),
              child: Column(
                children: [
                  Icon(_providerIcon(session.provider), size: 40, color: IqraTokens.gold),
                  const SizedBox(height: 12),
                  Text(_providerLabel(session.provider), style: text.cardTitle(size: 16)),
                  const SizedBox(height: 4),
                  Text(session.scheduleSummary, style: text.metaDim()),
                  const SizedBox(height: 20),
                  if (hasLink)
                    ElevatedButton.icon(
                      onPressed: () => _launchLink(session.meetingLink!),
                      icon: const Icon(Icons.video_call),
                      label: const Text('Join Live Class'),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: IqraTokens.stateWarn.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'No meeting link has been set for this class yet.',
                        style: TextStyle(color: IqraTokens.stateWarn, fontSize: 12.5),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: s.appCard2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: s.appTextDim),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live classes currently use Zoom/Google Meet links. Native in-app video via LiveKit is planned — the provider abstraction is already in place.',
                      style: text.metaDim(size: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _providerIcon(LiveClassProvider p) {
    switch (p) {
      case LiveClassProvider.zoom:
        return Icons.videocam_outlined;
      case LiveClassProvider.googleMeet:
        return Icons.duo_outlined;
      case LiveClassProvider.liveKit:
        return Icons.live_tv_outlined;
      case LiveClassProvider.none:
        return Icons.video_call_outlined;
    }
  }

  String _providerLabel(LiveClassProvider p) {
    switch (p) {
      case LiveClassProvider.zoom:
        return 'Zoom Meeting';
      case LiveClassProvider.googleMeet:
        return 'Google Meet';
      case LiveClassProvider.liveKit:
        return 'LiveKit (Native Video)';
      case LiveClassProvider.none:
        return 'No provider set';
    }
  }

  Future<void> _launchLink(String link) async {
    final uri = Uri.tryParse(link);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
