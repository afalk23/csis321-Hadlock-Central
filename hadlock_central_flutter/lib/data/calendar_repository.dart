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

class CalendarConflictException implements Exception {
  const CalendarConflictException(this.conflictingEntry);

  final CalendarEntry conflictingEntry;

  String get message =>
      '${conflictingEntry.location} is already reserved at that time. '
      'Choose a different time or location.';
}

class CalendarValidationException implements Exception {
  const CalendarValidationException(this.message);

  final String message;
}

class InMemoryCalendarRepository implements CalendarRepository {
  InMemoryCalendarRepository() : _entries = _sampleEntries();

  final List<CalendarEntry> _entries;

  static List<CalendarEntry> _sampleEntries() {
    final today = DateTime.now();
    final weekdayOffset = (DateTime.saturday - today.weekday) % 7;
    // Keep the demo entries in the future even when the app opens on Saturday.
    final daysUntilSaturday = weekdayOffset == 0 ? 7 : weekdayOffset;
    final saturday = DateTime(
      today.year,
      today.month,
      today.day + daysUntilSaturday,
    );
    return [
      CalendarEntry(
        id: 'sample-open-gym',
        title: 'Open gym',
        description: 'Drop in for an open recreation session.',
        location: 'Main gym',
        type: CalendarEntryType.event,
        startsAt: DateTime(saturday.year, saturday.month, saturday.day, 16),
        endsAt: DateTime(saturday.year, saturday.month, saturday.day, 18),
      ),
      CalendarEntry(
        id: 'sample-court-booking',
        title: 'Court 2 reserved',
        description: 'Court unavailable during this time.',
        location: 'Court 2',
        type: CalendarEntryType.booking,
        startsAt: DateTime(saturday.year, saturday.month, saturday.day, 13),
        endsAt: DateTime(saturday.year, saturday.month, saturday.day, 14),
      ),
    ];
  }

  @override
  Future<List<CalendarEntry>> getEntries() async => List.unmodifiable(_entries);

  @override
  Future<void> addEntry(CalendarEntry entry) async {
    if (entry.title.trim().isEmpty || entry.location.trim().isEmpty) {
      throw const CalendarValidationException(
        'Add a title and location before saving.',
      );
    }
    if (!entry.endsAt.isAfter(entry.startsAt)) {
      throw const CalendarValidationException(
        'The end time must be after the start time.',
      );
    }
    if (entry.startsAt.isBefore(DateTime.now())) {
      throw const CalendarValidationException('Choose a future date and time.');
    }

    CalendarEntry? conflict;
    for (final existing in _entries) {
      final sameLocation =
          _normalizeLocation(existing.location) ==
          _normalizeLocation(entry.location);
      final overlaps =
          entry.startsAt.isBefore(existing.endsAt) &&
          existing.startsAt.isBefore(entry.endsAt);
      if (sameLocation && overlaps) {
        conflict = existing;
        break;
      }
    }
    if (conflict != null) {
      throw CalendarConflictException(conflict);
    }
    _entries.add(entry);
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
  }

  String _normalizeLocation(String location) =>
      location.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
