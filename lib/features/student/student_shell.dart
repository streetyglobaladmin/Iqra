import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/state/app_state.dart';
import '../../core/auth/guest_locked_screen.dart';
import '../../services/iqra_api_service.dart';
import '../../data/repositories/student_repository.dart';

/// Student experience: enrolled classes loaded from `/enrollments`,
/// memorization tracker, and homework. Guests see the locked gate.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  bool _loading = true;
  String? _error;
  List<ApiEnrollment> _enrollments = [];
  List<ApiLiveSession> _liveSessions = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final enrollments = await IqraApiService.instance.getEnrollments();
      List<ApiLiveSession> sessions = [];
      try {
        sessions = await IqraApiService.instance.getLiveSessions();
      } on IqraApiException {
        // Live sessions are non-critical; keep enrollments if they loaded.
      }
      if (mounted) {
        setState(() {
          _enrollments = enrollments;
          _liveSessions = sessions;
        });
      }
    } on IqraApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    // Guest-first: Student dashboard is login-required.
    if (user == null) {
      return const GuestLockedScreen(
        surfaceName: 'Student',
        icon: Icons.school_outlined,
        message: 'Your classes, memorization tracker, and homework are tied to your account.',
      );
    }

    final s = context.surface;
    final text = IqraText(s);
    final useArabic = appState.prayerSettings.useArabicNumerals;

    final profile = StudentRepository.instance.getByUserId(user.id);

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Student')),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: IqraTokens.gold,
        backgroundColor: s.appCard,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [IqraTokens.emerald, IqraTokens.emeraldDeep]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, ${user.name}',
                            style: const TextStyle(fontFamily: IqraFonts.display, fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          profile != null
                              ? 'Level: ${profile.level} · ${Numerals.format(profile.streakDays, useArabic: useArabic)} day streak'
                              : 'Complete your profile to get started',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.school, color: Colors.white.withValues(alpha: 0.85), size: 32),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _statsRow(profile, s, text, useArabic),
            const SizedBox(height: 24),
            Text('MY CLASSES', style: text.sectionHeader),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2),
              ))
            else if (_error != null && _enrollments.isEmpty)
              Container(
                decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
                child: IqraEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Unable to load enrollments',
                  subtitle: _error!,
                ),
              )
            else if (_enrollments.isEmpty)
              Container(
                decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
                child: const IqraEmptyState(
                  icon: Icons.video_call_outlined,
                  title: 'No classes yet',
                  subtitle: 'Enroll in a class from the Learn tab. Once enrolled, it will appear here with the live session link.',
                ),
              )
            else
              ..._enrollments.map((e) => _enrollmentCard(context, e, s, text)),
            const SizedBox(height: 24),
            Text('LIVE SESSIONS', style: text.sectionHeader),
            const SizedBox(height: 12),
            if (_liveSessions.isEmpty)
              Container(
                decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
                child: const IqraEmptyState(
                  icon: Icons.live_tv_outlined,
                  title: 'No upcoming live sessions',
                  subtitle: 'Your teacher will schedule live classes here.',
                ),
              )
            else
              ..._liveSessions.map((ls) => _liveSessionCard(context, ls, s, text)),
            const SizedBox(height: 24),
            Text('HOMEWORK', style: text.sectionHeader),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
              child: const IqraEmptyState(
                icon: Icons.assignment_outlined,
                title: 'No homework assigned',
                subtitle: 'Waiting for first activity from your teacher.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(dynamic profile, IqraSurface s, IqraText text, bool useArabic) {
    final versesMemorized = profile?.versesMemorized ?? 0;
    final enrolled = _enrollments.length;
    return Row(
      children: [
        Expanded(child: _statCard('Verses memorized', Numerals.format(versesMemorized, useArabic: useArabic), s, text)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Enrolled classes', Numerals.format(enrolled, useArabic: useArabic), s, text)),
      ],
    );
  }

  Widget _statCard(String label, String value, IqraSurface s, IqraText text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: s.appBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontFamily: IqraFonts.numeric, fontSize: 24, fontWeight: FontWeight.w600, color: IqraTokens.gold)),
          const SizedBox(height: 4),
          Text(label, style: text.metaDim()),
        ],
      ),
    );
  }

  Widget _enrollmentCard(BuildContext context, ApiEnrollment e, IqraSurface s, IqraText text) {
    final statusColor = e.status == 'active'
        ? IqraTokens.stateSuccess
        : e.status == 'pending'
            ? IqraTokens.stateWarn
            : s.appTextDim;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: s.appBorder)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: IqraTokens.lapisLt.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.menu_book_outlined, color: IqraTokens.lapisLt),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.classTitle ?? 'Class #${e.classId}', style: text.body(size: 13.5, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(e.status.toUpperCase(), style: text.metaDim()),
                    if (e.progressPct > 0) ...[
                      const SizedBox(width: 12),
                      Text('${e.progressPct}%', style: text.metaDim()),
                    ],
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _openLiveSession(context, e.classId),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget _liveSessionCard(BuildContext context, ApiLiveSession ls, IqraSurface s, IqraText text) {
    final statusColor = ls.isLive ? IqraTokens.stateSuccess : s.appTextDim;
    final timeText = ls.scheduledAt != null
        ? '${ls.scheduledAt!.day}/${ls.scheduledAt!.month} · ${ls.scheduledAt!.hour.toString().padLeft(2, '0')}:${ls.scheduledAt!.minute.toString().padLeft(2, '0')}'
        : 'Scheduled';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: s.appBorder)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: IqraTokens.rubyLt.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.live_tv_outlined, color: IqraTokens.rubyLt),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ls.title, style: text.body(size: 13.5, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(ls.status.toUpperCase(), style: text.metaDim()),
                    const SizedBox(width: 12),
                    Text(timeText, style: text.metaDim()),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _joinLiveSession(context, ls.id),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinLiveSession(BuildContext context, int sessionId) async {
    try {
      final result = await IqraApiService.instance.joinLiveSession(sessionId);
      if (result.joinUrl != null && result.joinUrl!.isNotEmpty) {
        final uri = Uri.tryParse(result.joinUrl!);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No join URL returned for this session.')),
        );
      }
    } on IqraApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _openLiveSession(BuildContext context, int classId) async {
    // Find the next joinable live session for this class.
    try {
      final sessions = await IqraApiService.instance.getLiveSessions(classId: classId);
      final joinable = sessions.where((s) => s.isJoinable).toList();
      if (joinable.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No live session is available for this class right now.')),
        );
        return;
      }
      final session = joinable.first;
      final result = await IqraApiService.instance.joinLiveSession(session.id);
      if (result.joinUrl != null && result.joinUrl!.isNotEmpty) {
        final uri = Uri.tryParse(result.joinUrl!);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No join URL returned for this session.')),
        );
      }
    } on IqraApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
