# Visitor Management App

A Flutter-based Visitor Management application designed to simplify visitor registration, manage visitor records, generate QR codes, and support visitor check-in and check-out workflows through a REST API.

## Project Overview

The Visitor Management App provides a structured way to register visitors, view their information, and manage visitor entry and exit status. It integrates with a MockAPI backend for visitor data operations and uses QR codes to identify registered visitors.

The application is developed using Flutter and Dart, follows the BLoC pattern for state management, and uses GoRouter for navigation.

## Features

- **Dashboard:** View the visitor management dashboard.
- **Visitor Registration:** Register visitors using the registration form and available validation.
- **Visitor List:** Retrieve and display visitor records from the API.
- **Visitor Details:** View information about registered visitors.
- **Visitor Editing:** Update existing visitor records.
- **Visitor Deletion:** Delete visitor records through the API.
- **QR Code Generation:** Generate a QR code using a visitor's unique ID.
- **QR Code Scanning:** Scan visitor QR codes using the device camera.
- **Check-in and Check-out:** Support visitor status workflows implemented in the application.
- **REST API Integration:** Retrieve, create, update, and delete visitor records.
- **Splash Screen:** Display an introductory screen when the application launches.
- **Bottom Navigation:** Navigate between the Dashboard, Visitors, and QR Scanner screens.
- **Error Handling:** Handle API responses, request failures, and JSON parsing errors in the API service.

## Technology Stack

| Technology / Package | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| flutter_bloc | BLoC state management |
| go_router | Application navigation and routing |
| http | HTTP requests to the REST API |
| MockAPI | Mock backend for visitor data |
| qr_flutter | QR code generation |
| mobile_scanner | QR code scanning |
| intl | Date and time formatting |
| equatable | Value equality|

Refer to `pubspec.yaml` for the project's actual dependencies and versions.

## Prerequisites

Before running the project, install:

- Flutter SDK compatible with the project's SDK constraints
- Dart SDK included with Flutter
- Android Studio and Android SDK
- An Android emulator or physical Android device
- Git, if cloning the repository

Verify your Flutter installation:

```bash
flutter doctor
```

Check your Flutter and Dart versions:

```bash
flutter --version
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/amey-flutterdeveloper/visitor_management_app.git
cd visitor_management_app
```

Alternatively, open the existing project directory in Android Studio.

### 2. Install Dependencies

Run this command from the project root:

```bash
flutter pub get
```

### 3. Configure the Mock API

The application uses the following MockAPI base URL:

`https://6ae03e448e42963c8d5f305b.mockapi.io/api/v1`

The visitor resource endpoint is:

`https://6ae03e448e42963c8d5f305b.mockapi.io/api/v1/visitors`

The API base URL is configured in:

`lib/data/visitor_api.dart`

### API Operations

| HTTP Method | Endpoint | Description |
|---|---|---|
| GET | `/visitors` | Retrieve all visitors |
| GET | `/visitors/{id}` | Retrieve a visitor by ID |
| POST | `/visitors` | Register a new visitor |
| PUT | `/visitors/{id}` | Update an existing visitor |
| DELETE | `/visitors/{id}` | Delete a visitor |

These are the expected API operations. Their availability depends on the implemented API service and MockAPI resource configuration.

The API must be accessible over the internet for visitor data operations. Verify the endpoint and required operations before submission.

### 4. Run the Application

Connect an Android device or start an emulator.

Check available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

## Project Structure

The main application files are organized as follows:

