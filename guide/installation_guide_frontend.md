# Frontend Installation Guide

This document provides detailed instructions for setting up and running the WAH4P Frontend Flutter application.

## Prerequisites and Third-Party Applications

Ensure the following tools are installed on your development machine:

1. Flutter SDK: Version 3.9.2 or higher.
2. Dart SDK: Included with Flutter.
3. Google Chrome: For web testing and debugging.
4. Android Studio: For Android emulation and build tools.
5. Xcode (macOS only): For iOS simulation and build tools.

## Setup Instructions

### 1. Verify Flutter Installation

Run the Flutter doctor command to ensure all required components are installed and configured correctly.

```bash
flutter doctor
```
Resolve any issues reported by the doctor before proceeding.

### 2. Install Dependencies

Navigate to the frontend directory and fetch the necessary Flutter packages.

```bash
cd frontend
flutter pub get
```

### 3. Environment Configuration

Copy the example environment file to create your local configuration.

```bash
cp .env.example .env
```

Open the `.env` file and configure the necessary variables, such as API endpoints matching your backend configuration.

### 4. Running the Application

You can run the application on different platforms depending on your requirements.

To run on Chrome (Web) using the specific port configured for the project:

```bash
flutter run -d chrome --web-port 3046
```

To run on an Android emulator or physical device:

```bash
flutter run -d android
```

To run on an iOS simulator (macOS only):

```bash
flutter run -d ios
```

### 5. Building the Application (APK)

To build a release APK for Android deployment:

```bash
flutter build apk --release
```

The generated APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

### 6. Running Tests

To execute the widget and unit tests for the frontend application:

```bash
flutter test
```
