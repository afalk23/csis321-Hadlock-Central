[productbacklog.md](https://github.com/user-attachments/files/33234837/productbacklog.md)
# Product Backlog

## Requirements & User Stories 

| ID | Information | Priority | Story Points | Dependencies |
| ----- | ----- | ----- | ----- | ----- |
| TS-01 | As a developer, I want a database with collections for users, equipment, bookings, and events so that every feature has a place to store its data. | High | 3 | None |
| TS-02 | As a developer, I want a Python API connected to a database so that the Flutter app can read and write data. | High | 3 | TS-01 |
| TS-03 | As a developer, I want a Flutter app that navigates between screens so that important screens have a place to live. | High | 3 | None |
| TS-04 | As an HSC employee, I want our current rental equipment loaded into the database so that the app shows our real inventory. | High | 2 | TS-01 |
| US-01 | As a student, I want to log in with my account so that I can access my personal rentals. | High | 5 | TS-02, TS-03 |
| US-02 | As an HSC employee, I want staff-only features restricted to staff accounts so that students cannot change any important information. | High | 3 | US-01 |
| US-03 | As a student, I want to see which equipment is available so that I know what I can borrow before going to the desk. | High | 5 | US-01, TS-04 |
| US-04 | As a student, I want to search and filter equipment by type so that I can find what I need quickly. | Medium | 3 | US-03 |
| US-05 | As a student, I want to request a checkout and see the terms and due time so that I know what I am agreeing to. | High | 5 | US-03 |
| US-06 | As an HSC employee, I want to verify a student's ID and confirm the handoff so that every rental is tied to a student and recorded. | High | 5 | US-05, US-02 |
| US-07 | As an HSC employee, I want to label equipment as returned so that it becomes available to other students. | High | 3 | US-06 |
| US-08 | As an HSC employee, I want students with overdue items to not be able to checkout new equipment so that equipment loss is reduced. | Medium | 3 | US-07 |
| US-09 | As an HSC employee, I want to override checkout times and terms for special events. | Low | 2 | US-06 |
| US-10 | As a student, I want to view a calendar of court availability so that I can pick an open time. | High | 5 | US-01 |
| US-11 | As a student, I want to reserve Court 2 for a date, time, and reason so that I have guaranteed access to the court. | High | 8 | US-10 |
| US-12 | As a student, I want faulty bookings rejected, so that I can quickly rebook the available option. | Medium | 5 | US-11 |
| US-13 | As a student, I want to change or cancel my reservation when my plans change. | Medium | 3 | US-11 |
| US-14 | As an HSC employee, I want to approve or override reservations so that I can handle special cases and borderline requests. | Low | 3 | US-11, US-02 |
| US-15 | As an HSC employee, I want to add an event with a date, time, location, and description so that students can see what is happening at Hadlock. | High | 5 | US-02, US-10 |
| US-16 | As an HSC employee, I want to be told when a new event conflicts with an existing one so that I can choose a different time or location. | Medium | 3 | US-15 |
| US-17 | As a student, I want to view upcoming events and announcements in one place so that I stay informed without checking multiple channels. | High | 3 | US-15 |
| US-18 | As a student, I want a push notification when a new event is added so that I do not miss it. | Medium | 8 | US-15 |
| US-19 | As a student, I want to log in with my GFU credentials so that I do not need a separate account. | Low | 13 | US-01; GFU IT API access (Sprint 1, Risk 1) |

**Totals:** 24 items, 114 story points. High: 14 items / 58 pts. Medium: 6 items / 25 pts. Low: 4 items / 31 pts.

`TS-` items are technical stories written by the developer; `US-` items are user stories.

## Sprint 1 Connection

| Sprint 1 requirement | Backlog items |
|---|---|
| MVP feature 1: Login student and staff) | US-01, US-02 |
| MVP feature 4 / UC1: Equipment checkout | US-03 to US-09 |
| MVP feature 2 / UC2: Court booking | US-10 to US-14 |
| MVP feature 3 / UC3: Add event / announcements | US-15 to US-18 |
| Technical tools (Flutter, Python API, MongoDB) | TS-01 to TS-03 |
| Sprint 1 Risk 1 (GFU IT API) | US-19 (Low until access is confirmed) |

## Priorities

- **High:** The MVP critical path. These items are the foundation (database, API, app skeleton, login) and the core success scenario of each use case. Without them, nothing is possible.
- **Medium:** Items that complete the exception paths of the use cases (search, validation, conflict, overdue blocking, cancellation, push notifications). It still works without them, but is less convenient.
- **Low:** Staff overrides for special cases and the stretch goals from Sprint 1. GFU single sign-on is Low because it is blocked on access from GFU IT.

## Story Points

Uses the Fibonacci-style scale (1, 2, 3, 5, 8, 13) and are relative, with **US-01 Student Login = 5** as the baseline. Each item was compared to that baseline on four factors:

1. **Layers touched:** how many of the database, Python API, and Flutter UI the item changes.
2. **Team unfamiliarity:** Flutter is new to us, so UI items carry more importance.
3. **Number of paths:** success scenario plus the extensions and exceptions from the Sprint 1 use cases.
4. **External dependencies and uncertainty:** items needing outside access or ones that possess unknown design were given high importance. The two 13-point items would be split into smaller stories.
