import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/app_role.dart';
import '../../../models/user_account.dart';
import '../../../data/repositories/user_repository.dart';

/// Manage Users / Teachers / Students / Parents from one real roster —
/// filterable by role. Starts at "0 users" — genuinely empty until real
/// accounts register.
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  AppRole? _filter;

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);
    var users = UserRepository.instance.getAll();
    if (_filter != null) {
      users = users.where((u) => u.hasRole(_filter!)).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manage Users', style: text.cardTitle(size: 20)),
              const SizedBox(height: 4),
              Text('${users.length} total · Teachers, Students, Parents, Admins', style: text.metaDim()),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(label: const Text('All'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null)),
                  ...AppRole.values.map((r) => ChoiceChip(
                        label: Text(r.label),
                        selected: _filter == r,
                        onSelected: (_) => setState(() => _filter = r),
                      )),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? const IqraEmptyState(
                  icon: Icons.people_outline,
                  title: '0 users',
                  subtitle: 'No accounts have registered yet. Real accounts created through Sign Up will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => Divider(color: s.appBorderSoft, height: 1),
                  itemBuilder: (context, i) => _userRow(users[i], s, text),
                ),
        ),
      ],
    );
  }

  Widget _userRow(UserAccount u, IqraSurface s, IqraText text) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: IqraTokens.gold.withValues(alpha: 0.2),
        child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?', style: const TextStyle(color: IqraTokens.gold, fontWeight: FontWeight.w700)),
      ),
      title: Text(u.name, style: text.body(size: 13.5, weight: FontWeight.w700)),
      subtitle: Text('${u.email} · ${u.roles.map((r) => r.label).join(", ")}', style: text.metaDim()),
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          if (action == 'suspend') {
            await UserRepository.instance.update(u.copyWith(
              status: u.status == AccountStatus.suspended ? AccountStatus.active : AccountStatus.suspended,
            ));
            setState(() {});
          } else if (action == 'delete') {
            await UserRepository.instance.delete(u.id);
            setState(() {});
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'suspend', child: Text(u.status == AccountStatus.suspended ? 'Reactivate' : 'Suspend')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}
