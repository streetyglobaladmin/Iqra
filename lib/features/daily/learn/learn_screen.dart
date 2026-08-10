import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../services/iqra_api_service.dart';
import '../scholar/scholar_screen.dart';
import 'class_detail_screen.dart';

/// Learn modules screen. Loads published classes from the production API
/// (`/classes`) and keeps the category shortcuts as navigational targets.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  bool _loading = true;
  String? _error;
  List<ApiClass> _classes = [];

  static const _categories = [
    ('Fiqh', Icons.balance_outlined, IqraTokens.emeraldLt),
    ('ʿAqīdah', Icons.auto_awesome_outlined, IqraTokens.lapisLt),
    ('Sīrah', Icons.timeline_outlined, IqraTokens.rubyLt),
    ('Tafsīr', Icons.menu_book_outlined, IqraTokens.saffron),
    ('Arabic', Icons.translate_outlined, IqraTokens.goldLt),
  ];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await IqraApiService.instance.getClasses();
      if (mounted) setState(() => _classes = data);
    } on IqraApiException catch (e) {
      if (mounted) {
        final cached = IqraApiService.instance.getClassesCached();
        setState(() {
          _classes = cached ?? [];
          _error = cached == null ? e.message : null;
        });
      }
    } catch (e) {
      if (mounted) {
        final cached = IqraApiService.instance.getClassesCached();
        setState(() {
          _classes = cached ?? [];
          _error = cached == null ? e.toString() : null;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Learn')),
      body: RefreshIndicator(
        onRefresh: _loadClasses,
        color: IqraTokens.gold,
        backgroundColor: s.appCard,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text('CATEGORIES', style: text.sectionHeader),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: _categories.map((c) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: s.appCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: s.appBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: (c.$3 as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(c.$2 as IconData, color: c.$3 as Color, size: 18),
                      ),
                      const Spacer(),
                      Text(c.$1 as String, style: text.body(size: 13.5, weight: FontWeight.w700)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('FEATURED CLASSES', style: text.sectionHeader),
                const Spacer(),
                if (_loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null && _classes.isEmpty)
              Container(
                decoration: BoxDecoration(
                  color: s.appCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: s.appBorder),
                ),
                child: IqraEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Unable to load classes',
                  subtitle: _error!,
                ),
              )
            else if (_classes.isEmpty && !_loading)
              Container(
                decoration: BoxDecoration(
                  color: s.appCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: s.appBorder),
                ),
                child: IqraEmptyState(
                  icon: Icons.auto_stories_outlined,
                  title: 'No learning modules yet',
                  subtitle: 'Teachers publish structured lessons through IQRA Studio. Once published, they will appear here.',
                  action: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScholarScreen()),
                    ),
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Find a scholar'),
                  ),
                ),
              )
            else
              ..._classes.map((c) => _classCard(context, c, s, text)),
          ],
        ),
      ),
    );
  }

  Widget _classCard(BuildContext context, ApiClass c, IqraSurface s, IqraText text) {
    final priceLabel = c.isFree
        ? 'Free'
        : '${(c.priceCents / 100).toStringAsFixed(2)} ${c.currency}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: s.appCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.appBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ClassDetailScreen(classId: c.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: IqraTokens.emeraldLt.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_outlined, color: IqraTokens.emeraldLt),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title, style: text.body(size: 13.5, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '${c.scholarName ?? 'IQRA Scholar'} · ${c.level ?? 'beginner'}',
                      style: text.metaDim(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.scheduleText ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.metaDim(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.isFree
                      ? IqraTokens.stateSuccess.withValues(alpha: 0.15)
                      : IqraTokens.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  priceLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: c.isFree ? IqraTokens.stateSuccess : IqraTokens.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
