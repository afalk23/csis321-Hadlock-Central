enum CalendarEntryType { event, booking }

class CalendarEntry {
  const CalendarEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.startsAt,
    required this.endsAt,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final CalendarEntryType type;
  final DateTime startsAt;
  final DateTime endsAt;

  factory CalendarEntry.fromJson(Map<String, Object?> json) => CalendarEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    location: json['location'] as String,
    type: CalendarEntryType.values.byName(json['type'] as String),
    startsAt: DateTime.parse(json['startsAt'] as String).toLocal(),
    endsAt: DateTime.parse(json['endsAt'] as String).toLocal(),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'location': location,
    'type': type.name,
    'startsAt': startsAt.toUtc().toIso8601String(),
    'endsAt': endsAt.toUtc().toIso8601String(),
  };
}
