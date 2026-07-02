import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/cms_page.dart';
import '../../../data/repositories/cms_repository.dart';

/// Manage Blogs / CMS pages — real create/edit/publish workflow feeding
/// the Public Website surface.
class CmsAdminPage extends StatefulWidget {
  const CmsAdminPage({super.key});

  @override
  State<CmsAdminPage> createState() => _CmsAdminPageState();
}

class _CmsAdminPageState extends State<CmsAdminPage> {
  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final pages = CmsRepository.instance.getAll();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, null),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('CMS / Blog Pages', style: text.cardTitle(size: 20)),
          const SizedBox(height: 12),
          if (pages.isEmpty)
            const IqraEmptyState(
              icon: Icons.article_outlined,
              title: 'No pages yet',
              subtitle: 'Create a blog post or static page — it will appear on the Public Website once published.',
            )
          else
            ...pages.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    tileColor: s.appCard,
                    title: Text(p.title, style: text.body(size: 13.5, weight: FontWeight.w700)),
                    subtitle: Text('${p.status.name} · /${p.slug}', style: text.metaDim()),
                    onTap: () => _showEditor(context, p),
                  ),
                )),
        ],
      ),
    );
  }

  void _showEditor(BuildContext context, CmsPage? page) {
    final titleCtrl = TextEditingController(text: page?.title ?? '');
    final slugCtrl = TextEditingController(text: page?.slug ?? '');
    final bodyCtrl = TextEditingController(text: page?.body ?? '');
    CmsStatus status = page?.status ?? CmsStatus.draft;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface.appCard,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 10),
                TextField(controller: slugCtrl, decoration: const InputDecoration(labelText: 'Slug')),
                const SizedBox(height: 10),
                TextField(controller: bodyCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Body')),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: CmsStatus.values.map((s2) {
                    return ChoiceChip(
                      label: Text(s2.name),
                      selected: status == s2,
                      onSelected: (_) => setSheetState(() => status = s2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final cmsPage = CmsPage(
                      id: page?.id ?? const Uuid().v4(),
                      slug: slugCtrl.text.trim(),
                      title: titleCtrl.text.trim(),
                      body: bodyCtrl.text,
                      status: status,
                      isBlogPost: true,
                      updatedAt: DateTime.now(),
                    );
                    await CmsRepository.instance.upsert(cmsPage);
                    if (ctx.mounted) Navigator.pop(ctx);
                    setState(() {});
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
