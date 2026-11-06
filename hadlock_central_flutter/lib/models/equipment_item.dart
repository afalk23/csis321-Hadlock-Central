/// This file defines the EquipmentItem model and its associated enum.
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

/// The EquipmentItem class represents an equipment item with various properties such as id, name, category, 
/// and description.
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
