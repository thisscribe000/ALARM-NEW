class Alarm {
  final String id; // unique string
  final int hour; // 0-23
  final int minute; // 0-59
  final String label;
  final bool enabled;

  const Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    required this.label,
    required this.enabled,
  });

  Alarm copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    bool? enabled,
  }) {
    return Alarm(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
    );
  }

  String timeText({bool use24h = true}) {
    final mm = minute.toString().padLeft(2, '0');

    if (use24h) {
      final hh = hour.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    final isPm = hour >= 12;
    var hh = hour % 12;
    if (hh == 0) hh = 12;
    final suffix = isPm ? 'PM' : 'AM';
    return '$hh:$mm $suffix';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'label': label,
        'enabled': enabled,
      };

  static Alarm fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: (json['id'] ?? '') as String,
      hour: (json['hour'] ?? 0) as int,
      minute: (json['minute'] ?? 0) as int,
      label: (json['label'] ?? '') as String,
      enabled: (json['enabled'] ?? false) as bool,
    );
  }
}
