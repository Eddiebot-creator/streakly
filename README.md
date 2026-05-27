# Streakly

Streakly is a premium Flutter habit operating system for Android and Windows. It helps users design advanced routines, complete habits offline or online, protect streaks with recovery tools, review performance heatmaps, join challenges, compare leaderboard progress, and sync their data with Firebase.

The current interface uses a clean Streakly design system inspired by the imported FlutterFlow export: a light slate background, white rounded cards, indigo primary actions, green success states, amber highlights, and responsive layouts for mobile and desktop.

## Features
- Premium onboarding with goal selection and starter habit templates
- Firebase email authentication and user profiles
- Firestore-backed habit storage and leaderboard data
- Daily completion tracking with current and best streaks
- Today Command Center with progress, heatmap, achievements, and habit actions
- Habit Studio with search, active/due/paused/archived filters, quick actions, and offline status
- Advanced habit builder with custom weekdays, every-X-days, monthly habits, pause mode, difficulty, priority, notes, tags, quantity goals, timer goals, checklist mode, and location cues
- Rich habit detail pages with streak history, calendar heatmap, reflection notes, freeze recovery, duplicate, archive, pause, edit, and completion actions
- Offline-first cache with optimistic local create, edit, delete, and completion behavior while cloud sync is unavailable
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
