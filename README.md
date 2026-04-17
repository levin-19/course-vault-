# CourseVault Authentication Module (Week 3-4)

This module implements:
- Email/password signup and login
- Form validation and error handling
- Persistent session using Firebase Auth
- Logout
- User profile view/update (name and password)
- Firestore-backed user profile storage

## Project Structure

```text
lib/
  main.dart
  models/
    app_user.dart
  providers/
    auth_provider.dart
  services/
    auth_service.dart
    profile_service.dart
  screens/
    auth_gate.dart
    login_screen.dart
    signup_screen.dart
    profile_screen.dart
  widgets/
    custom_text_field.dart
    primary_button.dart
```

## Setup Steps

1. Install dependencies:
   - `flutter pub get`
2. Create a Firebase project and add Android/iOS app configs:
   - Android: place `google-services.json` in `android/app/`
   - iOS: place `GoogleService-Info.plist` in `ios/Runner/`
3. Enable **Authentication > Sign-in method > Email/Password** in Firebase Console.
4. Enable **Cloud Firestore** and create database rules as needed.
5. Run the app:
   - `flutter run`

## Firestore Data Model

Collection: `users`
Document ID: Firebase UID
Fields:
- `uid` (string)
- `name` (string)
- `email` (string)
- `avatarUrl` (string | null)

## Key Behavior

- Auth session is automatically restored by Firebase Auth.
- On signup, app creates a Firestore user profile document.
- On login, app fetches Firestore profile data.
- Profile screen lets user update name and optional password.
- Password update handles Firebase errors (for example, recent-login required).
