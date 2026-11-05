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

class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  final String id;
  final String name;
  final EquipmentCategory category;
  final String description;
}
