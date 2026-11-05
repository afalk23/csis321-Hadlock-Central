enum AnnouncementCategory { event, facility, program, alert }

enum AnnouncementAudience { everyone, students, staff }

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.audience,
    required this.publishedAt,
    required this.author,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String body;
  final AnnouncementCategory category;
  final AnnouncementAudience audience;
  final DateTime publishedAt;
  final String author;
  final bool isPinned;
}
