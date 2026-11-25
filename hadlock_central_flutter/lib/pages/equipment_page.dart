import 'package:flutter/material.dart';

import '../data/equipment_repository.dart';
import '../models/equipment_item.dart';
import '../models/equipment_reservation.dart';
import '../models/student_account.dart';
import 'equipment_reservation_dialog.dart';

/// Browse equipment rentals and facility reservation spaces.
class EquipmentPage extends StatefulWidget {
  const EquipmentPage({
    super.key,
    required this.repository,
    required this.account,
    required this.onOpenSchedule,
  });

  final EquipmentRepository repository;
  final StudentAccount account;
  final VoidCallback onOpenSchedule;

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final _searchController = TextEditingController();
  EquipmentCategory? _category;
  bool _showReservations = false;
  bool _staffPreview = false;
  late Future<List<EquipmentItem>> _itemsFuture;
  Future<List<EquipmentReservation>>? _staffReservationsFuture;
  Future<List<EquipmentCancellation>>? _cancellationsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = widget.repository.getItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant EquipmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when the app switches from sample data to another repository.
    if (oldWidget.repository != widget.repository) {
      _itemsFuture = widget.repository.getItems();
      if (_staffPreview) {
        _staffReservationsFuture = widget.repository.getAllReservations();
        _cancellationsFuture = widget.repository.getCancellations();
      }
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

  void _reloadStaffReservations() => setState(() {
    _staffReservationsFuture = widget.repository.getAllReservations();
    _cancellationsFuture = widget.repository.getCancellations();
  });

  Future<void> _manageReservation(
    EquipmentReservation reservation,
    bool cancel,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _ReservationActionDialog(
        reservation: reservation,
        repository: widget.repository,
        cancel: cancel,
      ),
    );
    if (saved == true && mounted) _reloadStaffReservations();
  }

