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
  });

  final String id;
  final String itemId;
  final String itemName;
  final String accountId;
  final String studentId;
  final DateTime startsAt;
  final DateTime endsAt;
}
