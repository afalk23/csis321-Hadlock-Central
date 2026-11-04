import '../models/announcement.dart';

/// Storage boundary for announcements. Replace this with an HTTP backed
/// implementation when the API is ready; the screen does not depend on storage.
abstract interface class AnnouncementRepository {
  Future<List<Announcement>> getAnnouncements();

  Future<void> publish(Announcement announcement);
}

class InMemoryAnnouncementRepository implements AnnouncementRepository {
  InMemoryAnnouncementRepository()
    : _announcements = [
        Announcement(
          id: 'welcome-week',
          title: 'Welcome Week at Hadlock',
          body: 'Kick off the semester with free drop-in activities at the Student Center. Try the climbing wall, join an open gym session, or stop by the front desk to see what is happening each day.',
          category: AnnouncementCategory.event,
          audience: AnnouncementAudience.everyone,
          publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
          author: 'Hadlock Staff',
          isPinned: true,
        ),
        Announcement(
          id: 'climbing-wall-hours',
          title: 'Climbing wall hours this week',
          body: 'The climbing wall is open Monday through Friday from 3:00–8:00 PM. Please bring your student ID and complete the waiver at the front desk before your first climb.',
          category: AnnouncementCategory.facility,
          audience: AnnouncementAudience.everyone,
          publishedAt: DateTime.now().subtract(const Duration(days: 1)),
          author: 'Recreation Team',
        ),
        Announcement(
          id: 'intramural-registration',
          title: 'Intramural registration is open',
          body: 'Build a team or sign up as a free agent for this semester’s intramural league. Registration closes Friday at 5:00 PM. Visit the front desk if you need help finding a team.',
          category: AnnouncementCategory.program,
          audience: AnnouncementAudience.students,
          publishedAt: DateTime.now().subtract(const Duration(days: 2)),
          author: 'Campus Recreation',
        ),
        Announcement(
          id: 'gym-maintenance',
          title: 'Court 2 unavailable Tuesday morning',
          body: 'Court 2 will be closed from 8:00 AM to noon on Tuesday for routine floor maintenance. The other courts remain open as usual. Thanks for your patience.',
          category: AnnouncementCategory.alert,
          audience: AnnouncementAudience.everyone,
          publishedAt: DateTime.now().subtract(const Duration(days: 3)),
          author: 'Hadlock Staff',
        ),
      ];

  final List<Announcement> _announcements;

  @override
  Future<List<Announcement>> getAnnouncements() async =>
      List.unmodifiable(_announcements);

  @override
  Future<void> publish(Announcement announcement) async {
    _announcements.insert(0, announcement);
  }
}
