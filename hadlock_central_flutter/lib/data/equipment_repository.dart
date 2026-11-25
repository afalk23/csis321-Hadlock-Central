import '../models/equipment_item.dart';
import '../models/equipment_cart_entry.dart';
import '../models/equipment_reservation.dart';

/// Catalog data boundary for a future inventory API implementation.
abstract class EquipmentRepository {
  Future<List<EquipmentItem>> getItems();

  Future<int> availableCount(
    String itemId,
    DateTime start,
    DateTime end, {
    List<EquipmentCartEntry> cart = const [],
  });
  Future<EquipmentReservation> reserve({
    required EquipmentItem item,
    required String accountId,
    required String studentId,
    required DateTime start,
    required DateTime end,
  });
  Future<List<EquipmentReservation>> reserveCart({
    required List<EquipmentCartEntry> entries,
    required String accountId,
    required String studentId,
  });
  Future<List<EquipmentReservation>> reservationsFor(String accountId);

  /// Staff preview operations; a production API must authorize these calls.
  Future<List<EquipmentReservation>> getAllReservations();
  Future<List<EquipmentCancellation>> getCancellations();
  Future<void> completeReservation(
    String reservationId, {
    required bool returned,
  });
  Future<void> cancelReservation(
    String reservationId, {
    required bool userContacted,
    required bool bossApproved,
    required String reason,
  });
  Future<void> updateQuantity(String itemId, int quantity);
}

class EquipmentUnavailableException implements Exception {
  const EquipmentUnavailableException(this.message);
  final String message;
}

class EquipmentReservationException implements Exception {
  const EquipmentReservationException(this.message);
  final String message;
}

class EquipmentInventoryException implements Exception {
  const EquipmentInventoryException(this.message);
  final String message;
}

class EquipmentReservationActionException implements Exception {
  const EquipmentReservationActionException(this.message);
  final String message;
}

/// Example catalog for UI development; it does not represent live inventory.
class InMemoryEquipmentRepository implements EquipmentRepository {
  InMemoryEquipmentRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final List<EquipmentItem> _items = List.of(_sampleItems);
  final List<EquipmentReservation> _reservations = [];
  final List<EquipmentCancellation> _cancellations = [];
  int _nextId = 0;

  @override
  Future<List<EquipmentItem>> getItems() async => List.unmodifiable(_items);

  @override
  Future<int> availableCount(
    String itemId,
    DateTime start,
    DateTime end, {
    List<EquipmentCartEntry> cart = const [],
  }) async => _availableCount(itemId, start, end, cart);

  int _availableCount(
    String itemId,
    DateTime start,
    DateTime end,
    List<EquipmentCartEntry> cart,
  ) {
    final item = _items
        .where((candidate) => candidate.id == itemId)
        .firstOrNull;
    if (item == null) return 0;
    final overlapping = _reservations
        .where(
          (reservation) =>
              reservation.itemId == itemId &&
              start.isBefore(reservation.endsAt) &&
              reservation.startsAt.isBefore(end),
        )
        .toList();
    final pending = cart
        .where(
          (entry) =>
              entry.item.id == itemId &&
              start.isBefore(entry.endsAt) &&
              entry.startsAt.isBefore(end),
        )
        .toList();
    final times = [
      start,
      ...overlapping.map((entry) => entry.startsAt),
      ...pending.map((entry) => entry.startsAt),
    ];
    var peak = 0;
    for (final time in times) {
      final occupied =
          overlapping
              .where(
                (reservation) =>
                    !reservation.startsAt.isAfter(time) &&
                    reservation.endsAt.isAfter(time),
              )
              .fold<int>(
                0,
                (count, reservation) => count + reservation.quantity,
              ) +
          pending
              .where(
                (entry) =>
                    !entry.startsAt.isAfter(time) && entry.endsAt.isAfter(time),
              )
              .fold<int>(0, (count, entry) => count + entry.quantity);
      if (occupied > peak) peak = occupied;
    }
    return item.quantity - peak;
  }

  @override
  Future<EquipmentReservation> reserve({
    required EquipmentItem item,
    required String accountId,
    required String studentId,
    required DateTime start,
    required DateTime end,
  }) async {
    final reservations = await reserveCart(
      entries: [EquipmentCartEntry(item: item, startsAt: start, endsAt: end)],
      accountId: accountId,
      studentId: studentId,
    );
    return reservations.single;
  }

