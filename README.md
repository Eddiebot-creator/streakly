# Streakly

Streakly is a polished Flutter habit tracker for Android and Windows. It helps users create daily routines, complete habits, protect streaks, review statistics, join challenges, compare leaderboard progress, and sync their data with Firebase.

The current interface uses a clean Streakly design system inspired by the imported FlutterFlow export: a light slate background, white rounded cards, indigo primary actions, green success states, amber highlights, and responsive layouts for mobile and desktop.

## Features
- Premium onboarding with goal selection and starter habit templates
- Firebase email authentication and user profiles
- Firestore-backed habit storage and leaderboard data
- Daily completion tracking with current and best streaks
- Today Command Center with progress, heatmap, achievements, and habit actions
- Habit management with categories, icons, frequency, and reminders
- Statistics, insights, challenges, settings, privacy controls, and CSV export
- Local notification support for reminders
- Responsive Android and Windows layouts

## Product Quality
- GitHub Actions CI workflow for analyze, tests, and Windows debug builds
- Firestore security rules included in `firestore.rules`
- Privacy policy in `PRIVACY.md`
- Product roadmap in `ROADMAP.md`
- Changelog in `CHANGELOG.md`

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
