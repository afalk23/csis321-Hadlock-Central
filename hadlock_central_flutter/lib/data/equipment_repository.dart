import '../models/equipment_item.dart';

abstract class EquipmentRepository {
  Future<List<EquipmentItem>> getItems();
}

/// Example catalog for UI development. It does not represent live inventory.
class InMemoryEquipmentRepository implements EquipmentRepository {
  @override
  Future<List<EquipmentItem>> getItems() async =>
      List.unmodifiable(_sampleItems);
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
