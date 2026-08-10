import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/state/app_state.dart';
import '../../../core/auth/login_gate.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../services/iqra_api_service.dart';
import 'payment_screen.dart';

/// Detail view for a published class loaded from `/classes/:id`.
/// Guests can browse; enrolled students or free classes can proceed to
/// live sessions. Enrollment is gated behind login.
class ClassDetailScreen extends StatefulWidget {
  final int classId;
  const ClassDetailScreen({super.key, required this.classId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  bool _loading = true;
  String? _error;
  ApiClassDetail? _classDetail;
  bool _enrolling = false;
  String? _enrollMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await IqraApiService.instance.getClass(widget.classId);
      if (mounted) setState(() => _classDetail = detail);
    } on IqraApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _enroll() async {
    setState(() {
      _enrolling = true;
      _enrollMessage = null;
    });
    try {
      final result = await IqraApiService.instance.enroll(classId: widget.classId);
      if (!mounted) return;
      if (result.paymentRequired) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(classId: widget.classId),
          ),
        );
        return;
      }
      setState(() => _enrollMessage = 'Enrollment status: ${result.status}');
    } on IqraApiException catch (e) {
      if (mounted) setState(() => _enrollMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _enrollMessage = e.toString());
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Class Details')),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        color: IqraTokens.gold,
        backgroundColor: s.appCard,
        child: _buildBody(context, s, text, appState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, IqraSurface s, IqraText text, AppState appState) {
    if (_loading) {
      return const ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 240),
          Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: IqraEmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load class',
              subtitle: _error!,
            ),
          ),
        ],
      );
    }

    final c = _classDetail!;
    final priceLabel = c.isFree
        ? 'Free'
        : '${(c.priceCents / 100).toStringAsFixed(2)} ${c.currency}';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (c.coverUrl != null && c.coverUrl!.isNotEmpty)
          Container(
            height: 180,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: s.appCard2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.network(
              c.coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.school_outlined, color: s.appTextMuted, size: 48),
              ),
            ),
          )
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: IqraTokens.emeraldLt.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.school_outlined, color: IqraTokens.emeraldLt, size: 48),
            ),
          ),
        const SizedBox(height: 20),
        Text(c.title, style: text.cardTitle(size: 20)),
        const SizedBox(height: 8),
        if (c.scholarName != null)
          Text('By ${c.scholarName}',
              style: text.body(size: 13, weight: FontWeight.w600).copyWith(color: IqraTokens.gold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _infoPill(context, s, text, Icons.schedule_outlined, c.scheduleText ?? 'TBD'),
            const SizedBox(width: 8),
            _infoPill(context, s, text, Icons.signal_cellular_alt_outlined, c.level ?? 'beginner'),
            const SizedBox(width: 8),
            _infoPill(context, s, text, Icons.currency_rupee_outlined, priceLabel),
          ],
        ),
        const SizedBox(height: 20),
        if (c.description != null && c.description!.isNotEmpty) ...[
          Text('ABOUT', style: text.sectionHeader),
          const SizedBox(height: 8),
          Text(c.description!, style: text.body(size: 13)),
          const SizedBox(height: 24),
        ],
        Text('LESSONS', style: text.sectionHeader),
        const SizedBox(height: 12),
        if (c.lessons.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: s.appCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: s.appBorder),
            ),
            child: const IqraEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No lessons yet',
              subtitle: 'Lessons for this class will appear once published.',
            ),
          )
        else
          ...c.lessons.map((l) => _lessonTile(context, l, s, text)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _enrolling
                ? null
                : () {
                    void doEnroll() => _enroll();
                    if (appState.isGuest) {
                      requireLogin(
                        context,
                        isLoggedIn: false,
                        title: 'Sign in to enroll',
                        message: 'Create a free account or sign in to join this class.',
                        onAuthenticated: doEnroll,
                      );
                    } else {
                      doEnroll();
                    }
                  },
            child: _enrolling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: IqraTokens.ink),
                  )
                : Text(c.isFree ? 'Enroll for free' : 'Enroll — $priceLabel'),
          ),
        ),
        if (_enrollMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _enrollMessage!.startsWith('Enrollment status:')
                  ? IqraTokens.stateSuccess.withValues(alpha: 0.12)
                  : IqraTokens.stateWarn.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _enrollMessage!,
              style: TextStyle(
                color: _enrollMessage!.startsWith('Enrollment status:')
                    ? IqraTokens.stateSuccess
                    : IqraTokens.stateWarn,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _infoPill(BuildContext context, IqraSurface s, IqraText text, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: s.appCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.appBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: s.appTextMuted),
          const SizedBox(width: 6),
          Text(label, style: text.metaDim(size: 11)),
        ],
      ),
    );
  }

  Widget _lessonTile(BuildContext context, ApiLesson l, IqraSurface s, IqraText text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: s.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: s.appBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: IqraTokens.lapisLt.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.play_circle_outline, color: IqraTokens.lapisLt),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.title, style: text.body(size: 13.5, weight: FontWeight.w700)),
                if (l.durationSeconds != null)
                  Text(
                    '${l.durationSeconds! ~/ 60} min',
                    style: text.metaDim(),
                  ),
              ],
            ),
          ),
          if (l.videoUrl != null && l.videoUrl!.isNotEmpty)
            Icon(Icons.play_arrow, color: IqraTokens.gold)
          else
            Icon(Icons.lock_clock_outlined, color: s.appTextMuted, size: 18),
        ],
      ),
    );
  }
}
