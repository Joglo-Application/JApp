# Resto POS

A Point of Sale application for restaurants built with Flutter.

## Tech Stack

### Flutter Version
- **Flutter**: 3.41.7 (stable)
- **Dart SDK**: ^3.11.5

### State Management
- **Provider** `^6.1.2` — app-wide state management via `ChangeNotifier` and `Consumer` widgets.

### Local Database
- **Hive** `^2.2.3` + **hive_flutter** `^1.1.0` — lightweight, key-value NoSQL database for local persistence.
- Code generation via `hive_generator` and `build_runner`.

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation (for Hive adapters)
dart run build_runner build

# Run the app
flutter run
```
