import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/iqra_logo.dart';
import '../../core/state/app_state.dart';
import '../../models/app_role.dart';
import '../../models/student_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/student_repository.dart';
import 'package:uuid/uuid.dart';
import '../../services/iqra_api_service.dart';

/// Student / Parent signup — the only self-serve account creation flow
/// exposed inside the mobile app. Teachers/scholars do NOT sign up here;
/// they go through the "Apply as Scholar" flow inside IQRA Studio
/// (see features/studio/studio_preview_screen.dart), which is a
/// separate, vetted onboarding path. Admin/Super Admin accounts are never
/// created from the mobile app at all.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  AppRole _selectedRole = AppRole.student;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final referred = _referralCtrl.text.trim().isEmpty
          ? null
          : _referralCtrl.text.trim();

      // The production backend currently supports student self-registration.
      // The role selector is preserved in the UI; the API call always
      // registers the account as a student.
      final user = await UserRepository.instance.register(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        name: _nameCtrl.text,
        roles: [_selectedRole],
        referredByCode: referred,
      );

      // Create a lightweight local student profile so the Student dashboard
      // has backing data from the first login.
      if (_selectedRole == AppRole.student) {
        await StudentRepository.instance.upsert(
          StudentProfile(
            id: const Uuid().v4(),
            userId: user.id,
            name: user.name,
          ),
        );
      }

      if (!mounted) return;
      await context.read<AppState>().login(user);
      if (!mounted) return;
      // Simply pop back to whatever screen pushed this Signup screen —
      // see the matching note in login_screen.dart.
      Navigator.of(context).pop();
    } on IqraApiException catch (e) {
      setState(() => _error = e.message);
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
      appBar: AppBar(backgroundColor: Colors.transparent),
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
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: IqraFonts.display,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: IqraTokens.appTextDark,
                  ),
                ),
                const SizedBox(height: 24),
                _label('I am a...'),
                Text(
                  'Teachers/scholars: use "Apply as Scholar" inside IQRA Studio instead.',
                  style: TextStyle(
                    fontFamily: IqraFonts.sans,
                    fontSize: 11,
                    color: IqraTokens.appTextMutedDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        // Mobile app self-serve signup is Student/Parent only.
                        // Scholar accounts are created via the vetted
                        // "Apply as Scholar" flow inside IQRA Studio, and
                        // Admin/Super Admin accounts are never created here.
                        AppRole.student,
                        AppRole.parent,
                      ].map((role) {
                        final selected = _selectedRole == role;
                        return ChoiceChip(
                          label: Text(role.label),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedRole = role),
                          selectedColor: IqraTokens.gold.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: selected
                                ? IqraTokens.gold
                                : IqraTokens.appTextDimDark,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: IqraTokens.appCardDark,
                          side: BorderSide(
                            color: selected
                                ? IqraTokens.gold
                                : IqraTokens.appBorderDark,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
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
                _label('Referral code (optional)'),
                TextFormField(
                  controller: _referralCtrl,
                  style: TextStyle(color: IqraTokens.appTextDark),
                  decoration: const InputDecoration(hintText: 'IQRA-XXXXXXXX'),
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
                      : const Text('Create Account'),
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
