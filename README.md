# Streakly

Streakly is a polished Flutter habit tracker for Android and Windows. It helps users create daily routines, complete habits, protect streaks, review statistics, join challenges, compare leaderboard progress, and sync their data with Firebase.

The current interface uses a clean Streakly design system inspired by the imported FlutterFlow export: a light slate background, white rounded cards, indigo primary actions, green success states, amber highlights, and responsive layouts for mobile and desktop.

## Features
- Firebase email authentication and user profiles
- Firestore-backed habit storage and leaderboard data
- Daily completion tracking with current and best streaks
- Dashboard progress summary, quick stats, and habit actions
- Habit management with categories, icons, frequency, and reminders
- Statistics, insights, challenges, settings, and CSV export
- Local notification support for reminders
- Responsive Android and Windows layouts

## Run
```powershell
flutter pub get
flutterfire configure
flutter run -d windows
# or
flutter run -d android
```

## Firebase collections
- users
- habits
- completions

## Important
Run `flutterfire configure` to generate `lib/firebase_options.dart` before running with Firebase.
