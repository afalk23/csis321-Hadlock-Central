import '../models/calendar_entry.dart';

/// Storage boundary for shared events and facility bookings.
///
/// Replace the demo implementation with an authenticated API repository for
/// durable, cross-device storage. The API must authorize deletes as staff;
/// hiding the button in the Flutter UI is not an authorization check.
abstract interface class CalendarRepository {
  Future<List<CalendarEntry>> getEntries();

  Future<void> addEntry(CalendarEntry entry);

  /// The production API must reject callers without staff permission.
  Future<void> deleteEntry(String id);
}

class InMemoryCalendarRepository implements CalendarRepository {
  InMemoryCalendarRepository() : _entries = _sampleEntries();

  final List<CalendarEntry> _entries;

  static List<CalendarEntry> _sampleEntries() {
    final today = DateTime.now();
    final daysUntilSaturday = (DateTime.saturday - today.weekday) % 7;
    final saturday = DateTime(
      today.year,
      today.month,
      today.day + daysUntilSaturday,
    );
    final futureSaturday = saturday.day < today.day
        ? saturday.add(const Duration(days: 7))
        : saturday;

    return [
      CalendarEntry(
        id: 'sample-open-gym',
        title: 'Open gym',
        description: 'Drop in for an open recreation session.',
        location: 'Main gym',
        type: CalendarEntryType.event,
        startsAt: DateTime(
          futureSaturday.year,
          futureSaturday.month,
          futureSaturday.day,
          16,
        ),
        endsAt: DateTime(
          futureSaturday.year,
          futureSaturday.month,
          futureSaturday.day,
          18,
        ),
      ),
      CalendarEntry(
        id: 'sample-court-booking',
        title: 'Court 2 reserved',
        description: 'Court unavailable during this time.',
        location: 'Court 2',
        type: CalendarEntryType.booking,
        startsAt: DateTime(
          futureSaturday.year,
          futureSaturday.month,
          futureSaturday.day,
          13,
        ),
        endsAt: DateTime(
          futureSaturday.year,
          futureSaturday.month,
          futureSaturday.day,
          14,
        ),
      ),
    ];
  }

  @override
  Future<List<CalendarEntry>> getEntries() async => List.unmodifiable(_entries);

  @override
  Future<void> addEntry(CalendarEntry entry) async {
    final hasConflict = _entries.any((existing) {
      final sameLocation =
          existing.location.trim().toLowerCase() ==
          entry.location.trim().toLowerCase();
      final overlaps =
          entry.startsAt.isBefore(existing.endsAt) &&
          existing.startsAt.isBefore(entry.endsAt);
      return sameLocation && overlaps;
    });
    if (hasConflict) {
      throw StateError(
        'That location already has an event or booking at this time.',
      );
    }
    _entries.add(entry);
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
  }
}
