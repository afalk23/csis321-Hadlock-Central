import 'package:flutter/material.dart';

import '../data/announcement_repository.dart';
import '../models/announcement.dart';

/// AnnouncementsPage is a StatefulWidget that displays a list of announcements and allows users to filter, search, 
/// and compose new announcements.
class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key, required this.repository});

  final AnnouncementRepository repository;

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

/// _AnnouncementsPageState manages the state of the AnnouncementsPage, including filtering, searching, and 
/// composing announcements.
class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final _searchController = TextEditingController();
  AnnouncementCategory? _selectedCategory;
  late Future<List<Announcement>> _announcementsFuture;

  /// The initState method initializes the state of the AnnouncementsPage, including loading announcements and 
  /// setting up the search controller listener.
  @override
  void initState() {
    super.initState();
    _announcementsFuture = widget.repository.getAnnouncements();
    _searchController.addListener(_refresh);
  }

  /// The didUpdateWidget method is called when the widget is updated, allowing the state to respond to changes 
  /// in the widget.
  @override
  void didUpdateWidget(covariant AnnouncementsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _announcementsFuture = widget.repository.getAnnouncements();
    }
  }

  /// The dispose method cleans up resources when the AnnouncementsPage is removed from the widget tree, including
  /// removing the search controller listener and disposing of the controller.
  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  /// The _refresh method triggers a rebuild of the widget tree when the search controller's text changes.
  void _refresh() {
    if (mounted) setState(() {});
  }

  /// The _loadAnnouncements method reloads the announcements from the repository and updates the state.
  void _loadAnnouncements() {
    setState(() {
      _announcementsFuture = widget.repository.getAnnouncements();
    });
  }

  /// The _composeAnnouncement method opens a dialog for composing a new announcement and handles the publishing.
  Future<void> _composeAnnouncement() async {
    final published = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _ComposeAnnouncementDialog(onPublish: widget.repository.publish),
    );
    if (published != true || !mounted) return;
    _loadAnnouncements();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Announcement published in this demo.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// The build method constructs the UI for the AnnouncementsPage, including search, filtering, and displaying 
  /// announcements.
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 680;
    return LayoutBuilder(
      /// The LayoutBuilder widget allows the UI to adapt to different screen sizes, providing a responsive layout.
      builder: (context, constraints) => SingleChildScrollView(
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
                _PageHeader(onCompose: _composeAnnouncement, compact: compact),
                const SizedBox(height: 18),
                const _DemoNotice(),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search announcements',
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
                      borderSide: const BorderSide(color: Color(0xFFE5E7E3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7E3)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _CategoryFilters(
                  selected: _selectedCategory,
                  onSelected: (category) =>
                      setState(() => _selectedCategory = category),
                ),
                const SizedBox(height: 22),
                FutureBuilder<List<Announcement>>(
                  future: _announcementsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return _LoadError(onRetry: _loadAnnouncements);
                    }

                    final announcements = _filterAnnouncements(
                      snapshot.data ?? const [],
                    );
                    if (announcements.isEmpty) {
                      return const _EmptyAnnouncements();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${announcements.length} ${announcements.length == 1 ? 'announcement' : 'announcements'}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 12),
                        for (final announcement in announcements) ...[
                          _AnnouncementCard(
                            announcement: announcement,
                            onTap: () => _showAnnouncement(announcement),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The _filterAnnouncements method filters the list of announcements based on the selected category and search query.
  List<Announcement> _filterAnnouncements(List<Announcement> all) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = all.where((announcement) {
      final matchesCategory =
          _selectedCategory == null ||
          announcement.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          announcement.title.toLowerCase().contains(query) ||
          announcement.body.toLowerCase().contains(query) ||
          announcement.author.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.publishedAt.compareTo(a.publishedAt);
    });
    return filtered;
  }

  /// The _showAnnouncement method displays a dialog with the details of the selected announcement.
  void _showAnnouncement(Announcement announcement) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          _AnnouncementDetailsDialog(announcement: announcement),
    );
  }
}

/// The _PageHeader widget displays the header section of the AnnouncementsPage, including the title, description, 
/// and a button to create a new announcement.
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onCompose, required this.compact});

  final VoidCallback onCompose;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Announcements',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'The latest news, events, and updates from Hadlock.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
    final button = FilledButton.icon(
      onPressed: onCompose,
      icon: const Icon(Icons.add),
      label: const Text('Create announcement'),
    );
    return compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 16), button],
          )
        : Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 16),
              button,
            ],
          );
  }
}

/// _DemoNotice is a widget that displays a notice indicating that the app is in demo mode, and 
/// announcements are sample content.
class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer
          .withValues(alpha: .55),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Demo mode: announcements are sample content and new posts are stored only while the app is open. Email and audience delivery are not connected yet.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

/// _CategoryFilters is a widget that displays a horizontal list of filter chips for selecting announcement categories.
class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.selected, required this.onSelected});

  final AnnouncementCategory? selected;
  final ValueChanged<AnnouncementCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All updates',
            selected: selected == null,
            onSelected: () => onSelected(null),
          ),
          for (final category in AnnouncementCategory.values)
            _FilterChip(
              label: category.label,
              selected: selected == category,
              onSelected: () => onSelected(category),
            ),
        ],
      ),
    );
  }
}

/// _FilterChip is a widget that represents a single filter chip for selecting an announcement category.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      side: BorderSide(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : const Color(0xFFE5E7E3),
      ),
    ),
  );
}

