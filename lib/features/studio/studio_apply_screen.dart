import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/iqra_logo.dart';
import '../../core/state/app_state.dart';
import '../../models/app_role.dart';
import '../../models/teacher_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import 'studio_shell.dart';

/// "Apply as Scholar" — the vetted registration flow for teachers, kept
/// separate from the mobile app's regular Student/Parent signup screen.
/// Creates an account with the Teacher/Scholar role plus a starter
/// [TeacherProfile], then opens IQRA Studio directly.
class StudioApplyScreen extends StatefulWidget {
  const StudioApplyScreen({super.key});

  @override
  State<StudioApplyScreen> createState() => _StudioApplyScreenState();
}

class _StudioApplyScreenState extends State<StudioApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await UserRepository.instance.register(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        name: _nameCtrl.text,
        roles: [AppRole.teacher],
      );

      await TeacherRepository.instance.upsert(
        TeacherProfile(
          id: const Uuid().v4(),
          userId: user.id,
          name: user.name,
          bio: _bioCtrl.text.trim(),
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;
      await context.read<AppState>().login(user);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const StudioShell()));
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IqraTokens.emeraldDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Apply as Scholar'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: IqraLogoMark(size: 60)),
                const SizedBox(height: 16),
                Text(
                  'Register as a Scholar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: IqraFonts.display,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: IqraTokens.appTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create your IQRA Studio teacher account to start teaching online.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: IqraFonts.sans,
                    fontSize: 12.5,
                    color: IqraTokens.appTextDimDark,
                  ),
                ),
                const SizedBox(height: 24),
                _label('Full name'),
                TextFormField(
                  controller: _nameCtrl,
                  style: TextStyle(color: IqraTokens.appTextDark),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _label('Email'),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: IqraTokens.appTextDark),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Password'),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: TextStyle(color: IqraTokens.appTextDark),
                  validator: (v) {
                    if (v == null || v.length < 6)
                      return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Short bio / specialties (optional)'),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  style: TextStyle(color: IqraTokens.appTextDark),
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. Tajwīd, Ḥifẓ, Fiqh — 8 years teaching experience',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: IqraTokens.stateDanger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: IqraTokens.stateDanger.withValues(alpha: 0.95),
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: IqraTokens.ink,
                          ),
                        )
                      : const Text('Submit Application'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: IqraFonts.sans,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: IqraTokens.appTextDimDark,
      ),
    ),
  );
}