```text
visitor_management_app/
├── android/
├── lib/
│   ├── core/
│   │   └── app_theme.dart
│   ├── data/
│   │   ├── visitor_api.dart
│   │   └── visitor_repository.dart
│   ├── logic/
│   │   ├── scanner/
│   │   │   ├── scanner_bloc.dart
│   │   │   ├── scanner_event.dart
│   │   │   └── scanner_state.dart
│   │   └── visitor/
│   │       ├── visitor_bloc.dart
│   │       ├── visitor_event.dart
│   │       └── visitor_state.dart
│   ├── models/
│   │   └── visitor.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── ui/
│   │   ├── widgets/
│   │   │   └── common_widgets.dart
│   │   ├── app_shell.dart
│   │   ├── dashboard_page.dart
│   │   ├── scanner_page.dart
│   │   ├── splash_page.dart
│   │   ├── visitor_details_page.dart
│   │   ├── visitor_form_page.dart
│   │   └── visitor_list_page.dart
│   ├── util/
│   │   └── visitor_enum.dart
│   └── main.dart
├── screenshots/
│   ├── 01_dashboard.jpeg
│   ├── 02_visitor_list.jpeg
│   ├── 03_visitor_registration.jpeg
│   ├── 04_visitor_details_qr.jpeg
│   └── 05_qr_scanner.jpeg
├── test/
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

This structure is a reference. Ensure the files and screenshot names match the actual project before submission.

## Visitor Registration Workflow

1. Launch the application.
2. Navigate to the visitor registration screen.
3. Enter the required visitor information.
4. Complete the available form validation.
5. Submit the registration form.
6. Save the visitor record through the REST API.
7. Open the visitor details screen after successful registration.
8. View the visitor's QR code.
9. Scan the QR code and use the available visitor status workflow.

The QR code uses the visitor's unique ID returned by the API.

## State Management and Architecture

The application uses the BLoC pattern through the `flutter_bloc` package.

- **UI Layer:** Displays application screens and handles user interactions.
- **BLoC Layer:** Processes visitor-related events and manages application state.
- **Events:** Represent actions such as loading, registering, or updating visitor records.
- **States:** Represent loading, success, data, and error conditions as implemented.
- **Repository Layer:** Provides an abstraction between BLoC and API operations.
- **API Service:** Performs HTTP requests and handles response parsing and HTTP errors.
- **Models:** Represent visitor data and support JSON serialization.
- **Router:** Manages navigation between application screens.
- **Theme:** Defines reusable application styling.

This architecture helps separate the user interface, application logic, and data operations.

## Screenshots

### Dashboard

![Dashboard](screenshots/01_dashboard.jpeg)

### Visitor List

![Visitor List](screenshots/02_visitor_list.jpeg)

### Visitor Registration

![Visitor Registration](screenshots/03_visitor_registration.jpeg)

### Visitor Details and QR Code

![Visitor Details and QR Code](screenshots/04_visitor_details_qr.jpeg)

### QR Scanner

![QR Scanner](screenshots/05_qr_scanner.jpeg)

## Build an Android APK

To create a release APK, run:

```bash
flutter build apk --release
```

The generated APK is normally located at:

`build/app/outputs/flutter-apk/app-release.apk`

Install and test the release APK on an Android device before submission.

## Run Tests and Static Analysis

Run automated tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Review any errors and verify the main application workflows before submitting the project.

## API Information

**MockAPI Base URL**

`https://6ae03e448e42963c8d5f305b.mockapi.io/api/v1`

**Visitor Resource**

`/visitors`

Use the visitor endpoint to inspect the available sample records. The actual JSON fields depend on the visitor model and the records configured in MockAPI.

The evaluator needs internet access to test API-dependent functionality. Verify that the endpoint is reachable and the required operations work before submission.

## Known Limitations

- The application depends on the availability of the configured MockAPI service.
- QR scanning requires camera permission on the Android device.
- Visitor records depend on the configured mock backend and its resource configuration.
- API-dependent features may not work without an internet connection.
- Any additional limitations discovered during testing should be documented here.

## Repository

GitHub: [Visitor Management App](https://github.com/amey-flutterdeveloper/visitor_management_app)

## Project Information

- **Project:** Visitor Management App
- **Platform:** Flutter
- **Programming Language:** Dart
- **State Management:** BLoC (`flutter_bloc`)
- **Navigation:** `go_router`
- **Backend:** MockAPI REST API
- **QR Code Generation:** `qr_flutter`
- **QR Code Scanning:** `mobile_scanner`
