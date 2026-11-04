# Hadlock Central — Project Handoff

Use this note to bring a new contributor or future Codex session up to speed. It records the current product direction and implementation as of November 3, 2026. Update it as team decisions change.

## Product goal

Hadlock Central is a student and staff app for the Hadlock Student Center. The project aims to bring facility announcements, events, reservations, equipment availability, and staff workflows into one place. The product should make information easier to find and reduce the need to maintain separate communication channels.

The intended architecture is:

```text
Flutter app  →  Python/Flask REST API  →  MongoDB
                                      ↘ notification provider (later)
```

The Flutter app owns presentation and user input. The API should own authorization, business rules, persistence, and integrations such as email. The Flutter app should not connect directly to MongoDB or hold database credentials.

## Roles and shared experience

- Students and staff should see the same general announcements and center information.
- Staff accounts will receive additional capabilities, such as creating announcements and notifications and approving reservations.
- The current plan is to accept school accounts ending in `@georgefox.edu` and designate administrator accounts from a manually maintained list in the database.
- The login flow is being developed separately by another team member. There is not yet an agreed login or role interface in this Flutter code, and the app does not yet have separate student and admin areas.
- Continue building the ordinary product pages without assuming a particular login implementation. When authentication is ready, connect staff actions to a role/capability supplied by the authenticated session. Do not treat an email-domain check in the Flutter client as authorization; the API must enforce roles using trusted account data.

## Current announcements implementation

The Flutter app is in `hadlock_central_flutter/`.

- `lib/pages/announcements.dart` contains the responsive announcement feed, search, category filters, pinned sorting, announcement details, and a create form.
- `lib/models/announcement.dart` defines the announcement data model and its category/audience values.
- `lib/data/announcement_repository.dart` defines the storage boundary and provides `InMemoryAnnouncementRepository` with sample data.
- `lib/pages/main.dart` connects Announcements and Schedule to the navigation shell. Home previews the latest announcement.
- The create action is currently available as a demo so the feature can be explored before authentication exists. It writes only to in-memory data. Posts disappear when the app process ends. No email or push delivery is implemented.
- Sample records include an audience label, but the current product decision is that students and staff share the same feed. Audience-specific visibility is not implemented or currently required.

To connect the page to a backend later, add an HTTP implementation of `AnnouncementRepository` that calls the Flask API. Keep the page independent of storage. A likely API shape is `GET /announcements` and staff-authorized `POST /announcements`; settle endpoint names and request/response JSON with the backend contributor before implementing that adapter. The backend should store posts in MongoDB and own notification delivery. Email should be sent only after the API accepts and saves a post.

## Backend and data notes

A Flask/MongoDB login sketch has been shared by the team. It queries `Users` by email and password and returns the matching user document. Treat this as a prototype, not production-ready authentication:

- Never commit a real MongoDB connection string or password. Load secrets from environment configuration and keep them out of Git.
- Do not store or compare plaintext passwords. Store password hashes and verify them using a suitable password-hashing library.
- Do not return the raw MongoDB user document from `/login`; it may contain a password hash or internal fields. Return a limited user representation and an authenticated session/token appropriate to the chosen design.
- Enforce the administrator allowlist and role in the API for every staff-only operation. A client-side email check can improve the form experience but cannot grant authorization.
- Coordinate the login response/session format with Flutter before wiring up role-specific controls.

The project documents MongoDB collections for users, equipment, and bookings/courts/rooms. Announcements need a persistent schema as the API is implemented. A useful initial record includes an ID, title, body, category, author, creation time, and pinned state. Add fields only as the API and team requirements settle; do not rely on the Flutter-only sample schema as a final database contract.

## Sprint 4 expectations


1. Review requirements, architecture, module decomposition, ER model, and coding guidelines.
2. Agree on core features, owners, dependencies, and API/data interfaces.
3. Create a GitHub Issue for each feature or meaningful task. Each issue needs an assignee, clear title, completion criteria, and at least one relevant label.
4. Give every team member at least one meaningful implementation task. Issue management and reviews alone do not meet the implementation requirement.
5. Use focused feature branches, descriptive commits, linked pull requests, and code review before merging.

| Team member | Starting focus from the project plan |
| --- | --- |
| Austin Falk | Flutter frontend and UI |
| Ben Vail | Backend/API |
| Ana Richardson | Database and QA |

Confirm current ownership with the team before treating this table as a final assignment. GitHub Issues, assignees, labels, branches, and pull requests must be created in the shared repository; this handoff note does not substitute for those collaboration records.

## Current app status and likely next steps

- The app shell includes Home, Schedule, Equipment, and Announcements navigation. Equipment remains a placeholder.
- Schedule is an early calendar page; it does not yet load reservations from an API.
- Announcements are a functional UI prototype backed by sample in-memory data.
- Login, durable storage, authorization, reservation approval, equipment workflows, and email/push integrations are not connected in this Flutter app.

Suggested integration sequence:

