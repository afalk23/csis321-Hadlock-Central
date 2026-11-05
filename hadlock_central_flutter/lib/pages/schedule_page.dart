import 'package:flutter/material.dart';

import '../data/calendar_repository.dart';
import '../models/calendar_entry.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.repository});

  final CalendarRepository repository;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  bool _staffPreview = false;
  late Future<List<CalendarEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = widget.repository.getEntries();
  }

  @override
  void didUpdateWidget(covariant SchedulePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _entriesFuture = widget.repository.getEntries();
    }
  }

  void _reload() {
    setState(() {
      _entriesFuture = widget.repository.getEntries();
    });
  }

  void _changeMonth(int amount) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + amount,
      );
      final lastDay = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
        0,
      ).day;
      _selectedDate = DateTime(
        _visibleMonth.year,
        _visibleMonth.month,
        _selectedDate.day.clamp(1, lastDay).toInt(),
      );
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _visibleMonth = DateTime(now.year, now.month);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  Future<void> _createEntry(CalendarEntryType type) async {
    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => _CreateCalendarEntryDialog(
          type: type,
          date: _selectedDate,
          onSave: widget.repository.addEntry,
        ),
      );
      if (saved != true || !mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type.label} added to the shared calendar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Could not finish creating a calendar entry: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not complete this calendar action. Refresh and check the schedule before trying again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteEntry(CalendarEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: Text('Delete ${entry.type.label.toLowerCase()}?'),
        content: Text(
          '“${entry.title}” will be removed from the shared calendar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.repository.deleteEntry(entry.id);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${entry.type.label} removed from the calendar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not delete this entry. Refresh the schedule and try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 680;
    return FutureBuilder<List<CalendarEntry>>(
      future: _entriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('The schedule could not be loaded.'),
                const SizedBox(height: 8),
                TextButton(onPressed: _reload, child: const Text('Try again')),
              ],
            ),
          );
        }

        final entries = snapshot.data ?? const [];
        return LayoutBuilder(
          builder: (context, constraints) {
            final sideBySide = constraints.maxWidth >= 980;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 18 : 32,
                vertical: compact ? 20 : 30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ScheduleHeader(
                        staffPreview: _staffPreview,
                        onStaffPreviewChanged: (value) =>
                            setState(() => _staffPreview = value),
                        onCreateEvent: () =>
                            _createEntry(CalendarEntryType.event),
                        onCreateBooking: () =>
                            _createEntry(CalendarEntryType.booking),
                      ),
                      const SizedBox(height: 20),
                      if (_staffPreview) ...[
                        const _DemoModeNotice(),
                        const SizedBox(height: 16),
                      ],
                      if (sideBySide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: _buildCalendar(entries)),
                            const SizedBox(width: 18),
                            Expanded(
                              flex: 5,
                              child: _DayAgenda(
                                date: _selectedDate,
                                entries: _entriesForDate(
                                  entries,
                                  _selectedDate,
                                ),
                                staffPreview: _staffPreview,
                                onDelete: _deleteEntry,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildCalendar(entries),
                        const SizedBox(height: 18),
                        _DayAgenda(
                          date: _selectedDate,
                          entries: _entriesForDate(entries, _selectedDate),
                          staffPreview: _staffPreview,
                          onDelete: _deleteEntry,
                        ),
                      ],
                      const SizedBox(height: 20),
                      const _CalendarLegend(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendar(List<CalendarEntry> entries) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    MaterialLocalizations.of(context)
                        .formatMonthYear(_visibleMonth),
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              TextButton(onPressed: _goToToday, child: const Text('Today')),
              IconButton(
                tooltip: 'Next month',
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _monthGrid(entries),
        ],
      ),
    ),
  );

  Widget _monthGrid(List<CalendarEntry> entries) {
    // Sunday is column zero, matching the weekday labels below. Dart numbers
    // weekdays Monday=1 through Sunday=7, so modulo 7 gives Sunday=0.
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month);
    final firstColumn = firstOfMonth.weekday % DateTime.daysPerWeek;
    final dates = List.generate(
      42,
      (index) => DateTime(
        _visibleMonth.year,
        _visibleMonth.month,
        index - firstColumn + 1,
      ),
    );
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Table(
      children: [
        TableRow(
          children: [
            for (final day in weekdays)
              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (var week = 0; week < 6; week++)
          TableRow(
            children: [
              for (var weekday = 0; weekday < DateTime.daysPerWeek; weekday++)
                _buildDayCell(
                  dates[week * DateTime.daysPerWeek + weekday],
                  entries,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildDayCell(DateTime date, List<CalendarEntry> entries) {
    if (date.month != _visibleMonth.month) {
      // Blank out spillover dates so they cannot be mistaken for dates in the
      // displayed month. Month navigation is available in the header.
      return const SizedBox(height: 62);
    }

    return SizedBox(
      height: 62,
      child: _CalendarDayCell(
        date: date,
        entries: _entriesForDate(entries, date),
        isInMonth: true,
        isSelected: _sameDay(date, _selectedDate),
        isToday: _sameDay(date, DateTime.now()),
        onTap: () => setState(() => _selectedDate = date),
      ),
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  const _ScheduleHeader({
    required this.staffPreview,
    required this.onStaffPreviewChanged,
    required this.onCreateEvent,
    required this.onCreateBooking,
  });

  final bool staffPreview;
  final ValueChanged<bool> onStaffPreviewChanged;
  final VoidCallback onCreateEvent;
  final VoidCallback onCreateBooking;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Schedule', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 5),
        Text(
          'Events and facility reservations at Hadlock.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            if (staffPreview) ...[
              OutlinedButton.icon(
                onPressed: onCreateEvent,
                icon: const Icon(Icons.event_outlined),
                label: const Text('Add event'),
              ),
              FilledButton.icon(
                onPressed: onCreateBooking,
                icon: const Icon(Icons.add),
                label: const Text('Add booking'),
              ),
            ],
          ],
        ),
        TextButton.icon(
          onPressed: () => onStaffPreviewChanged(!staffPreview),
          icon: Icon(
            staffPreview
                ? Icons.admin_panel_settings
                : Icons.visibility_outlined,
          ),
          label: Text(staffPreview ? 'Exit staff preview' : 'Staff preview'),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 620
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 14), controls],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                const SizedBox(width: 16),
                controls,
              ],
            ),
    );
  }
}

class _DemoModeNotice extends StatelessWidget {
  const _DemoModeNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer
          .withValues(alpha: .55),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Staff preview is for exploring the prototype. Real staff access must come from the authenticated account and be enforced by the API.',
          ),
        ),
      ],
    ),
  );
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.entries,
    required this.isInMonth,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final List<CalendarEntry> entries;
  final bool isInMonth;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = isSelected
        ? Theme.of(context).colorScheme.primaryContainer
        : Colors.transparent;
    final visibleEntries = entries.take(3).toList();
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isToday ? Border.all(color: primary, width: 1.3) : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isInMonth
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant
                              .withValues(alpha: .45),
                    fontWeight: isSelected || isToday
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 2,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final entry in visibleEntries)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _entryColor(context, entry.type),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayAgenda extends StatelessWidget {
  const _DayAgenda({
    required this.date,
    required this.entries,
    required this.staffPreview,
    required this.onDelete,
  });

  final DateTime date;
  final List<CalendarEntry> entries;
  final bool staffPreview;
  final ValueChanged<CalendarEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    final formattedDate = MaterialLocalizations.of(context)
        .formatFullDate(date);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              entries.isEmpty
                  ? 'No events or facility bookings.'
                  : '${entries.length} ${entries.length == 1 ? 'item' : 'items'} on the schedule',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (entries.isEmpty) ...[
              const SizedBox(height: 18),
              const _EmptyDay(),
            ] else ...[
              const SizedBox(height: 12),
              for (final entry in entries) ...[
                _AgendaEntry(
                  entry: entry,
                  showDelete: staffPreview,
                  onDelete: () => onDelete(entry),
                ),
                if (entry != entries.last) const Divider(height: 22),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _AgendaEntry extends StatelessWidget {
  const _AgendaEntry({
    required this.entry,
    required this.showDelete,
    required this.onDelete,
  });

  final CalendarEntry entry;
  final bool showDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = _entryColor(context, entry.type);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 58,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _EntryTypeTag(type: entry.type),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatTime(context, entry.startsAt)} – ${_formatTime(context, entry.endsAt)} · ${entry.location}',
              ),
              if (entry.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  entry.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showDelete)
          IconButton(
            tooltip: 'Delete ${entry.type.label.toLowerCase()}',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    );
  }
}