  @override
  Future<List<EquipmentReservation>> reserveCart({
    required List<EquipmentCartEntry> entries,
    required String accountId,
    required String studentId,
  }) async {
    if (entries.isEmpty) {
      throw const EquipmentReservationException(
        'Add an item to the cart first.',
      );
    }
    if (accountId.isEmpty || studentId.trim().isEmpty) {
      throw const EquipmentReservationException(
        'Enter your student ID and sign in first.',
      );
    }
    final now = _now();
    for (final entry in entries) {
      if (!entry.startsAt.isAfter(now) ||
          !entry.endsAt.isAfter(entry.startsAt)) {
        throw const EquipmentReservationException(
          'Choose a future start and an end time after it for every item.',
        );
      }
      if (!_items.any((candidate) => candidate.id == entry.item.id)) {
        throw const EquipmentReservationException(
          'An item could not be found.',
        );
      }
      if (entry.quantity < 1) {
        throw const EquipmentReservationException(
          'Choose a quantity of at least one for every item.',
        );
      }
    }
    // Check the peak number of overlapping rentals, including other cart rows.
    for (final itemId in entries.map((entry) => entry.item.id).toSet()) {
      final requested = entries
          .where((entry) => entry.item.id == itemId)
          .toList();
      final existing = _reservations
          .where((entry) => entry.itemId == itemId)
          .toList();
      final starts = [
        ...requested.map((entry) => entry.startsAt),
        ...existing.map((entry) => entry.startsAt),
      ];
      final quantity = _items.firstWhere((item) => item.id == itemId).quantity;
      for (final time in starts) {
        final count =
            requested
                .where(
                  (entry) =>
                      !entry.startsAt.isAfter(time) &&
                      entry.endsAt.isAfter(time),
                )
                .fold<int>(0, (sum, entry) => sum + entry.quantity) +
            existing
                .where(
                  (entry) =>
                      !entry.startsAt.isAfter(time) &&
                      entry.endsAt.isAfter(time),
                )
                .fold<int>(0, (sum, entry) => sum + entry.quantity);
        if (count > quantity) {
          final name = requested.first.item.name;
          throw EquipmentUnavailableException(
            '$name is unavailable for a selected time. Adjust the cart and try again.',
          );
        }
      }
    }
    final reservations = [
      for (final entry in entries)
        EquipmentReservation(
          id: 'demo-${++_nextId}',
          itemId: entry.item.id,
          itemName: entry.item.name,
          accountId: accountId,
          studentId: studentId.trim(),
          startsAt: entry.startsAt,
          endsAt: entry.endsAt,
          quantity: entry.quantity,
        ),
    ];
    _reservations.addAll(reservations);
    return List.unmodifiable(reservations);
  }

  @override
  Future<List<EquipmentReservation>> reservationsFor(String accountId) async =>
      List.unmodifiable(
        _reservations.where((entry) => entry.accountId == accountId),
      );

  @override
  Future<List<EquipmentReservation>> getAllReservations() async =>
      List.unmodifiable(_reservations);

  @override
  Future<List<EquipmentCancellation>> getCancellations() async =>
      List.unmodifiable(_cancellations);

  @override
  Future<void> completeReservation(
    String reservationId, {
    required bool returned,
  }) async {
    final index = _reservations.indexWhere(
      (entry) => entry.id == reservationId,
    );
    if (index < 0) {
      throw const EquipmentReservationActionException('Reservation not found.');
    }
    final reservation = _reservations[index];
    if (reservation.completedAt != null) {
      throw const EquipmentReservationActionException('Already completed.');
    }
    if (_now().isBefore(reservation.endsAt)) {
      throw const EquipmentReservationActionException(
        'Wait until the rental time has ended.',
      );
    }
    if (!returned) {
      throw const EquipmentReservationActionException(
        'Confirm the equipment was returned.',
      );
    }
    _reservations[index] = reservation.completed(_now());
  }

  @override
  Future<void> cancelReservation(
    String reservationId, {
    required bool userContacted,
    required bool bossApproved,
    required String reason,
  }) async {
    final index = _reservations.indexWhere(
      (entry) => entry.id == reservationId,
    );
    if (index < 0) {
      throw const EquipmentReservationActionException('Reservation not found.');
    }
    if (_reservations[index].completedAt != null) {
      throw const EquipmentReservationActionException(
        'A completed rental cannot be cancelled.',
      );
    }
    if (!userContacted || !bossApproved || reason.trim().isEmpty) {
      throw const EquipmentReservationActionException(
        'Confirm contact and boss approval, and enter a cancellation note.',
      );
    }
    _cancellations.add(
      EquipmentCancellation(
        reservation: _reservations.removeAt(index),
        reason: reason.trim(),
        cancelledAt: _now(),
      ),
    );
  }

