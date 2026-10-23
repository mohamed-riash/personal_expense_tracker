# Setup and Run Guide

This guide provides step-by-step instructions for setting up the development environment, configuring Firebase credentials, running the application on emulators or real devices, and building production releases.

---

## 1. Prerequisites

Before running the application, ensure the following tools are installed and present in your operating system's `PATH`:

* **Flutter SDK:** Version `3.5.3` or later (Flutter 3.24+ recommended, Dart `>=3.5.3 <4.0.0`).
* **Java Development Kit (JDK):** JDK 17 or JDK 21 (required by Gradle 8.x).
* **Android Studio / Android SDK:**
  * Android SDK Platform 34 or 35.
  * Android SDK Build-Tools 34.0.0.
  * Android SDK Command-line Tools.
* **Firebase Account:** A project configured in the Firebase Console with:
  * Firebase Authentication (Email/Password provider enabled).
  * Cloud Firestore Database (in Production or Test mode).

---

## 2. Environment Setup & PATH Configuration (Windows)

If `flutter` or `dart` commands are not recognized in your terminal, add Flutter to your User or System `PATH`:

1. Download the Flutter SDK from `https://docs.flutter.dev/get-started/install/windows`.
2. Extract the archive (e.g., to `C:\src\flutter`).
3. Press `Windows Key`, search for "Edit environment variables for your account".
4. Edit the `Path` variable and add:
   ```
   C:\src\flutter\bin
   ```
5. Set `JAVA_HOME` to your JDK path (e.g. `C:\Program Files\Android\Android Studio\jbr` or `C:\Program Files\Java\jdk-17`).
6. Open a new PowerShell terminal and verify:
   ```powershell
   flutter --version
   flutter doctor -v
   ```

---

## 3. Firebase Configuration

The project already contains Firebase configuration files:
* Android: `android/app/google-services.json`
* Dart: `lib/firebase_options.dart`

### To connect your own Firebase project:

1. Install the Firebase CLI:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
2. Activate and run `flutterfire`:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. In the Firebase Console:
   * Go to **Authentication** > **Sign-in method** > Enable **Email/Password**.
   * Go to **Firestore Database** > **Create database**.
   * Set security rules allowing authenticated users to access their subcollections:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /users/{userId}/{document=**} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
     ```

---

## 4. Installing Dependencies

Run inside the project root:

```bash
flutter pub get
```

---

## 5. Running the Application

### 5.1 On Android Device or Emulator

1. Start an Android Virtual Device (AVD) from Android Studio or connect a physical Android device via USB with USB Debugging enabled.
2. Verify device connection:
   ```bash
   flutter devices
   ```
3. Run in debug mode:
   ```bash
   flutter run
   ```

### 5.2 Hot Reload & Hot Restart
* Press `r` in the terminal for Hot Reload.
* Press `R` in the terminal for Hot Restart.
* Press `q` to detach and exit.

---

## 6. Running Tests and Quality Checks

```bash
# Check formatting
dart format --output=none --set-exit-if-changed lib test

# Static analysis
flutter analyze

# Execute unit and widget tests
flutter test
```

---

## 7. Building Releases

### 7.1 Android Debug APK
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### 7.2 Android Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 7.3 Android App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 8. Troubleshooting Common Issues

### Issue: `Null check operator used on a null value` at launch
* **Cause:** Attempting to query Firestore before a user is authenticated.
* **Resolution:** Already resolved in this audit (`BUG-001` & `BUG-005`). Ensure you use the updated `lib/data/web_services/firebase_service.dart` and `lib/main.dart`.

### Issue: `RenderFlex overflowed by ... pixels`
* **Cause:** Forms with on-screen keyboard on smaller screens.
* **Resolution:** Already resolved in this audit (`BUG-009`). Forms now utilize `SingleChildScrollView`.

### Issue: Network calls fail in Release mode
* **Cause:** Missing Android `INTERNET` permission in release manifest.
* **Resolution:** Already resolved in this audit (`BUG-002`).
