import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/state/app_state.dart';
import '../../../core/auth/login_gate.dart';
import '../../../models/lecture.dart';
import '../../../services/iqra_api_service.dart';
import '../../../data/repositories/lecture_repository.dart';
import 'lecture_detail_screen.dart';

/// Public Lectures — loads published lessons from `/videos` and falls
/// back to locally cached lectures when offline. Guest-accessible.
class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  String? _category;
  bool _loading = true;
  String? _error;
  List<Lecture> _lectures = [];

  @override
  void initState() {
    super.initState();
    _loadLectures();
  }

  Future<void> _loadLectures() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lessons = await IqraApiService.instance.getVideos();
      if (mounted) {
        setState(() => _lectures = lessons.map(_apiLessonToLecture).toList());
      }
    } on IqraApiException catch (e) {
      if (mounted) {
        final local = LectureRepository.instance.getAll().where((l) => l.isPublished).toList();
        setState(() {
          _lectures = local;
          _error = local.isEmpty ? e.message : null;
        });
      }
    } catch (e) {
      if (mounted) {
        final local = LectureRepository.instance.getAll().where((l) => l.isPublished).toList();
        setState(() {
          _lectures = local;
          _error = local.isEmpty ? e.toString() : null;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Lecture _apiLessonToLecture(ApiLesson l) {
    return Lecture(
      id: l.id.toString(),
      title: l.title,
      scholarName: 'IQRA Scholar',
      category: 'Lessons',
      thumbnailUrl: l.thumbnailUrl,
      description: l.description ?? '',
      videoLink: l.videoUrl,
      duration: l.durationSeconds != null ? '${l.durationSeconds! ~/ 60} min' : '',
      language: 'Arabic',
      status: l.isPublished ? LecturePublishStatus.published : LecturePublishStatus.draft,
      isPremium: false,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = context.surface;
    final text = IqraText(s);

    final categories = _lectures.map((l) => l.category).toSet().toList()..sort();
    final visible = _category == null
        ? _lectures
        : _lectures.where((l) => l.category == _category).toList();

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Public Lectures')),
      body: RefreshIndicator(
        onRefresh: _loadLectures,
        color: IqraTokens.gold,
        backgroundColor: s.appCard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
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
              ),
            if (_loading && _lectures.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_lectures.isEmpty && !_loading)
              SliverFillRemaining(
                child: Center(
                  child: IqraEmptyState(
                    icon: Icons.play_circle_outline,
                    title: 'No lectures yet',
                    subtitle: _error ??
                        'Lectures published from the Nuerizo Control Center will appear here — free to watch, no account needed.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _lectureCard(context, visible[i], s, text, appState),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _lectureCard(BuildContext context, Lecture l, IqraSurface s, IqraText text, AppState appState) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        void open() {
          if (l.videoLink != null && l.videoLink!.isNotEmpty) {
            final uri = Uri.tryParse(l.videoLink!);
            if (uri != null) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LectureDetailScreen(lecture: l)),
            );
          }
        }
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