  Future<void> _reserve(EquipmentItem item) async {
    final reservation = await showDialog<EquipmentReservation>(
      context: context,
      builder: (context) => EquipmentReservationDialog(
        item: item,
        account: widget.account,
        repository: widget.repository,
      ),
    );
    if (!mounted || reservation == null) return;
    if (_staffPreview) _reloadStaffReservations();
    // Personal reservations appear only on the signed-in student's calendar.
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equipment reserved'),
        content: const Text(
          'Come to the front desk for your reservation. You can find it on your calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onOpenSchedule();
            },
            child: const Text('View calendar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Rentals',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Browse equipment and spaces available at Hadlock Central.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // Match the Schedule page's temporary staff preview control.
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        _staffPreview = !_staffPreview;
                        if (_staffPreview) {
                          _staffReservationsFuture = widget.repository
                              .getAllReservations();
                          _cancellationsFuture = widget.repository
                              .getCancellations();
                        }
                      }),
                      icon: Icon(
                        _staffPreview
                            ? Icons.admin_panel_settings
                            : Icons.visibility_outlined,
                      ),
                      label: Text(
                        _staffPreview ? 'Exit staff preview' : 'Staff preview',
                      ),
                    ),
                  ),
                  if (_staffPreview) ...[
                    const SizedBox(height: 8),
                    _buildStaffReservations(),
                  ],
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _showReservations
                          ? 'Browse spaces below and check the schedule for existing bookings. Online facility booking is not connected yet.'
                          : 'Sample inventory · Equipment reservations are a local demo and are cleared when the app restarts.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _showReservations
                          ? 'Search reservation spaces'
                          : 'Search equipment',
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
                        selected: !_showReservations && _category == null,
                        onSelected: (_) => setState(() {
                          _showReservations = false;
                          _category = null;
                        }),
                      ),
                      for (final category in EquipmentCategory.values)
                        ChoiceChip(
                          label: Text(category.label),
                          selected: !_showReservations && _category == category,
                          onSelected: (_) => setState(() {
                            _showReservations = false;
                            _category = category;
                          }),
                        ),
                      ChoiceChip(
                        label: const Text('Reservations'),
                        selected: _showReservations,
                        onSelected: (_) =>
                            setState(() => _showReservations = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_showReservations)
                    _buildReservationSpaces()
                  else
                    FutureBuilder<List<EquipmentItem>>(
                      future: _itemsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                        final query = _searchController.text
                            .trim()
                            .toLowerCase();
                        // Apply category and text filters to the same loaded catalog.
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
                                          item.description
                                              .toLowerCase()
                                              .contains(query) ||
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
                                          onEditQuantity: _staffPreview
                                              ? () => _editQuantity(item)
                                              : null,
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

  /// Staff preview reads every equipment reservation for front desk pickup.
  Widget _buildStaffReservations() => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Staff preview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text(
            'Demo access only. Staff authentication and shared inventory need a backend connection.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Equipment reservations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Refresh reservations',
                onPressed: _reloadStaffReservations,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          FutureBuilder<List<EquipmentReservation>>(
            future: _staffReservationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }
              if (snapshot.hasError) {
                return const Text('Reservations could not be loaded.');
              }
              final reservations = [...?snapshot.data]
                ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
              if (reservations.isEmpty) {
                return const Text(
                  'No active or completed equipment reservations.',
                );
              }
              return Column(
                children: [
                  for (final reservation in reservations)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(reservation.itemName),
                          subtitle: Text(
                            'Student ID: ${reservation.studentId}\n'
                            '${MaterialLocalizations.of(context).formatMediumDate(reservation.startsAt)} '
                            '${TimeOfDay.fromDateTime(reservation.startsAt).format(context)}–'
                            '${TimeOfDay.fromDateTime(reservation.endsAt).format(context)}\n'
                            '${reservation.completedAt == null ? 'Reserved' : 'Completed and returned'}',
                          ),
                          isThreeLine: true,
                        ),
                        if (reservation.completedAt == null)
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed:
                                    DateTime.now().isBefore(reservation.endsAt)
                                    ? null
                                    : () => _manageReservation(
                                        reservation,
                                        false,
                                      ),
                                icon: const Icon(Icons.task_alt),
                                label: const Text('Mark complete'),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _manageReservation(reservation, true),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Cancel reservation'),
                              ),
                            ],
                          ),
                        const Divider(),
                      ],
                    ),
                ],
              );
            },
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Cancellation notes'),
            children: [
              FutureBuilder<List<EquipmentCancellation>>(
                future: _cancellationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text(
                      'Cancellation notes could not be loaded.',
                    );
                  }
                  final cancellations =
                      snapshot.data ?? const <EquipmentCancellation>[];
                  if (cancellations.isEmpty) {
                    return const Text('No cancellations recorded.');
                  }
                  return Column(
                    children: [
                      for (final entry in cancellations)
                        ListTile(
                          title: Text(entry.reservation.itemName),
                          subtitle: Text(
                            'Student ID: ${entry.reservation.studentId}\n'
                            'Reason: ${entry.reason}',
                          ),
                          isThreeLine: true,
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _editQuantity(EquipmentItem item) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _EditQuantityDialog(item: item, repository: widget.repository),
    );
    if (saved == true && mounted) _reload();
  }

  /// Shows the reservable spaces without treating them as equipment inventory.
  Widget _buildReservationSpaces() {
    final query = _searchController.text.trim().toLowerCase();
    final spaces = _reservationSpaces
        .where(
          (space) =>
              query.isEmpty ||
              space.name.toLowerCase().contains(query) ||
              space.type.toLowerCase().contains(query) ||
              space.description.toLowerCase().contains(query),
        )
        .toList();

    if (spaces.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: Text('No reservation spaces match your search.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${spaces.length} ${spaces.length == 1 ? 'space' : 'spaces'}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 900
                ? 3
                : width >= 560
                ? 2
                : 1;
            final cardWidth = (width - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final space in spaces)
                  SizedBox(
                    width: cardWidth,
                    child: _ReservationSpaceCard(
                      space: space,
                      onTap: () => _showSpaceDetails(space),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showSpaceDetails(_ReservationSpace space) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(space.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(space.type, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            Text(space.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onOpenSchedule();
            },
            child: const Text('View schedule'),
          ),
        ],
      ),
    );
  }

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
            Text('Sample quantity: ${item.quantity}'),
            const SizedBox(height: 8),
            const Text(
              'Choose a time to check availability and reserve this item.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reserve(item);
            },
            child: const Text('Check availability'),
          ),
        ],
      ),
    );
  }
}

/// Confirms the checks staff must make before changing a reservation.
class _ReservationActionDialog extends StatefulWidget {
  const _ReservationActionDialog({
    required this.reservation,
    required this.repository,
    required this.cancel,
  });

  final EquipmentReservation reservation;
  final EquipmentRepository repository;
  final bool cancel;

  @override
  State<_ReservationActionDialog> createState() =>
      _ReservationActionDialogState();
}

class _ReservationActionDialogState extends State<_ReservationActionDialog> {
  final _reason = TextEditingController();
  bool _returned = false;
  bool _contacted = false;
  bool _approved = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.cancel) {
        await widget.repository.cancelReservation(
          widget.reservation.id,
          userContacted: _contacted,
          bossApproved: _approved,
          reason: _reason.text,
        );
      } else {
        await widget.repository.completeReservation(
          widget.reservation.id,
          returned: _returned,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on EquipmentReservationActionException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not update reservation. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.cancel ? 'Cancel reservation' : 'Complete rental'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.reservation.itemName} · Student ID: ${widget.reservation.studentId}',
          ),
          const SizedBox(height: 12),
          if (widget.cancel) ...[
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _contacted,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _contacted = value ?? false),
              title: const Text('I contacted the reservation holder'),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _approved,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _approved = value ?? false),
              title: const Text(
                'The boss approved the reason for cancellation',
              ),
            ),
            TextField(
              controller: _reason,
              enabled: !_saving,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Cancellation reason and note',
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            const Text('Only complete a rental after its scheduled end time.'),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _returned,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _returned = value ?? false),
              title: const Text('The equipment has been returned'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Back'),
      ),
      FilledButton(
        onPressed: _saving ? null : _submit,
        child: Text(
          _saving
              ? 'Saving...'
              : widget.cancel
              ? 'Cancel reservation'
              : 'Mark complete',
        ),
      ),
    ],
  );
}

