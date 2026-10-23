# Dependencies Audit

This document inventories the third-party libraries and runtime packages declared in `pubspec.yaml`, their architectural role, usage analysis, and compatibility status.

---

## 1. SDK Environment Constraints

* **Flutter SDK Constraint:** `>=3.5.3 <4.0.0`
* **Dart SDK Constraint:** `>=3.5.3 <4.0.0`

---

## 2. Production Dependencies

| Package Name | Declared Version | Category | Purpose in Project | Active Usage | Compatibility & Audit Notes |
|--------------|------------------|----------|-------------------|--------------|-----------------------------|
| `flutter` | SDK | Framework | Core Flutter framework | Core | Standard |
| `cupertino_icons` | `^1.0.8` | UI / Icons | iOS-style iconography | Active | Standard icon set |
| `flutter_bloc` | `^8.1.6` | State Management | Reactive BLoC/Cubit state management | Active | Used across `ExpenseCubit` and `SubscriptionCubit` |
| `firebase_core` | `^3.6.0` | Cloud Backend | Firebase app initialization | Active | Initialized in `main()` with platform options |
| `firebase_auth` | `^5.3.1` | Authentication | User sign-in, registration, authStateChanges stream | Active | Used in `AuthScreen`, `FirebaseService`, `SubscriptionService` |
| `cloud_firestore` | `^5.4.4` | Database | Real-time multi-tenant NoSQL cloud database | Active | Used for real-time transactions & subscriptions |
| `intl` | `^0.19.0` | Localization / Formatting | Currency and date formatting (`DateFormat`) | Active | Used in screens, models, and widgets |
| `dio` | `^5.7.0` | Network | HTTP REST client | Active | Used in `CurrencyApi` for foreign exchange rates |
| `fl_chart` | `^0.69.0` | Data Visualization | Pie charts and statistical graphs | Optional/Ready | Used for expense breakdown visualizations |
| `sqflite` | `^2.3.3+1` | Local Storage | SQLite database engine for mobile | Dormant | Configured in `DatabaseHelper` for offline storage |
| `path` | `^1.9.0` | Utilities | Cross-platform filesystem path manipulation | Active | Used by `DatabaseHelper` for SQLite DB path |
| `google_fonts` | `^6.2.1` | UI / Typography | Custom Google typography support | Active | Typography and custom font rendering |

---

## 3. Development Dependencies

| Package Name | Declared Version | Purpose | Active Usage | Audit Notes |
|--------------|------------------|---------|--------------|-------------|
| `flutter_test` | SDK | Testing | Unit and widget test framework | Active | Used in `test/widget_test.dart` |
| `flutter_lints` | `^4.0.0` | Code Quality | Recommended linter rules for Flutter | Active | Defined in `analysis_options.yaml` |

---

## 4. Assets and Native Assets Declarations

In `pubspec.yaml`:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icon/
```
* **Audit Finding (Fixed):** The application originally had `appIcon.jpeg` referenced in `AuthScreen` without declaring the `assets/icon/` folder in `pubspec.yaml`. This was corrected during the audit, and standard resolution image assets were generated.

---

## 5. Dependency Audit Findings & Recommendations

1. **No Outdated Breaking Changes:** All package versions (`flutter_bloc ^8.1.6`, `cloud_firestore ^5.4.4`, `firebase_core ^3.6.0`, `dio ^5.7.0`) are modern, null-safe, and compatible with Flutter 3.x and Dart 3.x.
2. **Dormant SQLite Dependency:** `sqflite` is declared and implemented in `DatabaseHelper`. While it currently does not run in the active Cubit stream path, it is intentionally retained for planned offline caching.
3. **No Unused Bloat:** No unnecessary or abandoned packages (such as legacy HTTP plugins or deprecated state management tools) exist in the codebase.
