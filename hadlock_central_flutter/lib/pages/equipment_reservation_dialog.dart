import 'package:flutter/material.dart';

import '../data/equipment_repository.dart';
import '../models/equipment_item.dart';
import '../models/student_account.dart';

/// Collects the signed-in student's details and a requested time window.
class EquipmentReservationDialog extends StatefulWidget {
  const EquipmentReservationDialog({
    super.key,
    required this.item,
    required this.account,
    required this.repository,
  });

  final EquipmentItem item;
  final StudentAccount account;
  final EquipmentRepository repository;

  @override
  State<EquipmentReservationDialog> createState() =>
      _EquipmentReservationDialogState();
}

class _EquipmentReservationDialogState
    extends State<EquipmentReservationDialog> {
  late final TextEditingController _firstName = TextEditingController(
    text: widget.account.firstName,
  );
  late final TextEditingController _lastName = TextEditingController(
    text: widget.account.lastName,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.account.email,
  );
  final TextEditingController _studentId = TextEditingController();
  late DateTime _date = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 1)),
  );
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  String? _error;
  bool _saving = false;
  late Future<int> _available = _checkAvailability();

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

  Future<int> _checkAvailability() =>
      widget.repository.availableCount(widget.item.id, _start, _end);

  void _updateTime() => setState(() {
    _error = null;
    _available = _checkAvailability();
  });

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateUtils.dateOnly(DateTime.now()),
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

  Future<void> _reserve() async {
    if (_saving) return;
    if (_firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _studentId.text.trim().isEmpty) {
      setState(
        () =>
            _error = 'Enter your first name, last name, email, and student ID.',
      );
      return;
    }
    if (_email.text.trim().toLowerCase() !=
        widget.account.email.toLowerCase()) {
      setState(() => _error = 'Use the email on your signed-in account.');
      return;
    }
    if (!_start.isAfter(DateTime.now()) || !_end.isAfter(_start)) {
      setState(
        () => _error = 'Choose a future start and an end time after it.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final reservation = await widget.repository.reserve(
        item: widget.item,
        accountId: widget.account.id,
        studentId: _studentId.text.trim(),
        start: _start,
        end: _end,
      );
      if (mounted) {
        Navigator.of(context).pop(reservation);
      }
    } on EquipmentUnavailableException {
      if (mounted) {
        setState(() {
          _error =
              'No ${widget.item.name.toLowerCase()} units are available for that time. Choose another time.';
          _available = _checkAvailability();
        });
      }
    } on EquipmentReservationException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not reserve this item. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _studentId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Reserve ${widget.item.name}'),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm your account details and choose when you need the item.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _firstName,
              readOnly: widget.account.firstName.isNotEmpty,
              decoration: const InputDecoration(labelText: 'First name'),
            ),
            TextField(
              controller: _lastName,
              readOnly: widget.account.lastName.isNotEmpty,
              decoration: const InputDecoration(labelText: 'Last name'),
            ),
            TextField(
              controller: _email,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _studentId,
              decoration: const InputDecoration(labelText: 'Student ID'),
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
                    return const Text('Availability could not be checked.');
                  }
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }
                  final count = snapshot.data!;
                  return Text(
                    count == 0
                        ? 'No units available for this time.'
                        : '$count of ${widget.item.quantity} available for this time.',
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
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _reserve,
        child: Text(_saving ? 'Reserving...' : 'Reserve item'),
      ),
    ],
  );
}
