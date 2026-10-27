import 'package:flutter/material.dart';
import 'package:hadlaock_central_flutter/pages/schedulePage.dart';

void main() => runApp(const HadlockCentralApp());

const _destinations = <_Destination>[
  _Destination('Home', Icons.home_outlined),
  _Destination('Schedule', Icons.calendar_month_outlined),
  _Destination('Equipment', Icons.sports_basketball_outlined),
  _Destination('Announcements', Icons.mail_outline),
];

class HadlockCentralApp extends StatelessWidget {
  const HadlockCentralApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 43, 53, 239),
      surface: const Color.fromARGB(233, 252, 243, 229),
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MaterialApp(
        title: 'Hadlock Central',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: scheme,
          scaffoldBackgroundColor: scheme.surface,
          appBarTheme: const AppBarTheme(centerTitle: false),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE5E7E3)),
            ),
          ),
        ),
        home: const _AppShell(),
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final page = _selectedIndex == 0
        ? const _HomePage()
        : _PlaceholderPage(destination: _destinations[_selectedIndex]);

    return Scaffold(
      appBar: wide
          ? null
          : AppBar(
              title: const _Brand(),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.fromLTRB(12, 22, 12, 26),
                child: _Brand(vertical: true),
              ),
              destinations: [
                for (final destination in _destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    label: Text(destination.label),
                  ),
              ],
            ),
          if (wide) const VerticalDivider(width: 1),
          Expanded(child: page),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _select,
              destinations: [
                for (final destination in _destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    label: destination.label,
                  ),
              ],
            ),
    );
  }

  void _select(int index) => setState(() => _selectedIndex = index);
}

class _HomePage extends StatelessWidget {
  const _HomePage();

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
                  _FacilityCard(compact: compact),
                  const SizedBox(height: 28),
                  Text(
                    'Quick access',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  _QuickLinks(compact: compact),
                  const SizedBox(height: 30),
                  Text(
                    'Latest updates',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  const _AnnouncementCard(),
                  const SizedBox(height: 14),
                  const _EventCard(),
                  const SizedBox(height: 28),
                  Text(
                    'No live schedule, or equipment data is connected.',
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

// class SchedulePage extends StatelessWidget {
//   const SchedulePage{(super.key)};
// }

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({required this.compact});
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

class _QuickLink {
  const _QuickLink(this.title, this.subtitle, this.icon, this.destinationIndex);
  final String title;
  final String subtitle;
  final IconData icon;
  final int destinationIndex;
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final links = const [
      _QuickLink(
        'Reservations',
        'Browse spaces and times',
        Icons.event_available_outlined,
        1,
      ),
      _QuickLink(
        'Equipment',
        'Check item availability',
        Icons.sports_basketball_outlined,
        2,
      ),
      _QuickLink(
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

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({required this.link});
  final _QuickLink link;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.findAncestorStateOfType<_AppShellState>()?._select(
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

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard();
  @override
  Widget build(BuildContext context) => _InfoCard(
    icon: Icons.campaign_outlined,
    title: 'Announcements will show here',
    detail: 'Staff updates can be brought into one place for students and employees.',
    tag: 'Updates',
  );
}

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

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.destination});
  final _Destination destination;

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

class _Brand extends StatelessWidget {
  const _Brand({this.vertical = false});
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

class _DemoLabel extends StatelessWidget {
  const _DemoLabel();
  @override
  Widget build(BuildContext context) =>
      const _StatusPill(label: 'LOCAL DEMO • SAMPLE CONTENT');
}

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

class _Destination {
  const _Destination(this.label, this.icon);
  final String label;
  final IconData icon;
}
