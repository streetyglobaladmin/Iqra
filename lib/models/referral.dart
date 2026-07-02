enum ReferralStatus { pending, rewarded, expired }

class Referral {
  final String id;
  final String referrerUserId;
  final String code;
  final String? inviteeUserId;
  final ReferralStatus status;
  final DateTime createdAt;

  Referral({
    required this.id,
    required this.referrerUserId,
    required this.code,
    this.inviteeUserId,
    this.status = ReferralStatus.pending,
    required this.createdAt,
  });

  Referral copyWith({String? inviteeUserId, ReferralStatus? status}) {
    return Referral(
      id: id,
      referrerUserId: referrerUserId,
      code: code,
      inviteeUserId: inviteeUserId ?? this.inviteeUserId,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'referrerUserId': referrerUserId,
        'code': code,
        'inviteeUserId': inviteeUserId,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Referral.fromMap(Map map) => Referral(
        id: map['id'] as String,
        referrerUserId: map['referrerUserId'] as String,
        code: map['code'] as String,
        inviteeUserId: map['inviteeUserId'] as String?,
        status: ReferralStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => ReferralStatus.pending,
        ),
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
