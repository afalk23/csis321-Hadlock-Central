/// This file defines the Announcement model and its associated enums.
enum AnnouncementCategory { event, facility, program, alert }

/// This enum represents the audience for an announcement.
enum AnnouncementAudience { everyone, students, staff }

/// The Announcement class represents an announcement with various properties such as title, body, category, 
/// audience, published date, author, and pin status.
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
