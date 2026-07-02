import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/iqra_logo.dart';
import '../../core/widgets/responsive.dart';
import '../../data/repositories/pricing_repository.dart';
import '../../data/repositories/lecture_repository.dart';
import '../../models/pricing_plan.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../hub/hub_shell.dart';

/// The Public Website — the marketing/landing surface for
/// iqra.nuerizo.com. Reuses the exact same design tokens, repositories,
/// and screens as the app itself (no separate codebase, no rebuild).
/// Fully guest-accessible: every link on this page either opens a guest
/// -accessible screen or a non-blocking login/register prompt.
class PublicWebsiteScreen extends StatelessWidget {
  const PublicWebsiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = IqraSurface.dark;
    final text = IqraText(s);
    final plans = PricingRepository.instance.getAllPlans();
    final lectureCount = LectureRepository.instance.getAll().where((l) => l.isPublished).length;

    return Scaffold(
      backgroundColor: s.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 1100,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(context, s, text),
                const SizedBox(height: 32),
                _hero(context, s, text),
                const SizedBox(height: 40),
                _featureGrid(context, s, text),
                const SizedBox(height: 40),
                _lecturesTeaser(context, s, text, lectureCount),
                const SizedBox(height: 40),
                _pricingTeaser(context, s, text, plans),
                const SizedBox(height: 40),
                _ecosystemLinks(context, s, text),
                const SizedBox(height: 32),
                _footer(context, s, text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, IqraSurface s, IqraText text) {
    final wide = Breakpoints.isTablet(context);
    return Row(
      children: [
        const IqraLogoMark(size: 36),
        const SizedBox(width: 10),
        const IqraWordmark(fontSize: 20),
        const Spacer(),
        if (wide)
          TextButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const HubShell())),
            child: Text('Browse as Guest', style: TextStyle(color: s.appTextDim, fontSize: 12.5)),
          ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
          style: OutlinedButton.styleFrom(side: BorderSide(color: IqraTokens.gold.withValues(alpha: 0.6))),
          child: const Text('Log In', style: TextStyle(fontSize: 12.5)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
          child: const Text('Create Account', style: TextStyle(fontSize: 12.5)),
        ),
      ],
    );
  }

  Widget _hero(BuildContext context, IqraSurface s, IqraText text) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: IqraTokens.skyDhuhr,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GUEST-FIRST · ADMIN-CONTROLLED',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2, color: Colors.white70)),
          const SizedBox(height: 10),
          const Text(
            'Prayer times, Qur\'ān, Hadith, lectures and scholars — free to everyone. No account required.',
            style: TextStyle(fontFamily: IqraFonts.display, fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 12),
          const Text(
            'IQRA is a full Islamic education ecosystem: a free daily companion for everyone, plus classes, live sessions, and dashboards for students, parents, and teachers who choose to sign in.',
            style: TextStyle(fontFamily: IqraFonts.sans, fontSize: 14, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const HubShell())),
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Open IQRA — No Sign-in Needed'),
                style: ElevatedButton.styleFrom(backgroundColor: IqraTokens.gold, foregroundColor: IqraTokens.ink),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
                icon: const Icon(Icons.person_add_alt_outlined, color: Colors.white),
                label: const Text('Create a free account', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _guestFeatures = [
    ('Prayer Times & Qibla', Icons.explore_outlined, IqraTokens.emeraldLt),
    ('Qur\'ān Reader', Icons.menu_book_outlined, IqraTokens.lapisLt),
    ('Daily Hadith & Duʿās', Icons.favorite_border, IqraTokens.rubyLt),
    ('Hijri Calendar', Icons.calendar_month_outlined, IqraTokens.goldLt),
    ('Public Lectures', Icons.play_circle_outline, IqraTokens.saffron),
    ('Scholar Directory', Icons.school_outlined, IqraTokens.emeraldLt),
    ('Tasbīḥ Counter', Icons.circle_outlined, IqraTokens.lapisLt),
    ('Articles & Blog', Icons.article_outlined, IqraTokens.rubyLt),
  ];

  Widget _featureGrid(BuildContext context, IqraSurface s, IqraText text) {
    final cols = responsiveColumns(MediaQuery.of(context).size.width).clamp(2, 4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FREE FOR EVERYONE — NO LOGIN', style: text.sectionHeader),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: _guestFeatures.map((f) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: s.appCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: s.appBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: f.$3.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(f.$2, color: f.$3, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f.$1, style: text.body(size: 12.5, weight: FontWeight.w700))),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _lecturesTeaser(BuildContext context, IqraSurface s, IqraText text, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: s.appCard2, borderRadius: BorderRadius.circular(18), border: Border.all(color: s.appBorderSoft)),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline, color: IqraTokens.gold, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Public Lectures', style: text.cardTitle(size: 15)),
                const SizedBox(height: 3),
                Text(
                  count > 0
                      ? '$count lectures published — watch free, no account needed.'
                      : 'Recorded lectures from scholars — free to watch, no account needed.',
                  style: text.metaDim(),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HubShell())),
            child: const Text('Watch'),
          ),
        ],
      ),
    );
  }

  Widget _pricingTeaser(BuildContext context, IqraSurface s, IqraText text, List<PricingPlan> plans) {
    final cols = responsiveColumns(MediaQuery.of(context).size.width).clamp(1, 4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FOR TEACHERS & ACADEMIES', style: text.sectionHeader),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: plans.map((p) {
            final usd = p.pricesMinorByCurrency['USD'] ?? 0;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: text.cardTitle(size: 15)),
                  const SizedBox(height: 6),
                  Text(
                    usd == 0 ? (p.tier == 'enterprise' ? 'Custom' : 'Free') : '\$${(usd / 100).toStringAsFixed(0)}/mo',
                    style: const TextStyle(fontFamily: IqraFonts.numeric, fontSize: 18, color: IqraTokens.gold, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ...p.features.take(3).map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          Icon(Icons.check, size: 13, color: IqraTokens.emeraldLt),
                          const SizedBox(width: 6),
                          Expanded(child: Text(f, style: text.metaDim())),
                        ]),
                      )),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _ecosystemLinks(BuildContext context, IqraSurface s, IqraText text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: s.appCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: s.appBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IQRA ECOSYSTEM', style: text.sectionHeader),
          const SizedBox(height: 10),
          Text(
            'studio.iqra.nuerizo.com — for teachers to manage classes and earnings.\n'
            'control.nuerizo.com — internal Nuerizo operator console.',
            style: text.metaDim(),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, IqraSurface s, IqraText text) {
    return Center(
      child: Column(
        children: [
          IqraWordmark(fontSize: 16, color: s.appTextMuted),
          const SizedBox(height: 6),
          Text('© ${DateTime.now().year} Nuerizo · IQRA', style: text.metaDim()),
        ],
      ),
    );
  }
}
