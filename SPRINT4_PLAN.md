# Hadlock Central - Feature Assignment Plan

**Course:** CSIS 321 - Software Engineering  
**Project:** Hadlock Central  
**Repository:** https://github.com/afalk23/csis321-Hadlock-Central  
**Team Members:** Austin Falk, Ben Vail, Ana Richardson

## 1. Project Overview

Hadlock Central is a Flutter-based web and mobile application designed to provide George Fox University students with a centralized platform for accessing campus resources, including equipment, scheduling, announcements, and account management.

This document outlines the primary responsibilities of each team member and organizes the major features of the application. While each feature has a primary owner, development is collaborative, and team members may contribute to multiple areas of the project.

## 2. Team Responsibilities

### Ana Richardson - Backend API and Authentication

**Primary Responsibilities:**
- Backend API development and integration
- Connecting Flutter frontend functionality to backend endpoints
- Registration and sign-in functionality
- Form validation and error handling
- Preventing duplicate form submissions
- Testing API requests and responses

**Assigned Features:**
- User registration
- User sign-in
- Required field validation
- George Fox email domain validation
- Authentication error messages
- Login and registration API integration

### Austin Falk - Equipment Functionality and UI

**Primary Responsibilities:**
- Equipment management functionality
- Equipment-related user interfaces
- Supporting Flutter UI development
- Equipment feature testing and debugging

**Assigned Features:**
- Equipment browsing
- Equipment availability
- Equipment checkout
- Equipment-related interface components

### Ben Vail - Flutter UI and Navigation

**Primary Responsibilities:**
- Flutter frontend development
- Main application navigation
- General UI design and layout
- Home page development
- Announcements and scheduling interfaces
- Maintaining consistent UI across pages

**Assigned Features:**
- Main application layout
- Navigation between pages
- Home page interface
- Announcements interface
- Calendar and scheduling interface
- Shared Flutter widgets and UI components

## 3. Feature Assignment Table

| Feature | Primary Owner | Supporting Members |
|---------|---------------|-------------------|
| Backend API Development | Ana | Austin, Ben |
| API Integration | Ana, Ben | Austin |
| User Registration | Ana | Ben |
| User Sign-In | Ana | Ben |
| Authentication Validation | Ana | Ben |
| Error Handling | All Members | All Members |
| Equipment Functionality | Austin | Ana, Ben |
| Equipment UI | Austin | Ben |
| General Flutter UI | Ben | Austin |
| Application Navigation | Ben | Ana |
| Home Page | Ben | Austin |
| Announcements UI | Ben | Austin |
| Calendar and Scheduling UI | Ben | Austin |
| Integration Testing | All Members | All Members |
| Documentation | All Members | All Members |

## 4. Feature Requirements and Acceptance Criteria

### 4.1 User Registration

Requirements:
- Users can create an account with their information.
- Required fields cannot be submitted empty.
- Registration emails must end in `@georgefox.edu`.
- Failed registration attempts display readable error messages.
- Users remain on the registration form after failed attempts.
- Multiple registration requests cannot be submitted simultaneously.
- Successful registration redirects users to the sign-in page.

### 4.2 User Sign-In

Requirements:
- Users can sign in using their email and password.
- Email and password fields cannot be empty.
- Invalid login attempts display appropriate error messages.
- Duplicate submissions are prevented while a request is processing.
- Successful login redirects users to the main application.

### 4.3 Equipment Management

Requirements:
- Users can view available equipment.
- Equipment information is displayed clearly.
- Equipment checkout functionality is supported by the interface.
- Equipment-related pages integrate with the rest of the application.
- Equipment functionality is tested for expected behavior.

### 4.4 Application UI and Navigation

Requirements:
- Users can navigate between the application's main pages.
- The application has a consistent interface.
- Navigation is functional across the Flutter application.
- The home page provides access to major features.
- The UI works in the intended web and mobile environments.

### 4.5 Announcements and Scheduling

Requirements:
- Users can access the announcements page.
- Announcements are displayed in an organized interface.
- Users can access calendar and scheduling information.
- Scheduling features are accessible through application navigation.

### 4.6 Backend API Integration

Requirements:
- Flutter communicates with the backend using API requests.
- Login and registration requests send the expected information.
- API responses are correctly interpreted by the frontend.
- Failed requests are handled appropriately.
- Frontend features are connected to their corresponding backend endpoints as integration progresses.

## 5. Collaboration and Development Process

Although each team member has primary responsibilities, Hadlock Central is developed collaboratively.

The team follows these general practices:

1. Each feature has a primary team member responsible for its development and functionality.
2. Team members may assist with features outside their primary assignments.
3. Frontend and backend components are integrated through team collaboration.
4. Features are tested and debugged as they are implemented.
5. Changes are maintained through the shared GitHub repository.
6. Team members communicate about dependencies between features.

## 6. Current Project Progress

### Implemented or Present in the Project
- Flutter application structure
- Main application navigation
- Home page
- Registration and sign-in interfaces
- Backend login and registration routes
- Equipment interface
- Announcements interface
- Calendar and scheduling interface

### In Progress / Requiring Verification
- Full frontend-to-backend integration
- Equipment checkout workflows
- Persistent data integration
- Authentication improvements and validation testing
- End-to-end testing across application features

## 7. Remaining Tasks

- [ ] Verify registration and sign-in validation.
- [ ] Test backend API connections.
- [ ] Complete equipment functionality and integration.
- [ ] Review Flutter navigation and page layouts.
- [ ] Test announcements and scheduling features.
- [ ] Verify frontend and backend compatibility.
- [ ] Perform final application testing.
- [ ] Review documentation and prepare for submission.

## 8. Summary

The Hadlock Central development responsibilities are organized into three main areas:

- **Ana Richardson:** Backend API integration, authentication, registration, sign-in, and validation.
- **Austin Falk:** Equipment functionality and supporting UI development.
- **Ben Vail:** Flutter UI development, application navigation, and general page design.

While these represent the primary areas of responsibility, all team members contribute to the overall development, testing, and improvement of Hadlock Central.

This document serves as a working summary of feature ownership and team collaboration. Responsibilities may be adjusted as development progresses.
