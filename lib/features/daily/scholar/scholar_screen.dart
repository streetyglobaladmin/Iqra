import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../services/iqra_api_service.dart';
import '../../../data/repositories/teacher_repository.dart';

/// Scholar / teacher directory. Loads from the production API (`/scholars`)
/// and falls back to locally cached or Studio-created teacher records when
/// offline, per the no-fake-data requirement.
class ScholarScreen extends StatefulWidget {
  const ScholarScreen({super.key});

  @override
  State<ScholarScreen> createState() => _ScholarScreenState();
}

class _ScholarScreenState extends State<ScholarScreen> {
  String _query = '';
  String? _filterTag;
  bool _loading = true;
  String? _error;
  List<ApiScholar> _scholars = [];

  static const _filters = ['Fiqh', 'ʿAqīdah', 'Tafsīr', 'Arabic'];

  @override
  void initState() {
    super.initState();
    _loadScholars();
  }

  Future<void> _loadScholars() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await IqraApiService.instance.getScholars(
        query: _query.isEmpty ? null : _query,
      );
      if (mounted) setState(() => _scholars = data);
    } on IqraApiException catch (e) {
      if (mounted) {
        final cached = IqraApiService.instance.getScholarsCached();
        setState(() {
          _scholars = cached ?? [];
          _error = cached == null ? e.message : null;
        });
      }
    } catch (e) {
      if (mounted) {
        final cached = IqraApiService.instance.getScholarsCached();
        setState(() {
          _scholars = cached ?? [];
          _error = cached == null ? e.toString() : null;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ApiScholar> get _filteredScholars {
    var list = _scholars;
    if (_query.isNotEmpty) {
      list = list
          .where((t) => t.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    if (_filterTag != null) {
      list = list
          .where((t) => t.specialties.any((s) => s.toLowerCase() == _filterTag!.toLowerCase()))
          .toList();
    }
    // Merge in local teachers as a fallback when the API list is empty.
    if (list.isEmpty && _scholars.isEmpty) {
      final local = TeacherRepository.instance.getAll();
      return local.map((t) {
        return ApiScholar(
          id: int.tryParse(t.id) ?? 0,
          slug: '',
          name: t.name,
          bio: t.bio,
          specialties: t.specialties,
          verified: t.verified,
        );
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final teachers = _filteredScholars;

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Scholars')),
      body: RefreshIndicator(
        onRefresh: _loadScholars,
        color: IqraTokens.gold,
        backgroundColor: s.appCard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  onChanged: (v) {
                    setState(() => _query = v);
                    _loadScholars();
                  },
                  style: TextStyle(color: s.appText),
                  decoration: const InputDecoration(hintText: 'Search scholars...', prefixIcon: Icon(Icons.search)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _filters.map((f) {
                    final selected = _filterTag == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: selected,
                        onSelected: (_) => setState(() => _filterTag = selected ? null : f),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            if (_loading && teachers.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_error != null && teachers.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: IqraEmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Unable to load scholars',
                    subtitle: _error!,
                  ),
                ),
              )
            else if (teachers.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: IqraEmptyState(
                    icon: Icons.school_outlined,
                    title: 'No scholars yet',
                    subtitle: 'Teachers who complete their Studio profile will appear here. Waiting for first activity.',
                  ),
                ),
              )
            else
              SliverList.separated(
                itemCount: teachers.length,
                separatorBuilder: (_, __) => Divider(color: s.appBorderSoft, height: 1),
                itemBuilder: (context, i) {
                  final t = teachers[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: IqraTokens.jewelForIndex(i),
                            child: Text(t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                          if (t.verified)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: IqraTokens.stateSuccess,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: s.appBg, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(t.name, style: text.body(size: 14, weight: FontWeight.w700)),
                      subtitle: Text(
                        t.specialties.isEmpty ? 'No specialties listed' : t.specialties.join(' · '),
                        style: text.metaDim(),
                      ),
                      trailing: Icon(Icons.chevron_right, color: s.appTextMuted),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
