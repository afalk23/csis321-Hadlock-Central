<p align="center">
  <img alt="header" src="https://shieldcn.dev/header/gradient.svg?title=%E2%9B%B3%EF%B8%8F+Hadlock+-+Central+%F0%9F%8F%8C%EF%B8%8F%E2%80%8D%E2%99%82%EF%B8%8F&amp;subtitle=An+all+in+one+student+center&amp;size=wide&amp;mode=dark&amp;font=jetbrains-mono&amp;image=https%3A%2F%2Flh3.googleusercontent.com%2Fgps-cs-s%2FAHRPTWnPH35fIgspdls_F2xJSSF8z41GGk8i3gCKa1DEkg0b6ZziMR5X4oIoVM_RjM3Cs8TihyIGl1tsU1tuRYou1tvPPl4b0Bg_zxzntCAfqeNGBNXCXx8vGU9qMI69Ymq17BfIjLlj%3Ds1360-w1360-h1020-rw&amp;overlay=.45" />
</p>

## What Are We Building?

Hadlock Central is based on making unifying facility reservations, equipment tracking, event scheduling, and real-time announcements into a single accessible interface.

## Why Are We Building?

This product simplifies resource management for Hadlock Student Center staff and provides students with immediate access to facility status, equipment availability, and event information

## Why Does it Matter?

It makes Hadlock customers less likely to use its resources and wastes resources because rentals and equipment spaces are underused.

## How is the Repository Organized?

Bigger tasks and pre-existing systems we want to integrate will have their own branch and spot in our repo.

<p align="center">
  <a href="https://github.com/afalk23/csis321-Hadlock-Central/graphs/contributors"><img alt="contributors" src="https://shieldcn.dev/contributors/afalk23/csis321-Hadlock-Central.svg?preset=gradient&amp;size=80&amp;names=true&amp;min=3&amp;mode=dark" /></a>
</p>



# **Hadlock Central — Sprint 1: Requirements & Team Policies**

**Project:** Hadlock Central: Universal Student Center Management   
**Team**: Austin Falk, Ben Vail, Ana Richardson; Course: 321 \- A   
**Status**: Living document — v1.0 (Sprint 1\)   
---

## **1\. Team Info**

### **1.1 Team Members & Roles**

| Name | Role | Responsibilities |
| ----- | ----- | ----- |
| Austin Falk | Scrum Masters \+ Stakeholder liaison | Stakeholder Liaison, Vision & Strategy, Sprint Execution |
| Ben Vail | Scrum Masters \+ Back end lead | Facilitating Events, Coaching, Sprint Execution |
| Ana Richardson | Scrum Masters \+ Data base and QA lead | Sprint Execution, Quality Control, Removing Impediments |

### **1.2 Project Artifacts**