class _EntryTypeTag extends StatelessWidget {
  const _EntryTypeTag({required this.type});

  final CalendarEntryType type;

  @override
  Widget build(BuildContext context) {
    final color = _entryColor(context, type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        type.label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(
          Icons.event_available_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        const Text('It’s open so far.'),
      ],
    ),
  );
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 18,
    runSpacing: 8,
    children: [
      _LegendItem(type: CalendarEntryType.event),
      _LegendItem(type: CalendarEntryType.booking),
      Text(
        'Personal equipment rentals belong in My Rentals.',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.type});

  final CalendarEntryType type;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: _entryColor(context, type),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 7),
      Text(type.label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _CreateCalendarEntryDialog extends StatefulWidget {
  const _CreateCalendarEntryDialog({
    required this.type,
    required this.date,
    required this.onSave,
  });

  final CalendarEntryType type;
  final DateTime date;
  final Future<void> Function(CalendarEntry entry) onSave;

  @override
  State<_CreateCalendarEntryDialog> createState() =>
      _CreateCalendarEntryDialogState();
}

class _CreateCalendarEntryDialogState
    extends State<_CreateCalendarEntryDialog> {
  static const _bookingLocations = [
    'Court 1',
    'Court 2',
    'Court 3',
    'Main gym',
    'Multi-purpose room',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 14, minute: 0);
  String? _formError;
  String _bookingLocation = _bookingLocations.first;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (_sameDay(widget.date, now)) {
      final suggestedStart = now.add(const Duration(minutes: 30));
      if (_sameDay(widget.date, suggestedStart)) {
        _startTime = TimeOfDay.fromDateTime(suggestedStart);
        final suggestedEnd = suggestedStart.add(const Duration(hours: 1));
        if (_sameDay(widget.date, suggestedEnd)) {
          _endTime = TimeOfDay.fromDateTime(suggestedEnd);
        } else {
          _formError = 'This date has less than one hour remaining. Choose another date.';
        }
      } else {
        _formError =
            'This date has less than one hour remaining. Choose another date.';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool start}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (selected == null) return;
    setState(() {
      _formError = null;
      if (start) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
    });
  }

  DateTime _atTime(TimeOfDay time) => DateTime(
    widget.date.year,
    widget.date.month,
    widget.date.day,
    time.hour,
    time.minute,
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final startsAt = _atTime(_startTime);
    final endsAt = _atTime(_endTime);
    if (!endsAt.isAfter(startsAt)) {
      setState(() => _formError = 'The end time must be after the start time.');
      return;
    }
    if (startsAt.isBefore(DateTime.now())) {
      setState(() => _formError = 'Choose a future date and time.');
      return;
    }

    final entry = CalendarEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: widget.type == CalendarEntryType.booking
          ? _bookingLocation
          : _locationController.text.trim(),
      type: widget.type,
      startsAt: startsAt,
      endsAt: endsAt,
    );

    setState(() {
      _isSaving = true;
      _formError = null;
    });
    try {
      await widget.onSave(entry);
      if (mounted) Navigator.pop(context, true);
    } on CalendarValidationException catch (error) {
      if (mounted) setState(() => _formError = error.message);
    } on CalendarConflictException catch (error) {
      if (mounted) setState(() => _formError = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _formError = 'Could not save this entry. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Add ${widget.type.label.toLowerCase()}'),
    content: SizedBox(
      width: 480,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  MaterialLocalizations.of(context).formatFullDate(widget.date),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 90,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a title.'
                    : null,
              ),
              const SizedBox(height: 10),
              if (widget.type == CalendarEntryType.booking)
                DropdownButtonFormField<String>(
                  initialValue: _bookingLocation,
                  decoration: const InputDecoration(
                    labelText: 'Court, room, or facility',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final location in _bookingLocations)
                      DropdownMenuItem(value: location, child: Text(location)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _bookingLocation = value;
                        _formError = null;
                      });
                    }
                  },
                )
              else
                TextFormField(
                  controller: _locationController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a location.'
                      : null,
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                maxLength: 400,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(start: true),
                      icon: const Icon(Icons.schedule),
                      label: Text('Start ${_startTime.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(start: false),
                      icon: const Icon(Icons.schedule),
                      label: Text('End ${_endTime.format(context)}'),
                    ),
                  ),
                ],
              ),
              if (_formError != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'This entry appears on the shared calendar. Do not include private renter details here.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _isSaving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _isSaving ? null : _submit,
        child: _isSaving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Add to calendar'),
      ),
    ],
  );
}

List<CalendarEntry> _entriesForDate(
  List<CalendarEntry> entries,
  DateTime date,
) {
  final forDate = entries
      .where((entry) => _sameDay(entry.startsAt, date))
      .toList();
  forDate.sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return forDate;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatTime(BuildContext context, DateTime dateTime) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(dateTime),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );

Color _entryColor(BuildContext context, CalendarEntryType type) =>
    switch (type) {
      CalendarEntryType.event => Theme.of(context).colorScheme.primary,
      CalendarEntryType.booking => const Color(0xFF35734A),
    };

extension on CalendarEntryType {
  String get label => switch (this) {
    CalendarEntryType.event => 'Event',
    CalendarEntryType.booking => 'Booking',
  };
}
