import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/state/app_state.dart';
import '../../../models/lecture.dart';
import '../../../data/repositories/lecture_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';

/// Nuerizo Control Center → Public Lectures manager. Full CRUD (add,
/// edit, publish, hide, delete) over the same [Lecture] records the
/// guest-accessible Public Lectures screen reads — no separate "draft"
/// database, just a status field the admin toggles.
class LecturesAdminPage extends StatefulWidget {
  const LecturesAdminPage({super.key});

  @override
  State<LecturesAdminPage> createState() => _LecturesAdminPageState();
}

class _LecturesAdminPageState extends State<LecturesAdminPage> {
  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final lectures = LectureRepository.instance.getAll();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, null),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Public Lectures', style: text.cardTitle(size: 20)),
          const SizedBox(height: 4),
          Text(
            'Guest-accessible recorded lecture library. Add, edit, publish, hide, or delete below — changes are live immediately.',
            style: text.metaDim(),
          ),
          const SizedBox(height: 16),
          if (lectures.isEmpty)
            const IqraEmptyState(
              icon: Icons.play_circle_outline,
              title: 'No lectures yet',
              subtitle: 'Add your first lecture — it appears on the guest-accessible Public Lectures screen once published.',
            )
          else
            ...lectures.map((l) => _lectureRow(context, l, s, text)),
        ],
      ),
    );
  }

  Widget _lectureRow(BuildContext context, Lecture l, IqraSurface s, IqraText text) {
    Color statusColor;
    switch (l.status) {
      case LecturePublishStatus.published:
        statusColor = IqraTokens.stateSuccess;
        break;
      case LecturePublishStatus.hidden:
        statusColor = IqraTokens.stateWarn;
        break;
      case LecturePublishStatus.draft:
        statusColor = s.appTextMuted;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: s.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: s.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l.title.isEmpty ? '(Untitled lecture)' : l.title,
                    style: text.body(size: 14, weight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(l.status.label,
                    style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w700)),
              ),
              if (l.isPremium) ...[
                const SizedBox(width: 6),
                Icon(Icons.lock_outline, size: 14, color: IqraTokens.gold),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text('${l.scholarName} · ${l.category} · ${l.language}', style: text.metaDim()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditor(context, l),
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
              if (l.status != LecturePublishStatus.published)
                OutlinedButton.icon(
                  onPressed: () => _setStatus(context, l, LecturePublishStatus.published),
                  icon: const Icon(Icons.check_circle_outline, size: 15),
                  label: const Text('Publish'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              if (l.status != LecturePublishStatus.hidden)
                OutlinedButton.icon(
                  onPressed: () => _setStatus(context, l, LecturePublishStatus.hidden),
                  icon: const Icon(Icons.visibility_off_outlined, size: 15),
                  label: const Text('Hide'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, l),
                icon: Icon(Icons.delete_outline, size: 15, color: IqraTokens.stateDanger),
                label: Text('Delete', style: TextStyle(color: IqraTokens.stateDanger)),
                style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setStatus(BuildContext context, Lecture l, LecturePublishStatus status) async {
    final appState = context.read<AppState>();
    await LectureRepository.instance.upsert(l.copyWith(status: status));
    await AuditLogRepository.instance.record(
      actorId: appState.currentUser?.id ?? 'admin',
      actorName: appState.currentUser?.name ?? 'Admin',
      action: 'lecture.${status.name}',
      subjectType: 'lecture',
      subjectId: l.id,
      summary: '${status.label} lecture "${l.title}"',
    );
    if (mounted) setState(() {});
  }

  Future<void> _confirmDelete(BuildContext context, Lecture l) async {
    final appState = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete lecture?'),
        content: Text('"${l.title}" will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: IqraTokens.stateDanger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await LectureRepository.instance.delete(l.id);
    await AuditLogRepository.instance.record(
      actorId: appState.currentUser?.id ?? 'admin',
      actorName: appState.currentUser?.name ?? 'Admin',
      action: 'lecture.delete',
      subjectType: 'lecture',
      subjectId: l.id,
      summary: 'Deleted lecture "${l.title}"',
    );
    if (mounted) setState(() {});
  }

  void _showEditor(BuildContext context, Lecture? lecture) {
    final titleCtrl = TextEditingController(text: lecture?.title ?? '');
    final scholarCtrl = TextEditingController(text: lecture?.scholarName ?? '');
    final categoryCtrl = TextEditingController(text: lecture?.category ?? '');
    final thumbCtrl = TextEditingController(text: lecture?.thumbnailUrl ?? '');
    final descCtrl = TextEditingController(text: lecture?.description ?? '');
    final videoCtrl = TextEditingController(text: lecture?.videoLink ?? '');
    final audioCtrl = TextEditingController(text: lecture?.audioLink ?? '');
    final durationCtrl = TextEditingController(text: lecture?.duration ?? '');
    final languageCtrl = TextEditingController(text: lecture?.language ?? 'Arabic');
    LecturePublishStatus status = lecture?.status ?? LecturePublishStatus.draft;
    bool isPremium = lecture?.isPremium ?? false;
    final appState = context.read<AppState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface.appCard,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(lecture == null ? 'New Lecture' : 'Edit Lecture',
                    style: IqraText(context.surface).cardTitle(size: 16)),
                const SizedBox(height: 14),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 10),
                TextField(controller: scholarCtrl, decoration: const InputDecoration(labelText: 'Scholar / Speaker')),
                const SizedBox(height: 10),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category (e.g. Fiqh, Tafsīr)')),
                const SizedBox(height: 10),
                TextField(controller: thumbCtrl, decoration: const InputDecoration(labelText: 'Thumbnail image URL')),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 10),
                TextField(
                  controller: videoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Video link (YouTube / Facebook / embeddable URL)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(controller: audioCtrl, decoration: const InputDecoration(labelText: 'Audio link (optional)')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Duration (e.g. 42 min)')),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(controller: languageCtrl, decoration: const InputDecoration(labelText: 'Language')),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Publish status', style: IqraText(context.surface).metaDim()),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: LecturePublishStatus.values.map((s2) {
                    return ChoiceChip(
                      label: Text(s2.label),
                      selected: status == s2,
                      onSelected: (_) => setSheetState(() => status = s2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Premium / private (requires login)'),
                  subtitle: const Text('Off by default — public lectures never require login.', style: TextStyle(fontSize: 11)),
                  value: isPremium,
                  onChanged: (v) => setSheetState(() => isPremium = v),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final saved = Lecture(
                      id: lecture?.id ?? const Uuid().v4(),
                      title: titleCtrl.text.trim(),
                      scholarName: scholarCtrl.text.trim(),
                      category: categoryCtrl.text.trim().isEmpty ? 'General' : categoryCtrl.text.trim(),
                      thumbnailUrl: thumbCtrl.text.trim().isEmpty ? null : thumbCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      videoLink: videoCtrl.text.trim().isEmpty ? null : videoCtrl.text.trim(),
                      audioLink: audioCtrl.text.trim().isEmpty ? null : audioCtrl.text.trim(),
                      duration: durationCtrl.text.trim(),
                      language: languageCtrl.text.trim().isEmpty ? 'Arabic' : languageCtrl.text.trim(),
                      status: status,
                      isPremium: isPremium,
                      updatedAt: DateTime.now(),
                    );
                    await LectureRepository.instance.upsert(saved);
                    await AuditLogRepository.instance.record(
                      actorId: appState.currentUser?.id ?? 'admin',
                      actorName: appState.currentUser?.name ?? 'Admin',
                      action: lecture == null ? 'lecture.create' : 'lecture.update',
                      subjectType: 'lecture',
                      subjectId: saved.id,
                      summary: '${lecture == null ? 'Created' : 'Updated'} lecture "${saved.title}"',
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) setState(() {});
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
