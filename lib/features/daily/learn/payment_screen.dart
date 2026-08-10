import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../services/iqra_api_service.dart';

/// Manual UPI payment submission for paid classes / subscriptions.
/// Loads `/payments/settings` and posts the UTR to `/payments/submit`.
class PaymentScreen extends StatefulWidget {
  final int? classId;
  final int? subscriptionId;

  const PaymentScreen({
    super.key,
    this.classId,
    this.subscriptionId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = true;
  String? _error;
  ApiPaymentSettings? _settings;

  final _utrCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _submitting = false;
  String? _submitMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _utrCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await IqraApiService.instance.getPaymentSettings(
        classId: widget.classId,
        subscriptionId: widget.subscriptionId,
      );
      if (mounted) setState(() => _settings = data);
    } on IqraApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final utr = _utrCtrl.text.trim();
    if (utr.isEmpty) {
      setState(() => _submitMessage = 'Please enter the UTR reference number.');
      return;
    }
    final amount = _settings?.amountCents ?? 0;
    if (amount <= 0) {
      setState(() => _submitMessage = 'No amount due for this item.');
      return;
    }

    setState(() {
      _submitting = true;
      _submitMessage = null;
    });
    try {
      final result = await IqraApiService.instance.submitPayment(
        classId: widget.classId,
        subscriptionId: widget.subscriptionId,
        amountCents: amount,
        utr: utr,
        payerNotes: _notesCtrl.text.trim(),
        currency: _settings?.currency ?? 'INR',
      );
      if (mounted) setState(() => _submitMessage = result.message);
    } on IqraApiException catch (e) {
      if (mounted) setState(() => _submitMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _submitMessage = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final text = IqraText(s);

    return Scaffold(
      backgroundColor: s.appBg,
      appBar: AppBar(title: const Text('Payment')),
      body: RefreshIndicator(
        onRefresh: _loadSettings,
        color: IqraTokens.gold,
        backgroundColor: s.appCard,
        child: _buildBody(context, s, text),
      ),
    );
  }

  Widget _buildBody(BuildContext context, IqraSurface s, IqraText text) {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 240),
          Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: IqraEmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load payment settings',
              subtitle: _error!,
            ),
          ),
        ],
      );
    }

    final settings = _settings!;
    final amountDue = settings.amountCents != null
        ? '${(settings.amountCents! / 100).toStringAsFixed(2)} ${settings.currency}'
        : 'Contact support';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: s.appCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: s.appBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount due', style: text.metaDim()),
              const SizedBox(height: 4),
              Text(amountDue,
                  style: const TextStyle(fontFamily: IqraFonts.numeric, fontSize: 32, fontWeight: FontWeight.w600, color: IqraTokens.gold)),
              const SizedBox(height: 16),
              if (settings.upiId != null) ...[
                Text('UPI ID', style: text.metaDim()),
                const SizedBox(height: 4),
                Text(settings.upiId!, style: text.body(size: 14, weight: FontWeight.w700)),
              ],
              if (settings.upiPayeeName != null) ...[
                const SizedBox(height: 8),
                Text('Payee', style: text.metaDim()),
                const SizedBox(height: 4),
                Text(settings.upiPayeeName!, style: text.body(size: 13)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (settings.upiQrUrl != null && settings.upiQrUrl!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: s.appCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: s.appBorder),
            ),
            child: Column(
              children: [
                Text('Scan to pay', style: text.body(size: 13, weight: FontWeight.w700)),
                const SizedBox(height: 12),
                Image.network(
                  settings.upiQrUrl!,
                  height: 180,
                  errorBuilder: (_, __, ___) => Icon(Icons.qr_code_2, size: 80, color: s.appTextMuted),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text('SUBMIT PAYMENT', style: text.sectionHeader),
        const SizedBox(height: 12),
        TextFormField(
          controller: _utrCtrl,
          style: TextStyle(color: s.appText),
          decoration: const InputDecoration(
            labelText: 'UPI Transaction Reference (UTR)',
            hintText: 'e.g. 123456789012',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesCtrl,
          style: TextStyle(color: s.appText),
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            hintText: 'Payment date, account used, etc.',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: IqraTokens.ink),
                  )
                : const Text('Submit UTR'),
          ),
        ),
        if (_submitMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _submitMessage!.contains('submitted') || _submitMessage!.contains('pending')
                  ? IqraTokens.stateSuccess.withValues(alpha: 0.12)
                  : IqraTokens.stateWarn.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _submitMessage!,
              style: TextStyle(
                color: _submitMessage!.contains('submitted') || _submitMessage!.contains('pending')
                    ? IqraTokens.stateSuccess
                    : IqraTokens.stateWarn,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
        if (settings.upiInstructions != null) ...[
          const SizedBox(height: 24),
          Text('INSTRUCTIONS', style: text.sectionHeader),
          const SizedBox(height: 8),
          Text(settings.upiInstructions!, style: text.body(size: 13)),
        ],
        if (settings.supportWhatsapp != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              final uri = Uri.tryParse('https://wa.me/${settings.supportWhatsapp}');
              if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.support_agent, size: 18),
            label: const Text('Get help on WhatsApp'),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
