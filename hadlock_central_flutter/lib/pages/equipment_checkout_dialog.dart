import 'package:flutter/material.dart';

import '../data/equipment_repository.dart';
import '../models/equipment_cart_entry.dart';
import '../models/student_account.dart';

/// Reviews the entire cart and reserves every entry in one operation.
class EquipmentCheckoutDialog extends StatefulWidget {
  const EquipmentCheckoutDialog({
    super.key,
    required this.entries,
    required this.account,
    required this.repository,
  });

  final List<EquipmentCartEntry> entries;
  final StudentAccount account;
  final EquipmentRepository repository;

  @override
  State<EquipmentCheckoutDialog> createState() =>
      _EquipmentCheckoutDialogState();
}

class _EquipmentCheckoutDialogState extends State<EquipmentCheckoutDialog> {
  final _studentId = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _studentId.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    if (_saving) return;
    if (_studentId.text.trim().isEmpty) {
      setState(() => _error = 'Enter your student ID.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.reserveCart(
        entries: widget.entries,
        accountId: widget.account.id,
        studentId: _studentId.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on EquipmentReservationException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on EquipmentUnavailableException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not complete checkout. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Checkout rentals'),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.account.firstName} ${widget.account.lastName} · ${widget.account.email}',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _studentId,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.entries.length} ${widget.entries.length == 1 ? 'reservation' : 'reservations'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final entry in widget.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${entry.item.name} × ${entry.quantity}'),
                subtitle: Text(
                  '${MaterialLocalizations.of(context).formatMediumDate(entry.startsAt)} · '
                  '${TimeOfDay.fromDateTime(entry.startsAt).format(context)}–'
                  '${TimeOfDay.fromDateTime(entry.endsAt).format(context)}',
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
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Back to cart'),
      ),
      FilledButton(
        onPressed: _saving ? null : _checkout,
        child: Text(_saving ? 'Checking out...' : 'Reserve all'),
      ),
    ],
  );
}