  @override
  Future<void> updateQuantity(String itemId, int quantity) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index < 0 || quantity < 0) {
      throw const EquipmentInventoryException('Enter a valid quantity.');
    }

    // A lower quantity must still cover every existing overlapping booking.
    final upcoming = _reservations
        .where(
          (reservation) =>
              reservation.itemId == itemId &&
              reservation.endsAt.isAfter(_now()),
        )
        .toList();
    for (final reservation in upcoming) {
      final overlapping = upcoming
          .where(
            (other) =>
                !other.startsAt.isAfter(reservation.startsAt) &&
                other.endsAt.isAfter(reservation.startsAt),
          )
          .fold<int>(0, (count, other) => count + other.quantity);
      if (overlapping > quantity) {
        throw const EquipmentInventoryException(
          'Quantity cannot be lower than existing reservations at the same time.',
        );
      }
    }
    _items[index] = _items[index].withQuantity(quantity);
  }
}

const _sampleItems = <EquipmentItem>[
  EquipmentItem(
    id: 'bike',
    name: 'Bicycle',
    category: EquipmentCategory.transportation,
    description: 'Explore local paths and roads on two wheels.',
  ),
  EquipmentItem(
    id: 'helmet',
    name: 'Bike helmet',
    category: EquipmentCategory.transportation,
    description: 'Protective helmet for cycling.',
  ),
  EquipmentItem(
    id: 'longboard',
    name: 'Longboard',
    category: EquipmentCategory.transportation,
    description: 'A board for relaxed rides around campus.',
  ),
  EquipmentItem(
    id: 'cornhole',
    name: 'Cornhole set',
    category: EquipmentCategory.gamesAndActivities,
    description: 'A portable lawn game for groups.',
  ),
  EquipmentItem(
    id: 'disc',
    name: 'Flying disc',
    category: EquipmentCategory.gamesAndActivities,
    description: 'Bring a disc to a casual game outdoors.',
  ),
  EquipmentItem(
    id: 'volleyball',
    name: 'Volleyball',
    category: EquipmentCategory.gamesAndActivities,
    description: 'A ball for recreational volleyball.',
  ),
  EquipmentItem(
    id: 'shoes',
    name: 'Climbing shoes',
    category: EquipmentCategory.climbing,
    description: 'Shoes designed for indoor climbing.',
  ),
  EquipmentItem(
    id: 'harness',
    name: 'Climbing harness',
    category: EquipmentCategory.climbing,
    description: 'A harness for roped climbing activities.',
  ),
  EquipmentItem(
    id: 'chalk',
    name: 'Chalk bag',
    category: EquipmentCategory.climbing,
    description: 'A small bag for climbing chalk.',
  ),
  EquipmentItem(
    id: 'ice-axe',
    name: 'Ice axe',
    category: EquipmentCategory.mountaineering,
    description: 'A tool for mountain travel in snowy conditions.',
  ),
  EquipmentItem(
    id: 'crampons',
    name: 'Crampons',
    category: EquipmentCategory.mountaineering,
    description: 'Traction equipment for suitable mountain boots.',
  ),
  EquipmentItem(
    id: 'pack',
    name: 'Backpacking pack',
    category: EquipmentCategory.backpacking,
    description: 'A large pack for carrying overnight gear.',
  ),
  EquipmentItem(
    id: 'tent',
    name: 'Backpacking tent',
    category: EquipmentCategory.backpacking,
    description: 'A compact shelter for an overnight trip.',
  ),
  EquipmentItem(
    id: 'sleeping-bag',
    name: 'Sleeping bag',
    category: EquipmentCategory.backpacking,
    description: 'Sleep gear for camping trips.',
  ),
  EquipmentItem(
    id: 'paddleboard',
    name: 'Stand-up paddleboard',
    category: EquipmentCategory.watersports,
    description: 'A board for paddling on calm water.',
  ),
  EquipmentItem(
    id: 'kayak',
    name: 'Kayak',
    category: EquipmentCategory.watersports,
    description: 'A small boat for paddling outings.',
  ),
  EquipmentItem(
    id: 'life-jacket',
    name: 'Life jacket',
    category: EquipmentCategory.watersports,
    description: 'A personal flotation device for water activities.',
  ),
  EquipmentItem(
    id: 'snowshoes',
    name: 'Snowshoes',
    category: EquipmentCategory.winterEquipment,
    description: 'Traction and flotation for walking on snow.',
  ),
  EquipmentItem(
    id: 'skis',
    name: 'Cross-country skis',
    category: EquipmentCategory.winterEquipment,
    description: 'Skis for traveling across snowy trails.',
  ),
  EquipmentItem(
    id: 'sled',
    name: 'Sled',
    category: EquipmentCategory.winterEquipment,
    description: 'A sled for winter recreation.',
  ),
];