* Git repository: [Hadlock-Central Link](https://github.com/afalk23/csis321-Hadlock-Central)   
* Project board [Trello](https://trello.com/b/HBZdkDNa)  
* Living document [here]()

### **1.3 Communication Channels & Rules**

| Channel | Purpose | Expected response time | Rules |
| :---- | :---- | :---- | :---- |
| Groupchat | Coordination/Quick responses | within 24h | Be Respectful |
| Email | Sharing Documents | Review within 24h |  |
| In-person/Weekly meeting | Sprint planning,  group work | Within 10min of scheduled meeting | If you can't make it, share beforehand |

---

## **2\. Project Description**

### **2.1 Project Proposal**

**Abstract:** Hadlock Central is a central app designed to streamline key aspects of Hadlock for both students and staff. By combining facility reservations, equipment tracking, event scheduling, and real-time announcements into a single application, the system reduces friction caused by differing communication channels. Hadlock Central allows staff to manage resources efficiently while providing students a reliable way to access all Hadlock has to offer from one place.

**Goal:** The goal of this project is to create an application that simplifies the process of managing resources for Hadlock Student Center staff and provides students easy access to facility status, equipment availability, and event information. The system directly tackles operational disorganization, misplaced equipment, and a lack of knowledge about events.

**As-Is:** Currently, Hadlock relies on a decentralized set of tools. Lots of the systems are currently separate, including reservation systems, static digital calendars, mass emails, social media posts, and physical flyers. This disjointed system forces staff to manually post information across every system, leading to inconsistencies and delayed updates. It is a struggle for some to find current facility hours, equipment availability, or schedule changes, resulting in underutilized resources.

**Innovative Approach:** Rather than replacing the existing infrastructure, Hadlock Central acts as a middleman, tailored specifically to campus recreation workflows. It combines streamlined equipment checkout management and push announcements into a single dashboard. By focusing strictly on the dual needs of student users and staff operators. Hadlock Central delivers a seamless experience tailored to George Fox University.

**Effects:** When successful, Hadlock Central will significantly decrease admin oversight for Hadlock staff and student employees, reduce equipment loss, and boost overall student engagement with recreation. Students will spend less time searching for information and enjoy better access to facility resources.

**Technical Approach:** We will use Flutter to develop the front end of the application. A Python API will run the backend and connect the application to the MongoDB database. Staff and students will have access to the Flutter application and will be able to use different features depending on their role in the app.

**Risks:** The primary technical risk is integrating with existing GFU IT identity and schedule systems without direct API access. To minimize this risk, Hadlock Central will be void of these features at first until API access is confirmed and integrated.

### **2.2 Major Features — MVP**

1. Login feature (student vs. staff)  
2. Scheduling/booking feature  
3. Hadlock announcements feature  
4. Equipment/checkout/tracking feature

### **2.3 Stretch Goals** 

1. Fancy UI Design  
2. User-Oriented Design (room for tweaks in goal)

## **3\. Use Cases / Functional Requirements**

## **Use Case 1: Ben \- Equipment checkout**

* **Actors:** Student, HSC employee  
* **Trigger:** Student approaches the front desk wanting to borrow equipment  
* **Preconditions:** They have no overdue rentals, the equipment is available to rent, the student has their ID on hand  
* **Postconditions:** The equipment is labeled as checked out, the student's ID is connected to their rental (likely the old way of holding it in person), a checkout record is created, showing who has the item.   
* **Main Success Scenario:**   
  * Student opens the app and can view the equipment page  
  * Student selects an available piece of equipment  
  * The checkout terms and times are shown to the Student  
  * Student confirms their checkout request  
  * Student gives their ID to the front desk  
  * Handoff is confirmed  
  * Item is recorded as checked out and is no longer available to other students  
* **Extensions / Variations:** 2a) student searches for an item, 6a) staff overrides the times and terms of the reservation for a special event.  
* **Exceptions:**   
  * Item is not available and shows the student other related items.  
  * Student has overdue items and cannot check out additional items

### **Use Case 2: Court/Room Booking – Austin**

* **Actors:** Student, HSC Employee  
* **Trigger:** Student uses scheduling feature to reserve court two for *x* amount of time  
* **Preconditions:** Student has a valid school email and ID number, no other event is at the same time or conflicts with another, reason for scheduling is allowed(G.F.A)  
* **Postconditions:**The court is reserved for the student during the requested time, the reservation is added to the calendar, and other students can see that the court is unavailable during that time,  
* **Main Success Scenario:**   
  * Student opens app and logs in  
  * Student opens scheduling/calendar  
  * Student selects court two  
  * Student selects the date and time for reservation  
  * Student enters the reason for reservation  
  * The app checks the court is available and that the reservation follows the guide lines  
  * Student confirms reservation  
  * The reservation is added to the calendar  
  * Student receives confirmation that the reservation was successful  
* **Extensions / Variations:**  
  * Student searches for a different available court  
  * Student changes the date and/or time of reservation  
  * HSC employee approves or overrides a reservation  
* **Exceptions:**  
  * Court 2 is already reserved during the requested time and the student is shown other available times or courts  
  * The reason for the reservation is not allowed: system rejects the request and shows the list of allowed reasons  
  * Student tries to reserve a time that has already passed: system rejects the request and prompts for a valid future time

### **Use Case 3: Ana**

