# Restaurant Table Service App

This project is a simple mobile application built with **Flutter** as part of a university course on mobile application development.

The goal of the project is to design a **minimal MVP interface** for an IoT-based restaurant service system where customers can request assistance directly from their table.

## Project Idea

Each restaurant table has a small IoT device (based on **ESP8266 / ESP32-C3**) with:

- a touch button
- RGB LED indicator

The device allows customers to send requests to the restaurant staff.

Interaction logic:

- **Short press** → call a waiter
- **Long press** → request the bill

When a button is pressed, the device sends a request to the system via Wi-Fi, and the mobile application displays the request to the restaurant staff.

## Application Concept

The mobile application is designed for restaurant staff.

The workflow is simple:

1. A customer sits at any free table.
2. The customer presses the button on the table device.
3. A new request appears in the staff application.
4. The first waiter who presses **Accept** becomes responsible for that table.
5. All further requests from that table belong to that waiter.
6. When the service is finished, the waiter closes the table and it becomes free again.

## Features Implemented (Lab 2)

This laboratory focuses on **UI development in Flutter**.

The application currently includes:

- Login screen
- Registration screen
- Main dashboard
- Profile screen
- Navigation between screens
- Reusable custom widgets
- Adaptive layout for different screen sizes

The UI demonstrates the basic structure of the system and the interaction flow for restaurant staff.

## Main Screens

### Login
Staff authentication screen.

### Register
Allows creating a staff account.

### Home (Tables Dashboard)
Main interface where staff can see:

- new table requests
- tables already assigned to them
- table statuses

### Profile
Displays basic information about the staff member.

## Technologies

- Flutter
- Dart
- Material Design
