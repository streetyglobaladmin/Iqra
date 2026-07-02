import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/iqra_logo.dart';
import '../../core/state/app_state.dart';
import '../../models/app_role.dart';
import '../../models/student_profile.dart';
import '../../models/teacher_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../data/repositories/referral_repository.dart';
import 'package:uuid/uuid.dart';
import '../hub/hub_shell.dart';

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
      final referred = _referralCtrl.text.trim().isEmpty ? null : _referralCtrl.text.trim();
      final user = await UserRepository.instance.register(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        name: _nameCtrl.text,
        roles: [_selectedRole],
        referredByCode: referred,
      );

      // Create the corresponding domain profile so the role's dashboard
      // has real backing data from the very first login.
      if (_selectedRole == AppRole.student) {
        await StudentRepository.instance.upsert(StudentProfile(
          id: const Uuid().v4(),
          userId: user.id,
          name: user.name,
        ));
      } else if (_selectedRole == AppRole.teacher) {
        await TeacherRepository.instance.upsert(TeacherProfile(
          id: const Uuid().v4(),
          userId: user.id,
          name: user.name,
          createdAt: DateTime.now(),
        ));
      }

      if (referred != null) {
        // Look up the referrer by code among existing users.
        final all = UserRepository.instance.getAll();
        final referrer = all.where((u) => u.referralCode == referred).toList();
        if (referrer.isNotEmpty) {
          await ReferralRepository.instance.recordSignupWithCode(
            code: referred,
            inviteeUserId: user.id,
            referrerUserId: referrer.first.id,
          );
        }
      }

      if (!mounted) return;
      await context.read<AppState>().login(user);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HubShell()),
        (route) => false,
      );
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppRole.student,
                    AppRole.parent,
                    AppRole.teacher,
                  ].map((role) {
                    final selected = _selectedRole == role;
                    return ChoiceChip(
                      label: Text(role.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedRole = role),
                      selectedColor: IqraTokens.gold.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: selected ? IqraTokens.gold : IqraTokens.appTextDimDark,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: IqraTokens.appCardDark,
                      side: BorderSide(
                        color: selected ? IqraTokens.gold : IqraTokens.appBorderDark,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _label('Full name'),
                TextFormField(
                  controller: _nameCtrl,
                  style: TextStyle(color: IqraTokens.appTextDark),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
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
                    if (v == null || v.length < 6) return 'At least 6 characters';
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
                    child: Text(_error!,
                        style: TextStyle(color: IqraTokens.stateDanger.withValues(alpha: 0.95), fontSize: 12.5)),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: IqraTokens.ink),
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
