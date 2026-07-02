class TasbihState {
  final int current;
  final int target;
  final String dhikr;
  final int sessionsToday;
  final Map<String, int> dhikrCounts;
  final DateTime? lastResetDate;

  TasbihState({
    this.current = 0,
    this.target = 33,
    this.dhikr = 'SubḥānAllāh',
    this.sessionsToday = 0,
    this.dhikrCounts = const {
      'SubḥānAllāh': 0,
      'Alḥamdulillāh': 0,
      'Allāhu Akbar': 0,
    },
    this.lastResetDate,
  });

  TasbihState copyWith({
    int? current,
    int? target,
    String? dhikr,
    int? sessionsToday,
    Map<String, int>? dhikrCounts,
    DateTime? lastResetDate,
  }) {
    return TasbihState(
      current: current ?? this.current,
      target: target ?? this.target,
      dhikr: dhikr ?? this.dhikr,
      sessionsToday: sessionsToday ?? this.sessionsToday,
      dhikrCounts: dhikrCounts ?? this.dhikrCounts,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'current': current,
        'target': target,
        'dhikr': dhikr,
        'sessionsToday': sessionsToday,
        'dhikrCounts': dhikrCounts,
        'lastResetDate': lastResetDate?.toIso8601String(),
      };

  factory TasbihState.fromMap(Map map) => TasbihState(
        current: map['current'] as int? ?? 0,
        target: map['target'] as int? ?? 33,
        dhikr: map['dhikr'] as String? ?? 'SubḥānAllāh',
        sessionsToday: map['sessionsToday'] as int? ?? 0,
        dhikrCounts: Map<String, int>.from(map['dhikrCounts'] as Map? ??
            {'SubḥānAllāh': 0, 'Alḥamdulillāh': 0, 'Allāhu Akbar': 0}),
        lastResetDate: map['lastResetDate'] != null
            ? DateTime.tryParse(map['lastResetDate'] as String)
            : null,
      );
}