/// Catalog card that opens the selected item's details.
class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({
    required this.item,
    required this.onTap,
    required this.onEditQuantity,
  });

  final EquipmentItem item;
  final VoidCallback onTap;
  final VoidCallback? onEditQuantity;

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
            if (onEditQuantity != null) ...[
              OutlinedButton.icon(
                onPressed: onEditQuantity,
                icon: const Icon(Icons.edit_outlined),
                label: Text('Quantity: ${item.quantity}'),
              ),
              const SizedBox(height: 8),
            ],
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

/// Edits the sample inventory and keeps validation feedback inside the form.
class _EditQuantityDialog extends StatefulWidget {
  const _EditQuantityDialog({required this.item, required this.repository});

  final EquipmentItem item;
  final EquipmentRepository repository;

  @override
  State<_EditQuantityDialog> createState() => _EditQuantityDialogState();
}

class _EditQuantityDialogState extends State<_EditQuantityDialog> {
  late final TextEditingController _quantity = TextEditingController(
    text: widget.item.quantity.toString(),
  );
  String? _error;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final value = int.tryParse(_quantity.text.trim());
    if (value == null || value < 0) {
      setState(() => _error = 'Enter a whole number of zero or more.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.updateQuantity(widget.item.id, value);
      if (mounted) Navigator.of(context).pop(true);
    } on EquipmentInventoryException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not update quantity. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Edit ${widget.item.name} quantity'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _quantity,
          keyboardType: TextInputType.number,
          autofocus: true,
          onSubmitted: (_) => _save(),
          decoration: const InputDecoration(
            labelText: 'Total quantity',
            border: OutlineInputBorder(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Saving...' : 'Save quantity'),
      ),
    ],
  );
}

/// Display data for the facility section; these are not equipment units.
class _ReservationSpace {
  const _ReservationSpace({
    required this.name,
    required this.type,
    required this.description,
    required this.icon,
  });

  final String name;
  final String type;
  final String description;
  final IconData icon;
}

const _reservationSpaces = <_ReservationSpace>[
  _ReservationSpace(
    name: 'Court 1',
    type: 'Gym court',
    description: 'One of three gym courts for recreational activities.',
    icon: Icons.sports_basketball_outlined,
  ),
  _ReservationSpace(
    name: 'Court 2',
    type: 'Gym court',
    description: 'One of three gym courts for recreational activities.',
    icon: Icons.sports_basketball_outlined,
  ),
  _ReservationSpace(
    name: 'Court 3',
    type: 'Gym court',
    description: 'One of three gym courts for recreational activities.',
    icon: Icons.sports_basketball_outlined,
  ),
  _ReservationSpace(
    name: 'Small private studio',
    type: 'Room',
    description:
        'A smaller private studio space for individual or small group use.',
    icon: Icons.meeting_room_outlined,
  ),
  _ReservationSpace(
    name: 'Large private studio',
    type: 'Room',
    description: 'A larger private studio space for group activities.',
    icon: Icons.meeting_room_outlined,
  ),
  _ReservationSpace(
    name: 'Rock wall',
    type: 'Climbing space',
    description: 'The indoor rock wall for climbing activities.',
    icon: Icons.terrain_outlined,
  ),
];

/// Facility card styled like the equipment cards in the same catalog.
class _ReservationSpaceCard extends StatelessWidget {
  const _ReservationSpaceCard({required this.space, required this.onTap});

  final _ReservationSpace space;
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
              space.icon,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              space.type,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 5),
            Text(space.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 7),
            Text(
              space.description,
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

IconData _iconFor(EquipmentCategory category) => switch (category) {
  EquipmentCategory.transportation => Icons.directions_bike_outlined,
  EquipmentCategory.gamesAndActivities => Icons.sports_basketball_outlined,
  EquipmentCategory.climbing => Icons.terrain_outlined,
  EquipmentCategory.mountaineering => Icons.landscape_outlined,
  EquipmentCategory.backpacking => Icons.backpack_outlined,
  EquipmentCategory.watersports => Icons.kayaking_outlined,
  EquipmentCategory.winterEquipment => Icons.ac_unit_outlined,
};
