# TimeTailor

TimeTailor is a daily scheduling and note-taking mobile application designed to enhance productivity and streamline time management. Built using Flutter, the app leverages direct manipulation for intuitive task scheduling and includes advanced features such as Optical Character Recognition (OCR) and AI-powered note management.

---

## Features

- **Direct Manipulation for Scheduling**: Drag-and-drop interface for task creation and management.
- **Integrated Note-Taking System**: Link notes to tasks for seamless organization.
- **Quick Scheduling**: Create and adjust tasks with minimal effort.
- **Completion History and Undo**: Manage task history and revert completed tasks.
- **OCR Integration**: Convert images into text directly.
- **AI-Powered Note Management**: Summarize, translate, and improve notes with AI.
- **Monochrome UI Theme**: Clean and modern user interface.

---

## Prerequisites

Before running the project, ensure you have the following installed:

1. **Flutter**: Version `3.24.5` (Stable channel)
   - [Install Flutter](https://docs.flutter.dev/get-started/install) if you haven't already.
2. **Dart**: Included with the Flutter SDK.
3. **Android Studio** or **Visual Studio Code**:
   - Install the Flutter and Dart plugins.
4. **Android Emulator** or a physical Android device for testing.
5. **Firebase Setup**:
   - Configure Firebase for authentication (details below).

---

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/your-repo/timetailor.git
cd timetailor
```

### 2. Install Dependencies
Run the following command to fetch the required dependencies:
```bash
flutter pub get
```

### 3. Configure Firebase
1. Add your `google-services.json` file to the `android/app` directory for Firebase configuration.
2. Ensure the Firebase Authentication module is enabled for your project in the Firebase Console.

### 4. Run the Project
- Development was done on Android, so make sure to enable an Android emulator or use a physical Android device before test running the project.
- **For Android**:
  ```bash
  flutter run
  ```
- **For Debugging**:
  Use the `--debug` flag:
  ```bash
  flutter run --debug
  ```

---

## Build APK

To build the APK for the app:

- Debug APK:
  ```bash
  flutter build apk --debug
  ```

- Profile APK:
  ```bash
  flutter build apk --profile
  ```

- Release APK:
  ```bash
  flutter build apk --release
  ```

The APK will be located in the `build/app/outputs/flutter-apk/` directory.

### Navigate to the APK
- For the profile APK, navigate to:
  ```
  build/app/outputs/flutter-apk/app-profile.apk
  ```

### Install the APK on Your Device
1. Connect your Android device to your computer via USB.
2. Ensure USB debugging is enabled on your device.
3. Use the following command to install the APK:
   ```bash
   adb install build/app/outputs/flutter-apk/app-profile.apk
   ```

---

## Troubleshooting

- If you encounter any issues with dependencies, ensure you have the correct version of Flutter (`3.24.5`) installed.
- Clear the build cache if needed:
  ```bash
  flutter clean
  flutter pub get
  ```

---

## Contribution

This is a final-year project and not open for contributions at the moment.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Author

**Yu**  
Degree in Software Engineering (Honours)  
Tunku Abdul Rahman University of Management and Technology (TARUMT)
