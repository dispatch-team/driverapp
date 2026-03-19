# Dispatch Driver App

A Flutter mobile application built with **GetX** for state management, routing, and dependency injection.

## Prerequisites

- [FVM](https://fvm.app/) (Flutter Version Management)
- Android Studio / Xcode (for emulators)

This project uses **FVM** to pin the Flutter version. The required version is defined in `.fvmrc` (currently `3.38.3`).

## Getting Started

```bash
# Clone the repository
git clone https://github.com/dispatch-team/driverapp
cd driverapp

# Install the pinned Flutter version via FVM
fvm install

# Install dependencies
fvm flutter pub get

# Run the app
fvm flutter run
```


## Key Packages

| Package | Purpose |
|---|---|
| `get` | State management, routing, DI |
| `firebase_core` | Firebase initialization |
| `dio` | HTTP client for REST APIs |
| `pretty_dio_logger` | Debug logging for API calls |

## Architecture

The app follows a **feature-based modular architecture** using GetX conventions.

### Data Flow

```
View  →  Controller  →  Provider  →  ApiClient (Dio) / Firebase
```

- **Views** display UI and react to state changes via `Obx`.
- **Controllers** hold business logic and reactive state (`.obs`).
- **Providers** handle raw data access (API calls, Firebase queries).
- **ApiClient** is a shared Dio wrapper used by providers — controllers never touch it directly.

### Dependency Injection

GetX bindings manage dependency lifecycles:

- **AppBinding** — registers global singletons (e.g., `ApiClient`) at app startup.
- **Feature bindings** (e.g., `HomeBinding`) — lazy-load controllers when a route is navigated to.

### Routing

Named routes are defined centrally:

- `AppRoutes` — route name constants.
- `AppPages` — maps routes to their page widget and binding.

Navigation: `Get.toNamed(AppRoutes.home)`

## Project Structure

```
lib/
├── main.dart                     # Entry point — Firebase init, runs App
├── firebase_options.dart         # Generated Firebase config
│
├── app/
│   ├── app.dart                  # GetMaterialApp — theme, routes, global binding
│   ├── bindings/
│   │   └── app_binding.dart      # Global dependency registration
│   └── routes/
│       ├── app_routes.dart       # Route name constants
│       └── app_pages.dart        # Route-to-page mapping
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart    # App-wide constants (URLs, keys, timeouts)
│   ├── theme/
│   │   ├── app_colors.dart       # Color palette
│   │   └── app_theme.dart        # Material 3 light theme
│   ├── utils/
│   │   ├── logger.dart           # Debug-only logging utility
│   │   └── validators.dart       # Reusable form validators
│   └── services/
│       └── api_client.dart       # Dio HTTP client with logging
│
├── data/
│   ├── models/                   # Data models / DTOs
│   ├── providers/                # Raw data sources (API, Firebase)
│   └── repositories/            # Optional: combines providers, adds caching
│
└── modules/
    └── home/                     # Example feature module
        ├── home_view.dart        # UI
        ├── home_controller.dart  # Logic & state
        └── home_binding.dart     # DI for this module
```

## Adding a New Feature

1. Create a folder under `lib/modules/` (e.g., `profile/`).
2. Add `profile_view.dart`, `profile_controller.dart`, and `profile_binding.dart`.
3. Add a route constant in `app_routes.dart`.
4. Register the page in `app_pages.dart`.
