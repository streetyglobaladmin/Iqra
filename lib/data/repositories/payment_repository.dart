import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment_record.dart';
import '../local/db.dart';
import '../local/hive_boxes.dart';

/// Simulated payment processing. This is intentionally isolated behind a
/// repository interface identical in shape to what a real PaymentAdapter
/// (Stripe/Razorpay/manual) would expose, so swapping in real gateways
/// later only touches this file — never the UI.
class PaymentRepository {
  static final PaymentRepository instance = PaymentRepository._();
  PaymentRepository._();

  final _uuid = const Uuid();

  Box get _box => Db.box(HiveBoxes.payments);

  List<PaymentRecord> getAll() => _box.values
      .map((e) => PaymentRecord.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<PaymentRecord> getByUser(String userId) =>
      getAll().where((p) => p.userId == userId).toList();

  /// Simulates a payment attempt. Always succeeds after a short delay to
  /// demonstrate the full UI flow (loading -> success/receipt) without a
  /// real gateway. Marked clearly as PaymentGateway.simulatedCard/Upi.
  Future<PaymentRecord> simulateCharge({
    required String userId,
    required String description,
    required int amountMinor,
    required String currency,
    PaymentGateway gateway = PaymentGateway.simulatedCard,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final record = PaymentRecord(
      id: _uuid.v4(),
      userId: userId,
      description: description,
      amountMinor: amountMinor,
      currency: currency,
      gateway: gateway,
      status: PaymentStatus.succeeded,
      createdAt: DateTime.now(),
    );
    await _box.put(record.id, record.toMap());
    return record;
  }
}
