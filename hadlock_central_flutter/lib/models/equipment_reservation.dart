/// A student's requested equipment time window.
class EquipmentReservation {
  const EquipmentReservation({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.accountId,
    required this.studentId,
    required this.startsAt,
    required this.endsAt,
    this.quantity = 1,
    this.completedAt,
  });

  final String id;
  final String itemId;
  final String itemName;
  final String accountId;
  final String studentId;
  final DateTime startsAt;
  final DateTime endsAt;
  final int quantity;
  final DateTime? completedAt;

  EquipmentReservation completed(DateTime at) => EquipmentReservation(
    id: id,
    itemId: itemId,
    itemName: itemName,
    accountId: accountId,
    studentId: studentId,
    startsAt: startsAt,
    endsAt: endsAt,
    quantity: quantity,
    completedAt: at,
  );
}

/// A retained note for a reservation removed by staff.
class EquipmentCancellation {
  const EquipmentCancellation({
    required this.reservation,
    required this.reason,
    required this.cancelledAt,
  });

  final EquipmentReservation reservation;
  final String reason;
  final DateTime cancelledAt;
}
