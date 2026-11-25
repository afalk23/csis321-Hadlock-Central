import 'dart:async';

import 'package:flutter/material.dart';

import '../data/equipment_repository.dart';
import '../models/equipment_cart_entry.dart';
import '../models/equipment_item.dart';

/// Chooses one item and time window to add to the local checkout cart.
class EquipmentReservationDialog extends StatefulWidget {
  const EquipmentReservationDialog({
    super.key,
    required this.item,
    required this.repository,
    required this.cart,
    this.initialEntry,
  });

  final EquipmentItem item;
  final EquipmentRepository repository;
  final List<EquipmentCartEntry> cart;
  final EquipmentCartEntry? initialEntry;

  @override
  State<EquipmentReservationDialog> createState() =>
      _EquipmentReservationDialogState();
}

class _EquipmentReservationDialogState
    extends State<EquipmentReservationDialog> {
  late DateTime _date = DateUtils.dateOnly(
    widget.initialEntry?.startsAt ??
        DateTime.now().add(const Duration(days: 1)),
  );
  late TimeOfDay _startTime = widget.initialEntry == null
      ? const TimeOfDay(hour: 10, minute: 0)
      : TimeOfDay.fromDateTime(widget.initialEntry!.startsAt);
  late TimeOfDay _endTime = widget.initialEntry == null
      ? const TimeOfDay(hour: 11, minute: 0)
      : TimeOfDay.fromDateTime(widget.initialEntry!.endsAt);
  String? _error;
  late int _quantity = widget.initialEntry?.quantity ?? 1;
  Timer? _availabilityTimer;
  late Future<int> _available = _checkAvailability();

  @override
  void initState() {
    super.initState();
    _availabilityTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _refreshAvailability();
    });
  }

  @override
  void dispose() {
    _availabilityTimer?.cancel();
    super.dispose();
  }

  DateTime get _start => DateTime(
    _date.year,
    _date.month,
    _date.day,
    _startTime.hour,
    _startTime.minute,
  );
  DateTime get _end => DateTime(
    _date.year,
    _date.month,
    _date.day,
    _endTime.hour,
    _endTime.minute,
  );
  Future<int> _checkAvailability() => widget.repository.availableCount(
    widget.item.id,
    _start,
    _end,
    cart: widget.cart,
  );

  void _refreshAvailability() =>
      setState(() => _available = _checkAvailability());

  void _updateTime() => setState(() {
    _error = null;
    _available = _checkAvailability();
  });

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 365)),
      ),
    );
    if (date == null || !mounted) return;
    _date = date;
    _updateTime();
  }

  Future<void> _pickTime(bool start) async {
    final time = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (time == null || !mounted) return;
    if (start) {
      _startTime = time;
    } else {
      _endTime = time;
    }
    _updateTime();
  }

  Future<void> _addToCart() async {
    if (!_start.isAfter(DateTime.now()) || !_end.isAfter(_start)) {
      setState(
        () => _error = 'Choose a future start and an end time after it.',
      );
      return;
    }
    try {
      if (await _checkAvailability() < _quantity) {
        if (mounted) {
          setState(
            () =>
                _error = 'The requested quantity is unavailable for this time.',
          );
        }
        return;
      }
      if (mounted) {
        Navigator.of(context).pop(
          EquipmentCartEntry(
            item: widget.item,
            startsAt: _start,
            endsAt: _end,
            quantity: _quantity,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Availability could not be checked. Try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.initialEntry == null
          ? 'Add ${widget.item.name} to cart'
          : 'Edit ${widget.item.name}',
    ),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialEntry == null
                  ? 'Choose when you need this item. You can add more items or time windows before checkout.'
                  : 'Change the rental time or quantity before checkout.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                MaterialLocalizations.of(context).formatMediumDate(_date),
              ),
            ),
            Wrap(
              spacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () => _pickTime(true),
                  child: Text('From ${_startTime.format(context)}'),
                ),
                OutlinedButton(
                  onPressed: () => _pickTime(false),
                  child: Text('To ${_endTime.format(context)}'),
                ),
              ],
            ),
            if (_end.isAfter(_start) && _start.isAfter(DateTime.now()))
              FutureBuilder<int>(
                future: _available,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return TextButton.icon(
                      onPressed: _refreshAvailability,
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Availability could not be checked. Retry',
                      ),
                    );
                  }
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  final count = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$count of ${widget.item.quantity} available for this time',
                            ),
                          ),
                          IconButton(
                            tooltip: 'Refresh availability',
                            onPressed: _refreshAvailability,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const Text('Includes items already in your cart.'),
                      Row(
                        children: [
                          const Text('Quantity'),
                          IconButton(
                            tooltip: 'Decrease quantity',
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$_quantity'),
                          IconButton(
                            tooltip: 'Increase quantity',
                            onPressed: _quantity < count
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      if (_quantity > count)
                        const Text(
                          'Reduce the quantity or choose another time.',
                        ),
                    ],
                  );
                },
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
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _addToCart,
        child: Text(
          widget.initialEntry == null ? 'Add to cart' : 'Save changes',
        ),
      ),
    ],
  );
}
