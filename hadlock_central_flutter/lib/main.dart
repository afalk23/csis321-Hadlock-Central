import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/data/announcement_repository.dart';
import 'package:hadlock_central_flutter/data/calendar_repository.dart';
import 'package:hadlock_central_flutter/data/equipment_repository.dart';
import 'package:hadlock_central_flutter/pages/announcements.dart';
import 'package:hadlock_central_flutter/pages/schedule_page.dart';
import 'package:hadlock_central_flutter/pages/equipment_page.dart';
import 'package:hadlock_central_flutter/pages/home_page.dart';
import 'package:hadlock_central_flutter/pages/sign_in_page.dart';
import 'package:hadlock_central_flutter/models/student_account.dart';

//Run with this command in terminal: flutter run -d chrome --web-port=58173

/// The main function is the entry point of the application. It runs the HadlockCentralApp widget.
void main() => runApp(const HadlockCentralApp());

/// Destination class represents a navigation destination with a label and an icon.
const _destinations = <Destination>[
  Destination('Home', Icons.home_outlined),
  Destination('Schedule', Icons.calendar_month_outlined),
  Destination('Equipment', Icons.sports_basketball_outlined),
  Destination('Announcements', Icons.mail_outline),
];

/// HadlockCentralApp is a StatelessWidget that sets up the MaterialApp with theme and home page.
class HadlockCentralApp extends StatelessWidget {
  const HadlockCentralApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// The build method constructs the UI for the HadlockCentralApp widget.
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 43, 53, 239),
      surface: const Color.fromARGB(239, 252, 243, 229),
    );

    /// The MaterialApp widget is the root of the application, setting up theme and home page.
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

      /// Start at sign-in before opening the app shell.
      home: const SignInPage(),
    );
  }
}

/// AppShell is a StatefulWidget that manages the main navigation and content of the application.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.account});

  final StudentAccount account;

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _selectedIndex = 1;
  final AnnouncementRepository _announcementRepository =
      InMemoryAnnouncementRepository();
  final CalendarRepository _calendarRepository = InMemoryCalendarRepository();
  final EquipmentRepository _equipmentRepository =
      InMemoryEquipmentRepository();

  @override
  Widget build(BuildContext context) {
    /// The build method constructs the UI for the AppShell widget, managing navigation and content display.
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final page = switch (_selectedIndex) {
      0 => HomePage(
        announcementRepository: _announcementRepository,
        onOpenAnnouncements: () => select(3),
      ),
      1 => SchedulePage(
        repository: _calendarRepository,
        equipmentRepository: _equipmentRepository,
        account: widget.account,
      ),
      2 => EquipmentPage(
        repository: _equipmentRepository,
        account: widget.account,
        onOpenSchedule: () => select(1),
      ),
      3 => AnnouncementsPage(repository: _announcementRepository),
      _ => PlaceholderPage(destination: _destinations[_selectedIndex]),
    };

    /// The Scaffold widget provides the basic visual structure for the AppShell, including navigation and
    /// content display.
    return Scaffold(
      appBar: wide
          ? null
          : AppBar(
              title: const Brand(),
              backgroundColor: Theme.of(context).colorScheme.surface,
              actions: [
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),

      /// The body of the Scaffold contains a Row that arranges the navigation rail and the main content
      /// area side by side.
      body: Row(
        children: [
          /// If the screen width is wide enough, a NavigationRail is displayed for navigation between different
          /// sections of the application.
          if (wide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: select,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.fromLTRB(12, 22, 12, 26),
                child: Brand(vertical: true),
              ),
              trailing: IconButton(
                tooltip: 'Sign out',
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
              ),
              trailingAtBottom: true,
              destinations: [
                for (final destination in _destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    label: Text(destination.label),
                  ),
              ],
            ),

          /// The VerticalDivider widget provides a visual separation between the navigation rail and
          /// the main content area.
          if (wide) const VerticalDivider(width: 1),
          Expanded(child: page),
        ],
      ),

      /// The bottomNavigationBar property provides a navigation bar for smaller screens,
      /// allowing users to switch between
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

  /// Returns to sign-in and removes the app shell from the navigation stack.
  void _signOut() {
    // This prototype has no server session to revoke; clear the app routes only.
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      (route) => false,
    );
  }
}
