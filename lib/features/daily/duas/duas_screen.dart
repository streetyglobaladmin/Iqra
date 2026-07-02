import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/state/app_state.dart';
import '../../../data/static/duas_content.dart';
import '../../../data/repositories/preferences_repository.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  DuaCategory? _category;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = context.surface;
    final text = IqraText(s);
    final userKey = appState.currentUser?.id ?? 'guest';
    final bookmarks = PreferencesRepository.instance.getBookmarks(userKey);

    final filtered = _category == null
        ? duasContent
        : duasContent.where((d) => d.category == _category).toList();

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Duʿās')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _catChip('All', null),
                ...DuaCategory.values.map((c) => _catChip(_categoryLabel(c), c)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final dua = filtered[i];
                final bookmarkKey = 'dua:${dua.id}';
                final isBookmarked = bookmarks.contains(bookmarkKey);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: s.appCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: s.appBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dua.arabic, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: IqraFonts.arabic, fontSize: 20, height: 1.8, color: IqraTokens.appTextDark)),
                      const SizedBox(height: 8),
                      Text(dua.transliteration,
                          style: const TextStyle(fontFamily: IqraFonts.display, fontStyle: FontStyle.italic, fontSize: 13, color: IqraTokens.appTextDimDark)),
                      const SizedBox(height: 6),
                      Text(dua.translation, style: text.body(size: 12.5)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Text(dua.source, style: text.metaDim())),
                          IconButton(
                            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, size: 18, color: IqraTokens.gold),
                            onPressed: () async {
                              await PreferencesRepository.instance.toggleBookmark(userKey, bookmarkKey);
                              setState(() {});
                            },
                          ),
                          Icon(Icons.volume_up_outlined, size: 18, color: s.appTextMuted),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _catChip(String label, DuaCategory? cat) {
    final selected = _category == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _category = cat),
      ),
    );
  }

  String _categoryLabel(DuaCategory c) {
    switch (c) {
      case DuaCategory.morning:
        return 'Morning';
      case DuaCategory.evening:
        return 'Evening';
      case DuaCategory.travel:
        return 'Travel';
      case DuaCategory.home:
        return 'Home';
      case DuaCategory.distress:
        return 'Distress';
    }
  }
}
