import 'package:flutter/material.dart';

import '../data/equipment_repository.dart';
import '../models/equipment_item.dart';

/// EquipmentPage is a StatefulWidget that displays a list of equipment items, allowing users to search and filter
/// by category. It fetches data from the provided EquipmentRepository and displays it in a responsive layout with 
/// cards for each item. Users can view details of each item in a dialog.
class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key, required this.repository});

  final EquipmentRepository repository;

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final _searchController = TextEditingController();
  EquipmentCategory? _category;
  late Future<List<EquipmentItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = widget.repository.getItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant EquipmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _itemsFuture = widget.repository.getItems();
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  void _reload() => setState(() => _itemsFuture = widget.repository.getItems());

  @override
  Widget build(BuildContext context) {
    /// The build method constructs the UI for the EquipmentPage, including a search bar, category filters, and a 
    /// list of equipment items. It uses a FutureBuilder to handle asynchronous data fetching and displays appropriate 
    /// messages for loading, errors, or empty results. The layout adapts to different screen sizes, providing a 
    /// responsive user experience.
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 20 : 40,
            vertical: compact ? 24 : 38,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// The following Text widgets display the title and subtitle of the EquipmentPage, 
                  /// providing context to the user.
                  Text(
                    'Equipment',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Browse gear and activities by category.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Sample catalog · Items shown here are examples. Live inventory and checkout are not connected yet.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search equipment',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: _searchController.clear,
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All products'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      for (final category in EquipmentCategory.values)
                        ChoiceChip(
                          label: Text(category.label),
                          selected: _category == category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<List<EquipmentItem>>(
                    future: _itemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(48),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            children: [
                              const Text('Equipment could not be loaded.'),
                              TextButton(
                                onPressed: _reload,
                                child: const Text('Try again'),
                              ),
                            ],
                          ),
                        );
                      }
                      final query = _searchController.text.trim().toLowerCase();
                      final items =
                          (snapshot.data ?? const <EquipmentItem>[])
                              .where(
                                (item) =>
                                    (_category == null ||
                                        item.category == _category) &&
                                    (query.isEmpty ||
                                        item.name.toLowerCase().contains(
                                          query,
                                        ) ||
                                        item.description.toLowerCase().contains(
                                          query,
                                        ) ||
                                        item.category.label
                                            .toLowerCase()
                                            .contains(query)),
                              )
                              .toList()
                            ..sort((a, b) => a.name.compareTo(b.name));
                      if (items.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Text('No equipment matches your search.'),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, gridConstraints) {
                              final width = gridConstraints.maxWidth;
                              final columns = width >= 900
                                  ? 3
                                  : width >= 560
                                  ? 2
                                  : 1;
                              final cardWidth =
                                  (width - (columns - 1) * 12) / columns;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  for (final item in items)
                                    SizedBox(
                                      width: cardWidth,
                                      child: _EquipmentCard(
                                        item: item,
                                        onTap: () => _showDetails(item),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// _showDetails displays a dialog with detailed information about a selected equipment item, including its name,
  /// category, description, and a note about availability and checkout details.
  void _showDetails(EquipmentItem item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.category.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Text(item.description),
            const SizedBox(height: 18),
            Text(
              'Availability and checkout details will appear when the inventory service is connected.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// _EquipmentCard is a stateless widget that represents a card displaying an equipment item's details, including
/// its category, name, and description. It also provides an onTap callback for user interaction.
class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.item, required this.onTap});

  final EquipmentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconFor(item.category),
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              item.category.label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 5),
            Text(item.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 7),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Text('View details'),
                SizedBox(width: 5),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// _iconFor returns an appropriate icon for a given EquipmentCategory, used for visual representation in the UI.
IconData _iconFor(EquipmentCategory category) => switch (category) {
  EquipmentCategory.transportation => Icons.directions_bike_outlined,
  EquipmentCategory.gamesAndActivities => Icons.sports_basketball_outlined,
  EquipmentCategory.climbing => Icons.terrain_outlined,
  EquipmentCategory.mountaineering => Icons.landscape_outlined,
  EquipmentCategory.backpacking => Icons.backpack_outlined,
  EquipmentCategory.watersports => Icons.kayaking_outlined,
  EquipmentCategory.winterEquipment => Icons.ac_unit_outlined,
};
