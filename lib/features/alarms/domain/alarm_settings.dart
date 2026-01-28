enum DismissMethod {
  normal,
  ticTacToe,
}

class AlarmSettings {
  /// null => unlimited
  final int? snoozeLimit;

  final DismissMethod dismissMethod;

  const AlarmSettings({
    required this.snoozeLimit,
    required this.dismissMethod,
  });

  static const defaultValue = AlarmSettings(
    snoozeLimit: 5,
    dismissMethod: DismissMethod.normal,
  );

  AlarmSettings copyWith({
    int? snoozeLimit,
    bool snoozeLimitToNull = false,
    DismissMethod? dismissMethod,
  }) {
    return AlarmSettings(
      snoozeLimit: snoozeLimitToNull ? null : (snoozeLimit ?? this.snoozeLimit),
      dismissMethod: dismissMethod ?? this.dismissMethod,
    );
  }

  Map<String, dynamic> toJson() => {
        'snoozeLimit': snoozeLimit,
        'dismissMethod': dismissMethod.name,
      };

  static AlarmSettings fromJson(Map<String, dynamic> json) {
    final rawMethod = (json['dismissMethod'] ?? 'normal') as String;
    final method = DismissMethod.values
        .where((e) => e.name == rawMethod)
        .cast<DismissMethod?>()
        .firstWhere((e) => e != null, orElse: () => DismissMethod.normal)!;

    final limit = json['snoozeLimit'];
    return AlarmSettings(
      snoozeLimit: limit is int ? limit : null,
      dismissMethod: method,
    );
  }
}
