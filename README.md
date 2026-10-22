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
* Living document [here](https://docs.google.com/document/d/10KF_cN4KRyqI0yxjn0exNhJOC2QAQr199yEGjbM6Rlo/edit?tab=t.0#heading=h.m282nthsljf2)

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

## **6\. Software Architecture**

1. Identify and describe the major software components and their functionality at a conceptual level  
   1. **Flutter Application:** this is the front end of the application. It is comprised of the user interface, some state management, and most importantly, takes in user inputs for the desired equipment rentals and room reservations. It doesn’t process logic or connect to the database itself.   
      **API Server / Backend:** This is the logic between our app and database. It receives user requests from the front end and checks to make sure that the requests either can or can’t go through. It handles reading and writing to the database as well.   
      **MongoDB:** This database will hold the storage for all user profiles, equipment, inventory, and scheduling information. It only interacts with the API  
      External Integration: A third-party system will be connected with the existing Gmail to send notifications as desired by the Hadlock staff.  
   2. **Flutter App & API:** These will communicate together using HTTP/REST. The Flutter app will send methods like GET, POST, PUT, DELETE to create actions that can be delivered to the proper endpoints.   
      **API & MongoDB:** This backend will communicate with the database by transmitting requests over a connection to a MongoDB cluster  
      **API & Notifications:** The backend will send HTTP requests that contain formatted messages that can be sent to the proper API endpoints.  
        
2. Describe in detail what data your system stores, and how. If it uses a database, give the high-level database schema.  
   1. Our system will use a MongoDB database to store the data. It will be stored in one cluster with different collections for each type of entity in the system. There will be a collection of users; each user will have an email address, first and last name, password, and an ID. There will be a collection of equipment that stores each object with its type, quantity, and amount currently rented out. Lastly, there will be a collection for courts and rooms that stores each location, date it is booked for, the time it is booked for, and the description of what it’s booked for.

---

## **7\. Software Design**

Functional Decomposition \-  
[see the decomposition diagram](docs/images/functional-decomposition(1).png)
[clearer viw in the living document](https://docs.google.com/document/d/10KF_cN4KRyqI0yxjn0exNhJOC2QAQr199yEGjbM6Rlo/edit?tab=t.0#heading=h.m282nthsljf2)


Data Modeling \- A detailed and complete ER model  
[see the ER diagram](docs/images/er-diagram.png)
[clearer viw in the living document](https://docs.google.com/document/d/10KF_cN4KRyqI0yxjn0exNhJOC2QAQr199yEGjbM6Rlo/edit?tab=t.0#heading=h.m282nthsljf2)



---

## **8\. Coding Guideline**

[**Effective Dart**](https://dart.dev/effective-dart)

We chose this guideline because it provides a consistent foundation for writing quality Flutter and Dart code. These standards emphasize readability, maintainability, and performance, which are essential for our project. We plan to enforce the guidelines through automated tools and team collaboration. We will use Dart’s built-in linter and formatter to automatically check for style and syntax consistency to ensure that the code is up to standard. Code reviews will also serve as a way to enforce the guidelines, where team members verify that they are following the guidelines as well as share perspectives and offer constructive feedback.  

[**Python Style Guide**](https://jgnanadurai.cs.georgefox.edu/resources/python/gfu-python-style-guide.pdf)

We chose this style guide because we are all familiar with it from taking CSIS 201. This guideline highlights the readability and maintainability that the backend API will need. We plan to enforce this style guide through conscientious coding habits and by double-checking documentation before committing. We will also have code reviews to enforce the guidelines and verify that all code is being properly documented and written.

---