1. Agree on authentication response fields and how Flutter represents the signed-in user and role.
2. Agree on API contracts for announcements and reservations, including error responses and identifiers.
3. Implement and document persistent backend models and API authorization.
4. Replace the in-memory announcement repository with an HTTP repository while keeping the UI contract stable.
5. Gate staff actions using the authenticated role, then add API-owned email/push delivery.

Keep each step in its own assigned issue and branch, and revise this note when decisions or interfaces change.

## Calendar implementation update — November 3, 2026

The Flutter Schedule page now has a month grid, selectable dates, event and facility-booking indicators, and a selected-day agenda. The screen is designed for a shared student/staff calendar. Public events and facility/court booking blocks belong here; personal equipment checkout history should be shown on a future My Rentals page and should not expose renter identity on the shared calendar.

Calendar code currently lives in:

- `hadlock_central_flutter/lib/pages/schedulePage.dart`: month navigation, date selection, day agenda, add forms, staff preview, and confirmed delete flow.
- `hadlock_central_flutter/lib/models/calendar_entry.dart`: event/booking fields and JSON conversion helpers.
- `hadlock_central_flutter/lib/data/calendar_repository.dart`: `CalendarRepository` interface and sample `InMemoryCalendarRepository` implementation. It checks overlapping entries at the same location and supports deleting by ID.
- `hadlock_central_flutter/lib/pages/main.dart`: Schedule is the app's initial page and receives the shared repository instance.

Staff preview exposes create and delete controls so the UI can be reviewed before login/roles are integrated. Preview is not real authorization: anyone can turn it on. Production create/delete endpoints must validate an authenticated staff role on the server. Delete now confirms before removing an item and reports repository errors.

**Persistence remains unfinished.** New and deleted entries only affect the in-memory demo repository and are lost when the app process restarts. The repo has no implemented calendar API: `data-base-codebase/RENAME-ME.py` is empty. Durable cross-device create/delete requires a Flask API backed by MongoDB, plus the authenticated staff token/session contract from the teammate implementing login. Flutter now has a repository boundary and JSON mapping ready for that API. Do not claim the current staff preview or in-memory delete is secure or permanent.

The current calendar API contract to agree with the backend owner should include:

- `GET /calendar` for public event and facility-booking entries.
- Staff-authorized `POST /calendar` to create an event or facility booking.
- Staff-authorized `DELETE /calendar/{id}` to remove an entry.
- JSON fields matching the calendar model: `id`, `title`, `description`, `location`, `type`, `startsAt`, and `endsAt`. Store timestamps in UTC and convert for display in Flutter.
- Conflict checks in the API for overlapping items at the same resource/location. Do not rely on the Flutter demo repository as the source of truth.

The university rental page/system should only be integrated through a supported API or documented interface with permission. Flutter must not connect directly to its database. If no supported interface is available, store Hadlock Central calendar and facility booking records in the project's own MongoDB through the Flask API, then consider a permitted sync later.

A submission issue was reported while testing in Chrome. The form now displays invalid time/date feedback inline instead of behind the dialog and catches repository errors. Static analysis currently reports no code errors; it still shows the existing naming-style note for `schedulePage.dart`.

## Open integration questions

1. What API base URL and endpoint contract will the backend team provide for calendar reads, creates, and deletes?
2. How will Flutter receive the authenticated user's staff role (token/session claims or another agreed interface)?
3. Is the university rental system exposing a supported API, or should Hadlock Central store its own facility bookings in its project MongoDB?

## Platform setup findings — November 3, 2026

- The actual Flutter package root is `hadlock_central_flutter/`, where `pubspec.yaml`, `lib/main.dart`, and the Android/iOS projects live. Open this folder in Android Studio or VS Code. The repository root has no Flutter `pubspec.yaml`.
- Added `lib/main.dart` as the conventional Flutter entry point. From the Flutter package directory, use `flutter pub get`, `flutter devices`, and `flutter run -d <device-id>`.
- iOS Simulator build verified with Flutter 3.47.5 / Dart 3.13.4 and Xcode 27.0: `flutter build ios --simulator --debug --no-codesign` succeeded. An iPhone 15 / iOS 26.1 simulator profile was absent at first; it was created and booted locally, then `flutter run` installed/launched the app. The simulator profile is local to this Mac, not a repo artifact. The build uses the existing placeholder bundle ID `com.example.hadlaockCentralFlutter`; choose a team-owned unique ID before publishing.
- Android could not be built in this environment because Android Studio/Android SDK is not installed or configured (`flutter doctor -v` reports “Unable to locate Android SDK”). Install Android Studio and its SDK/platform tools/emulator, accept Android SDK licenses, then run `flutter doctor -v`, `flutter devices`, and `flutter run -d <android-device-id>` from `hadlock_central_flutter/`.
- The repository-root `android/`, `ios/`, `macos/`, and `.dart_tool/` paths are unrelated generated scaffolding; root `.gitignore` excludes them. The real platform projects are nested under `hadlock_central_flutter/`.
- Simulator and Android builds validate local execution only. Announcements and calendar data are still in-memory demo data and are not shared across installs until the API/database is deployed.
