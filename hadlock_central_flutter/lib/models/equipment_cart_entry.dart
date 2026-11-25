import 'equipment_item.dart';

/// An equipment request held locally until the student checks out the cart.
class EquipmentCartEntry {
  const EquipmentCartEntry({
    required this.item,
    required this.startsAt,
    required this.endsAt,
    this.quantity = 1,
  });

  final EquipmentItem item;
  final DateTime startsAt;
  final DateTime endsAt;
  final int quantity;
}
