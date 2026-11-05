import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/data/announcement_repository.dart';
import 'package:hadlock_central_flutter/data/calendar_repository.dart';
import 'package:hadlock_central_flutter/models/announcement.dart';
import 'package:hadlock_central_flutter/pages/announcements.dart';
import 'package:hadlock_central_flutter/pages/schedule_page.dart';
import 'package:hadlock_central_flutter/pages/home_page.dart';

void main() => runApp(const HadlockCentralApp());

const _destinations = <Destination>[
  Destination('Home', Icons.home_outlined),
  Destination('Schedule', Icons.calendar_month_outlined),
  Destination('Equipment', Icons.sports_basketball_outlined),
  Destination('Announcements', Icons.mail_outline),
];

class HadlockCentralApp extends StatelessWidget {
  const HadlockCentralApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 43, 53, 239),
      surface: const Color.fromARGB(233, 252, 243, 229),
    );
    return MaterialApp(
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
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell();

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _selectedIndex = 1;
  final AnnouncementRepository _announcementRepository =
      InMemoryAnnouncementRepository();
  final CalendarRepository _calendarRepository = InMemoryCalendarRepository();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final page = switch (_selectedIndex) {
      0 => HomePage(
        announcementRepository: _announcementRepository,
        onOpenAnnouncements: () => select(3),
      ),
      1 => SchedulePage(repository: _calendarRepository),
      3 => AnnouncementsPage(repository: _announcementRepository),
      _ => PlaceholderPage(destination: _destinations[_selectedIndex]),
    };

    return Scaffold(
      appBar: wide
          ? null
          : AppBar(
              title: const Brand(),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: select,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.fromLTRB(12, 22, 12, 26),
                child: Brand(vertical: true),
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
              onDestinationSelected: select,
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

  void select(int index) => setState(() => _selectedIndex = index);
}