/// _AnnouncementCard is a widget that displays a card representing an announcement, including its title, body, 
/// and metadata.
class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement, required this.onTap});

  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(context, announcement.category);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Tag(
                    label: announcement.category.label,
                    color: categoryColor,
                  ),
                  if (announcement.isPinned)
                    const _Tag(label: 'Pinned', icon: Icons.push_pin_outlined),
                  _Tag(
                    label: announcement.audience.label,
                    icon: Icons.people_outline,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                announcement.title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                announcement.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 17,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      announcement.author,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  Text(
                    _formatDate(announcement.publishedAt),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// _Tag is a widget that displays a small tag with a label, optional color, and optional icon, used for 
/// categorizing announcements.
class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.color, this.icon});

  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// _AnnouncementDetailsDialog is a dialog that displays the details of a selected announcement, including its title,
/// body, and metadata.
class _AnnouncementDetailsDialog extends StatelessWidget {
  const _AnnouncementDetailsDialog({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) => AlertDialog(
    contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
    title: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Tag(
          label: announcement.category.label,
          color: _categoryColor(context, announcement.category),
        ),
        if (announcement.isPinned)
          const _Tag(label: 'Pinned', icon: Icons.push_pin_outlined),
      ],
    ),
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '${announcement.author} • ${_formatDate(announcement.publishedAt)} • ${announcement.audience.label}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              announcement.body,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}

/// _ComposeAnnouncementDialog is a dialog that allows users to compose and publish a new announcement, including
/// input fields for title, body, category, audience, and pinning options.
class _ComposeAnnouncementDialog extends StatefulWidget {
  const _ComposeAnnouncementDialog({required this.onPublish});

  final Future<void> Function(Announcement announcement) onPublish;

  @override
  State<_ComposeAnnouncementDialog> createState() =>
      _ComposeAnnouncementDialogState();
}

class _ComposeAnnouncementDialogState
    extends State<_ComposeAnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  AnnouncementCategory _category = AnnouncementCategory.event;
  AnnouncementAudience _audience = AnnouncementAudience.everyone;
  bool _isPinned = false;
  bool _isPublishing = false;
  String? _formError;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final announcement = Announcement(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      category: _category,
      audience: _audience,
      publishedAt: DateTime.now(),
      author: 'Hadlock Staff (demo)',
      isPinned: _isPinned,
    );

    setState(() {
      _isPublishing = true;
      _formError = null;
    });
    try {
      await widget.onPublish(announcement);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _formError = 'Could not publish this announcement. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create announcement'),
    content: SizedBox(
      width: 500,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compose a clear update for the Hadlock community.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                maxLength: 90,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Add a title.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                minLines: 4,
                maxLines: 7,
                maxLength: 1200,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Share the details people need to know.',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Add a message.'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AnnouncementCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final value in AnnouncementCategory.values)
                    DropdownMenuItem(value: value, child: Text(value.label)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AnnouncementAudience>(
                initialValue: _audience,
                decoration: const InputDecoration(
                  labelText: 'Audience',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final value in AnnouncementAudience.values)
                    DropdownMenuItem(value: value, child: Text(value.label)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _audience = value);
                },
              ),
              const SizedBox(height: 4),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPinned,
                onChanged: (value) =>
                    setState(() => _isPinned = value ?? false),
                title: const Text('Pin to top of the feed'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              Text(
                'Publishing is local to this demo. No email or push notification will be sent.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _isPublishing ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton.icon(
        onPressed: _isPublishing ? null : _submit,
        icon: const Icon(Icons.publish_outlined),
        label: _isPublishing
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Publish'),
      ),
    ],
  );
}

/// _EmptyAnnouncements is a widget that displays a message indicating that there are no announcements to show.
class _EmptyAnnouncements extends StatelessWidget {
  const _EmptyAnnouncements();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(34),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 38,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'No matching updates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            Text('Try another search or choose a different category.'),
          ],
        ),
      ),
    ),
  );
}

/// _LoadError is a widget that displays an error message and a retry button when announcements fail to load.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined),
          const SizedBox(width: 12),
          const Expanded(child: Text('Announcements could not be loaded.')),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

/// _formatDate formats a DateTime object into a human-readable string, indicating whether the date is today, 
/// yesterday, or a specific date.
String _formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final publishedDay = DateTime(date.year, date.month, date.day);
  if (publishedDay == today) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    return 'Today, $hour:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}';
  }
  if (publishedDay == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// _categoryColor returns a color associated with a specific announcement category, used for visual distinction.
Color _categoryColor(BuildContext context, AnnouncementCategory category) =>
    switch (category) {
      AnnouncementCategory.event => const Color(0xFF1D5F91),
      AnnouncementCategory.facility => const Color(0xFF35734A),
      AnnouncementCategory.program => const Color(0xFF7952A0),
      AnnouncementCategory.alert => const Color(0xFFB24F2D),
    };

/// The following extensions provide human-readable labels for the AnnouncementCategory and AnnouncementAudience enums.
extension on AnnouncementCategory {
  String get label => switch (this) {
    AnnouncementCategory.event => 'Events',
    AnnouncementCategory.facility => 'Facility',
    AnnouncementCategory.program => 'Programs',
    AnnouncementCategory.alert => 'Alerts',
  };
}

extension on AnnouncementAudience {
  String get label => switch (this) {
    AnnouncementAudience.everyone => 'Everyone',
    AnnouncementAudience.students => 'Students',
    AnnouncementAudience.staff => 'Staff',
  };
}
