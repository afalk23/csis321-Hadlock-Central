import '../models/equipment_item.dart';
import '../models/equipment_reservation.dart';

/// Catalog data boundary for a future inventory API implementation.
abstract class EquipmentRepository {
  Future<List<EquipmentItem>> getItems();

  Future<int> availableCount(String itemId, DateTime start, DateTime end);
  Future<EquipmentReservation> reserve({
    required EquipmentItem item,
    required String accountId,
    required String studentId,
    required DateTime start,
    required DateTime end,
  });
  Future<List<EquipmentReservation>> reservationsFor(String accountId);
}

class EquipmentUnavailableException implements Exception {
  const EquipmentUnavailableException();
}

class EquipmentReservationException implements Exception {
  const EquipmentReservationException(this.message);
  final String message;
}

/// Example catalog for UI development; it does not represent live inventory.
class InMemoryEquipmentRepository implements EquipmentRepository {
  final List<EquipmentReservation> _reservations = [];
  int _nextId = 0;

  @override
  Future<List<EquipmentItem>> getItems() async =>
      List.unmodifiable(_sampleItems);

  @override
  Future<int> availableCount(
    String itemId,
    DateTime start,
    DateTime end,
  ) async => _availableCount(itemId, start, end);

  int _availableCount(String itemId, DateTime start, DateTime end) {
    final item = _sampleItems
        .where((candidate) => candidate.id == itemId)
        .firstOrNull;
    if (item == null) return 0;
    return item.quantity -
        _reservations
            .where(
              (reservation) =>
                  reservation.itemId == itemId &&
                  start.isBefore(reservation.endsAt) &&
                  reservation.startsAt.isBefore(end),
            )
            .length;
  }

  @override
  Future<EquipmentReservation> reserve({
    required EquipmentItem item,
    required String accountId,
    required String studentId,
    required DateTime start,
    required DateTime end,
  }) async {
    if (accountId.isEmpty ||
        studentId.trim().isEmpty ||
        !start.isAfter(DateTime.now()) ||
        !end.isAfter(start)) {
      throw const EquipmentReservationException(
        'Choose a valid future time and sign in first.',
      );
    }
    // Recheck availability when saving so two requests cannot take the last unit.
    if (_availableCount(item.id, start, end) < 1) {
      throw const EquipmentUnavailableException();
    }
    final reservation = EquipmentReservation(
      id: 'demo-${++_nextId}',
      itemId: item.id,
      itemName: item.name,
      accountId: accountId,
      studentId: studentId.trim(),
      startsAt: start,
      endsAt: end,
    );
    _reservations.add(reservation);
    return reservation;
  }

  @override
  Future<List<EquipmentReservation>> reservationsFor(String accountId) async =>
      List.unmodifiable(
        _reservations.where((entry) => entry.accountId == accountId),
      );
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
