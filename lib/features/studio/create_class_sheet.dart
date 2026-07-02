import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/class_model.dart';
import '../../data/repositories/class_repository.dart';

class CreateClassSheet extends StatefulWidget {
  final String teacherId;
  final VoidCallback onCreated;
  const CreateClassSheet({super.key, required this.teacherId, required this.onCreated});

  @override
  State<CreateClassSheet> createState() => _CreateClassSheetState();
}

class _CreateClassSheetState extends State<CreateClassSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0');
  String _level = 'beginner';
  LiveClassProvider _provider = LiveClassProvider.zoom;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _scheduleCtrl.dispose();
    _linkCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = ClassSession(
      id: const Uuid().v4(),
      teacherId: widget.teacherId,
      title: _titleCtrl.text.trim(),
      level: _level,
      scheduleSummary: _scheduleCtrl.text.trim(),
      provider: _provider,
      meetingLink: _linkCtrl.text.trim().isEmpty ? null : _linkCtrl.text.trim(),
      priceAmountMinor: ((double.tryParse(_priceCtrl.text) ?? 0) * 100).round(),
      createdAt: DateTime.now(),
    );
    await ClassRepository.instance.upsert(session);
    widget.onCreated();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create a class', style: TextStyle(fontFamily: IqraFonts.display, fontSize: 20, fontWeight: FontWeight.w600, color: s.appText)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                style: TextStyle(color: s.appText),
                decoration: const InputDecoration(labelText: 'Class title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _scheduleCtrl,
                style: TextStyle(color: s.appText),
                decoration: const InputDecoration(labelText: 'Schedule (e.g. Mon/Wed 6:00 PM)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _level,
                dropdownColor: s.appCard,
                style: TextStyle(color: s.appText),
                decoration: const InputDecoration(labelText: 'Level'),
                items: ['beginner', 'intermediate', 'advanced']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setState(() => _level = v ?? 'beginner'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LiveClassProvider>(
                initialValue: _provider,
                dropdownColor: s.appCard,
                style: TextStyle(color: s.appText),
                decoration: const InputDecoration(labelText: 'Live class provider'),
                items: const [
                  DropdownMenuItem(value: LiveClassProvider.zoom, child: Text('Zoom')),
                  DropdownMenuItem(value: LiveClassProvider.googleMeet, child: Text('Google Meet')),
                ],
                onChanged: (v) => setState(() => _provider = v ?? LiveClassProvider.zoom),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _linkCtrl,
                style: TextStyle(color: s.appText),
                decoration: const InputDecoration(labelText: 'Meeting link (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: s.appText),
                decoration: const InputDecoration(labelText: 'Monthly price (USD, 0 = free)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Create class')),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
