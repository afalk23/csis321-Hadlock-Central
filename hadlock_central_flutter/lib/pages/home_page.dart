import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/data/announcement_repository.dart';
import 'package:hadlock_central_flutter/models/announcement.dart';
import 'package:hadlock_central_flutter/main.dart';

/// HomePage is a StatelessWidget that serves as the main landing page of the application. 
/// It displays a welcome message, quick access links, and the latest announcements and events. 
/// It uses the provided AnnouncementRepository to fetch and display announcements, and it provides a callback 
/// for navigating to the full announcements page.
class HomePage extends StatelessWidget {
  const HomePage({super.key, 
    required this.announcementRepository,
    required this.onOpenAnnouncements,
  });

  final AnnouncementRepository announcementRepository;
  final VoidCallback onOpenAnnouncements;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 20 : 40,
            vertical: compact ? 24 : 42,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DemoLabel(),
                  const SizedBox(height: 22),
                  Text(
                    'Welcome to Hadlock Central',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A simple starting point for your day at the Student Center.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FacilityCard(compact: compact),
                  const SizedBox(height: 28),
                  Text(
                    'Quick access',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  QuickLinks(compact: compact),
                  const SizedBox(height: 30),
                  Text(
                    'Latest updates',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  _AnnouncementCard(
                    repository: announcementRepository,
                    onOpenAnnouncements: onOpenAnnouncements,
                  ),
                  const SizedBox(height: 14),
                  const _EventCard(),
                  const SizedBox(height: 28),
                  Text(
                    'No live schedule, or equipment data is connected yet.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// FacilityCard is a StatelessWidget that displays information about the facility, including its hours and 
/// current availability.
class FacilityCard extends StatelessWidget {
  const FacilityCard({super.key, required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Facility information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Hours and current availability will appear here when connected.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 18, height: 18),
      const _StatusPill(label: 'Not connected', icon: Icons.cloud_off_outlined),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [content[0], const SizedBox(height: 18), content[2]],
              )
            : Row(children: content),
      ),
    );
  }
}

/// QuickLink represents a quick access link with a title, subtitle, icon, and destination index for navigation.
class QuickLink {
  const QuickLink(this.title, this.subtitle, this.icon, this.destinationIndex);
  final String title;
  final String subtitle;
  final IconData icon;
  final int destinationIndex;
}

class QuickLinks extends StatelessWidget {
  const QuickLinks({super.key, required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final links = const [
      QuickLink(
        'Reservations',
        'Browse spaces and times',
        Icons.event_available_outlined,
        1,
      ),
      QuickLink(
        'Equipment',
        'Check item availability',
        Icons.sports_basketball_outlined,
        2,
      ),
      QuickLink(
        'Announcements',
        'See center updates',
        Icons.campaign_outlined,
        3,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = compact ? 1 : (constraints.maxWidth >= 900 ? 3 : 2);
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final link in links)
              SizedBox(
                width: width,
                child: _QuickLinkCard(link: link),
              ),
          ],
        );
      },
    );
  }
}

/// _QuickLinkCard is a StatelessWidget that represents a card for a quick access link.
class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({required this.link});
  final QuickLink link;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.findAncestorStateOfType<AppShellState>()?.select(
          link.destinationIndex,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                link.icon,
                size: 25,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      link.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// _AnnouncementCard is a StatefulWidget that displays the latest announcement from the provided 
/// AnnouncementRepository.
class _AnnouncementCard extends StatefulWidget {
  const _AnnouncementCard({
    required this.repository,
    required this.onOpenAnnouncements,
  });

  final AnnouncementRepository repository;
  final VoidCallback onOpenAnnouncements;

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard> {
  late Future<List<Announcement>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _announcementsFuture = widget.repository.getAnnouncements();
  }

  @override
  void didUpdateWidget(covariant _AnnouncementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _announcementsFuture = widget.repository.getAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _announcementsFuture,
    builder: (context, snapshot) {
      final announcements = snapshot.data;
      final announcement = announcements == null || announcements.isEmpty
          ? null
          : announcements.first;
      if (announcement == null) {
        return _InfoCard(
          icon: Icons.campaign_outlined,
          title: 'Announcements',
          detail:
              'Hadlock news, events, and facility updates will appear here.',
          tag: 'Updates',
        );
      }
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onOpenAnnouncements,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        announcement.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: widget.onOpenAnnouncements,
                        icon: const Icon(Icons.arrow_forward, size: 17),
                        label: const Text('View all announcements'),
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.sizeOf(context).width > 540) ...[
                  const SizedBox(width: 12),
                  const _StatusPill(label: 'Latest'),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// _EventCard is a StatelessWidget that displays information about upcoming events, including a message
/// indicating that the center calendar is not yet connected.
class _EventCard extends StatelessWidget {
  const _EventCard();
  @override
  Widget build(BuildContext context) => _InfoCard(
    icon: Icons.calendar_today_outlined,
    title: 'Upcoming events',
    detail: 'Connect the center calendar to show events and schedule changes.',
    tag: 'Schedule',
  );
}

/// _InfoCard is a StatelessWidget that displays an informational card with an icon, title, detail, and tag.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.tag,
  });
  final IconData icon;
  final String title;
  final String detail;
  final String tag;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 540) ...[
            const SizedBox(width: 12),
            _StatusPill(label: tag),
          ],
        ],
      ),
    ),
  );
}

/// PlaceholderPage is a StatelessWidget that serves as a placeholder for sections of the application 
/// that are not yet implemented.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.destination});
  final Destination destination;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              destination.icon,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              destination.label,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'This is a placeholder for the ${destination.label} section. It is included to show how the app navigation can grow.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Brand is a StatelessWidget that displays the branding for Hadlock Central, including an icon and text.
class Brand extends StatelessWidget {
  const Brand({super.key, this.vertical = false});
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.sports_gymnastics, color: Colors.white, size: 22),
    );
    final text = Text(
      'Hadlock Central',
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [mark, const SizedBox(height: 10), text],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [mark, const SizedBox(width: 10), text],
    );
  }
}

/// _DemoLabel is a StatelessWidget that displays a label indicating that the application is running in a 
/// local demo mode.
class _DemoLabel extends StatelessWidget {
  const _DemoLabel();
  @override
  Widget build(BuildContext context) =>
      const _StatusPill(label: 'LOCAL DEMO • SAMPLE CONTENT');
}

/// _StatusPill is a StatelessWidget that displays a pill-shaped label with optional icon, used for status 
/// indicators or tags.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 6)],
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );
}

/// Destination represents a navigation destination with a label and an icon, used for navigation rail or menu items.
class Destination {
  const Destination(this.label, this.icon);
  final String label;
  final IconData icon;
}
