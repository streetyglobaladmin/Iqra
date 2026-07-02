import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/cms_page.dart';
import '../../../data/repositories/cms_repository.dart';

/// Public articles/blog reader — guest-accessible per the guest-first
/// requirement. Reads real published posts authored through the Nuerizo
/// Control Center CMS; starts empty ("No articles yet") until the admin
/// actually publishes something, per the no-fake-data requirement.
class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    final posts = CmsRepository.instance.getBlogPosts();

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Articles & Blog')),
      body: posts.isEmpty
          ? Center(
              child: IqraEmptyState(
                icon: Icons.article_outlined,
                title: 'No articles yet',
                subtitle: 'Published posts from the Nuerizo Control Center CMS will appear here.',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _articleCard(context, posts[i], s, text),
            ),
    );
  }

  Widget _articleCard(BuildContext context, CmsPage post, IqraSurface s, IqraText text) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ArticleDetailScreen(post: post)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: s.appCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: s.appBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: text.cardTitle(size: 15)),
            const SizedBox(height: 6),
            Text(
              post.body.length > 140 ? '${post.body.substring(0, 140)}…' : post.body,
              style: text.bodyDim(size: 12.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (post.tags.isNotEmpty)
                  ...post.tags.take(2).map((t) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: IqraTokens.emeraldLt.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(t, style: const TextStyle(fontSize: 10, color: IqraTokens.emeraldLt, fontWeight: FontWeight.w700)),
                      )),
                const Spacer(),
                Text(post.updatedAt.toString().split(' ').first, style: text.metaDim()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final CmsPage post;
  const ArticleDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: Text(post.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(post.title, style: text.displayHeadline(size: 22)),
          const SizedBox(height: 6),
          Text(post.updatedAt.toString().split(' ').first, style: text.metaDim()),
          const SizedBox(height: 16),
          Text(post.body, style: text.body(size: 14.5, weight: FontWeight.w400)),
        ],
      ),
    );
  }
}
