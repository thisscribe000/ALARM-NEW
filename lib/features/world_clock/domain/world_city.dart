class WorldCity {
  final String id; // stable unique id
  final String name; // e.g. Lagos
  final String country; // e.g. Nigeria
  final int utcOffsetMinutes; // e.g. +60 for UTC+1
  final bool is24h;

  const WorldCity({
    required this.id,
    required this.name,
    required this.country,
    required this.utcOffsetMinutes,
    this.is24h = true,
  });

  String get displayName => '$name, $country';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
        'utcOffsetMinutes': utcOffsetMinutes,
        'is24h': is24h,
      };

  static WorldCity fromJson(Map<String, dynamic> json) {
    return WorldCity(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      country: (json['country'] ?? '') as String,
      utcOffsetMinutes: (json['utcOffsetMinutes'] ?? 0) as int,
      is24h: (json['is24h'] ?? true) as bool,
    );
  }
}
