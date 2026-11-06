/// Categories shown in the equipment filter chips.
enum EquipmentCategory {
  transportation('Transportation'),
  gamesAndActivities('Games and activities'),
  climbing('Climbing'),
  mountaineering('Mountaineering'),
  backpacking('Backpacking'),
  watersports('Watersports'),
  winterEquipment('Winter equipment');

  const EquipmentCategory(this.label);
  final String label;
}

/// Catalog item details, separate from live availability or checkout data.
class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.quantity = 2,
  });

  final String id;
  final String name;
  final EquipmentCategory category;
  final String description;

  /// Total example units available before any overlapping reservations.
  final int quantity;
}
