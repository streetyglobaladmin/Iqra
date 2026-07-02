/// A simulated payment record. This models the shape a real Stripe/
/// Razorpay/manual-payment integration would produce, so the UI and data
/// layer do not need to change when a real [PaymentAdapter] is wired in.
enum PaymentGateway { simulatedCard, simulatedUpi, manual, stripe, razorpay }

enum PaymentStatus { pending, succeeded, failed, refunded }

class PaymentRecord {
  final String id;
  final String userId;
  final String description;
  final int amountMinor;
  final String currency;
  final PaymentGateway gateway;
  final PaymentStatus status;
  final DateTime createdAt;

  PaymentRecord({
    required this.id,
    required this.userId,
    required this.description,
    required this.amountMinor,
    required this.currency,
    required this.gateway,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'description': description,
        'amountMinor': amountMinor,
        'currency': currency,
        'gateway': gateway.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PaymentRecord.fromMap(Map map) => PaymentRecord(
        id: map['id'] as String,
        userId: map['userId'] as String,
        description: map['description'] as String,
        amountMinor: map['amountMinor'] as int,
        currency: map['currency'] as String,
        gateway: PaymentGateway.values.firstWhere(
          (g) => g.name == map['gateway'],
          orElse: () => PaymentGateway.simulatedCard,
        ),
        status: PaymentStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => PaymentStatus.pending,
        ),
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