* **Actors:** HSC Employee  
* **Trigger:** Employee wants to add an event to the calendar  
* **Preconditions:** Has proper credentials, not something on the calendar at that exact time or location, event has proper information(date, time, location, description)  
* **Postconditions:** The event gets added to the calendar and sends an alert to the students/other employees  
* **Main Success Scenario:**   
  * Employee opens app and logs in  
  * Employee can see the calendar and the Add Event button  
  * Add event button takes Employee to add event page  
  * Employee types correct information on the page  
  * Employee clicks submit   
  * API checks information, then updates calendar  
* **Extensions / Variations:**  
  * Employee goes to add an event, but the event already exists in the calendar  
  * System rejects the addition and displays the conflicting issue.  
* **Exceptions:**  
  * Calendar already has an event that day  
  * Employee does not have access to create events

## **4\. Non-Functional Requirements**

1. **Booking:** Booking equipment/room should only take 3-4 steps  
2. **Privacy:** Students have an independent experience with the app and are unable to connect with other users in the app. The experience is individual  
3. **Performance:** Status changes should be updated frequently to represent the accurate status of equipment

## **5\. Team Process Description**

### **5.1 Toolset**

| Tool | Purpose | Why this tool |
| ----- | ----- | ----- |
| Flutter | App Design and feature | Commonly used in industry, strong learning curve but very effective language to create the product we desire |
| MongoDB | Database | Prior knowledge of how to use it and works for the requirements of this project |
| Python | Backend API | Prior knowledge of how to use it and works well with both Flutter and MongoDB |

### **5.2 Roles & Justification**

| Member | Role  | Why the team needs this role | Why this member fits it |
| ----- | ----- | ----- | ----- |
| Austin Falk | (Stakeholder liaison) | Someone needs to own the UI so features share a consistent design, and the team has one point of contact for feedback from HSC staff/students | Most experience with vision & strategy and stakeholder liaison; natural extension into owning what the user sees |
| Ben Vail | (Backed Lead) | The API is the integration point for every feature (booking, announcements) \- needs one owner so endpoints don't drift out of sync with the frontend | Tasked with facilitating backend. Ownership pairs well with being our technical point of contact  |
| Ana Richardson | (Database & QA Lead (MongoDB)) | Data integrity (equipment status, bookings, events) is the thing most likely to break; someone needs to test each use case | Already tasked with quality control and; directly maps to owning testing and data correctness |

### **5.3 Weekly Schedule / Milestones**

| Week | Austin (Frontend/UI) | Ben (Backend/API) | Ana (Database/QA) |
| :---- | :---- | :---- | :---- |
| 1 | Login screen and app navigation shell built (no live data) | API skeleton with a working login/auth endpoint | MongoDB schema drafted for users, equipment, bookings, events |
| 3 | (court booking) screen functional, no error handling | (equipment checkout) endpoint functional: marks item checked out, creates record | Equipment and user collections live; login flow tested  |
| 4 | (equipment checkout) screen functional, no error handling | UC2 (booking) endpoint functional: conflict-free time slots stored | Booking collection live; conflict logic tested with overlapping requests |

### **5.4 Major Risks**

| \# | Risk | Likelihood / Impact | Mitigation |
| ----- | ----- | ----- | ----- |
| 1 | GFU IT identity/schedule systems lack direct API access | A top tier product is not achieved until systems interact BTS via. API | Modular data abstraction layer; fallback data models; CSV/ICS export-import routines |
| 2 | Scope of this project is quite large and ambitious as is | Not all features can be implemented | Cutting back on desired features and elements creates obtainable ground |
| 3 | Flutter has a large learning curve and could greatly slow progress | Weeks 1-2 become much more difficult given that the language isn’t fully understood | Spend time working on a throw away app before touching any real features |

### **5.5 External Feedback Plan**

* **When:** Getting feedback based on our prototype of the app, will be the most helpful because we will be able to see what design elements are most appealing and which basic features carry importance.  
* **From whom:** Feedback from the staff will be the most beneficial  
* **How:** Allowing staff to try a sample version of the app will give them enough exposure to make a decision regarding their preferences.

