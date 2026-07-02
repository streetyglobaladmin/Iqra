import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/repositories/teacher_repository.dart';

/// Scholar / teacher directory. Loads real [TeacherProfile] records —
/// starts empty until teachers actually register through Studio
/// onboarding, per the no-fake-data requirement.
class ScholarScreen extends StatefulWidget {
  const ScholarScreen({super.key});

  @override
  State<ScholarScreen> createState() => _ScholarScreenState();
}

class _ScholarScreenState extends State<ScholarScreen> {
  String _query = '';
  String? _filterTag;

  static const _filters = ['Fiqh', 'ʿAqīdah', 'Tafsīr', 'Arabic'];

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    var teachers = TeacherRepository.instance.getAll();
    if (_query.isNotEmpty) {
      teachers = teachers.where((t) => t.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    if (_filterTag != null) {
      teachers = teachers.where((t) => t.specialties.contains(_filterTag)).toList();
    }

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Scholars')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: s.appText),
              decoration: const InputDecoration(hintText: 'Search scholars...', prefixIcon: Icon(Icons.search)),
            ),
          ),
          SizedBox(
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
          const SizedBox(height: 8),
          Expanded(
            child: teachers.isEmpty
                ? Center(
                    child: IqraEmptyState(
                      icon: Icons.school_outlined,
                      title: 'No scholars yet',
                      subtitle: 'Teachers who complete their Studio profile will appear here. Waiting for first activity.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: teachers.length,
                    separatorBuilder: (_, __) => Divider(color: s.appBorderSoft, height: 1),
                    itemBuilder: (context, i) {
                      final t = teachers[i];
                      return ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: IqraTokens.jewelForIndex(i),
                              child: Text(t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                            if (t.online)
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
