# Bugs and Fixes Audit Log

This document catalogs all defects, compilation and runtime hazards, memory leaks, security oversights, and logic bugs identified during the comprehensive audit, along with their root causes, affected files, applied repairs, and verification statuses.

---

## 1. Summary of Defects

| Bug ID | Severity | Category | Description | Status |
|--------|----------|----------|-------------|--------|
| **BUG-001** | **Critical** | Runtime Crash | Null check operator (`!`) used on unauthenticated user ID causing immediate crash on cold start | **FIXED** |
| **BUG-002** | **Critical** | Network / Security | Missing `INTERNET` permission in Android main manifest (breaking release builds) | **FIXED** |
| **BUG-003** | **High** | Runtime Crash | Strict `double` type casting on Firestore number values (`map['amount'] as double`) causing crashes when integers are returned | **FIXED** |
| **BUG-004** | **High** | Memory Leak | Stream subscriptions in `ExpenseCubit` and `SubscriptionCubit` were never cancelled | **FIXED** |
| **BUG-005** | **High** | Navigation / Deadlock | Root `main.dart` directly routed to `HomeScreen` even when unauthenticated | **FIXED** |
| **BUG-006** | **High** | Syntax / Import | Invalid leading-slash package imports (`import '/constants/colors.dart';`) causing compilation errors | **FIXED** |
| **BUG-007** | **Medium** | Business Logic | `SubscriptionModel.isOverdue()` falsely flagged subscriptions as overdue on the exact day of payment due to time-of-day discrepancy | **FIXED** |
| **BUG-008** | **Medium** | State Management | `SubscriptionCubit.getSubscriptions()` emissions wiped the `upcomingSubscriptions` list on every stream update | **FIXED** |
| **BUG-009** | **Medium** | UI / Layout | Forms (`AddTransactionScreen`, `EditTransactionScreen`) caused RenderFlex pixel overflow when mobile keyboard opened | **FIXED** |
| **BUG-010** | **Medium** | Feature Disconnect | `StatisticsScreen` and `CurrencyScreen` existed in the project but were completely unreachable from navigation | **FIXED** |
| **BUG-011** | **Medium** | UI / Asset Failure | `assets/icon/appIcon.jpeg` was referenced by `AuthScreen` but was missing from filesystem and not declared in `pubspec.yaml` | **FIXED** |
| **BUG-012** | **Low** | Test Failure | Root `test/widget_test.dart` contained the default Flutter template counter test which failed to compile against the real app | **FIXED** |
| **BUG-013** | **Low** | Network Timeout | `Dio` HTTP client in `CurrencyApi` lacked timeouts, risking infinite UI hangs | **FIXED** |

---

## 2. Detailed Defect Investigations and Repairs

### BUG-001: Null Pointer Crash on Unauthenticated Cold Start
* **Severity:** Critical
* **Category:** Runtime Crash / Startup
* **Affected Files:**
  * [firebase_service.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/web_services/firebase_service.dart)
  * [subscription_service.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/web_services/subscription_service.dart)
* **Root Cause:** Both services initialized collection references directly using `_auth.currentUser!.uid`. When an unauthenticated user opened the app, `currentUser` was `null`, throwing an uncaught `Null check operator used on a null value` error.
* **Fix Applied:**
  1. Converted hardcoded collection references into dynamic getters (`_transactionsRef` and `_subscriptionsRef`) that check if `_userId` is non-null.
  2. Changed `getTransactionsStream()` and `getSubscriptionsStream()` to safely return `Stream.value([])` when `_userId == null`.
  3. Added `_auth.authStateChanges()` listeners in Cubits to cleanly re-bind streams upon user login.
* **Status:** Verified & Fixed.

---

### BUG-002: Missing Android INTERNET Permission in Release Manifest
* **Severity:** Critical
* **Category:** Network / Platform Configuration
* **Affected Files:**
  * [AndroidManifest.xml](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/android/app/src/main/AndroidManifest.xml)
* **Root Cause:** The `android.permission.INTERNET` permission was only defined in `android/app/src/debug/AndroidManifest.xml`. In release and profile builds, the app had no internet permission, silently blocking all Firebase and API requests.
* **Fix Applied:** Added `<uses-permission android:name="android.permission.INTERNET"/>` to the main application manifest.
* **Status:** Verified & Fixed.

---

### BUG-003: Numeric Type Casting Crashes in Models
* **Severity:** High
* **Category:** Data Deserialization / Crash
* **Affected Files:**
  * [transaction_model.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/models/transaction_model.dart)
  * [subscription_model.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/models/subscription_model.dart)
* **Root Cause:** When Firestore documents stored integer values (e.g., `amount: 100`), casting directly with `map['amount'] as double` threw `_CastError: type 'int' is not a subtype of type 'double' in type cast`.
* **Fix Applied:** Replaced strict type casting with numeric coercion:
  ```dart
  amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
  ```
* **Status:** Verified & Fixed.

---

### BUG-004: Cubit Stream Listener Memory Leaks
* **Severity:** High
* **Category:** Memory / Performance
* **Affected Files:**
  * [expense_cubit.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/business_logic/cubit/expense_cubit.dart)
  * [subscription_cubit.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/business_logic/cubit/subscription_cubit.dart)
* **Root Cause:** Real-time Firestore streams and auth streams were subscribed to via `.listen(...)` without storing the returned `StreamSubscription` instances or cancelling them in `close()`.
* **Fix Applied:** Added `_transactionsSubscription`, `_subscriptionsSubscription`, and `_authSubscription` fields; cancelled all active subscriptions in `close()`:
  ```dart
  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
  ```
* **Status:** Verified & Fixed.

---

### BUG-005: Premature Navigation to Dashboard Before Auth
* **Severity:** High
* **Category:** Architecture / Navigation Flow
* **Affected Files:**
  * [main.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/main.dart)
* **Root Cause:** The application root `MaterialApp` set `home: const HomeScreen()`, bypassing authentication entirely and rendering empty states with unauthenticated Firestore streams.
* **Fix Applied:** Configured `home: StreamBuilder<User?>` on `FirebaseAuth.instance.authStateChanges()`. If the user is authenticated, it renders `HomeScreen`; otherwise, it renders `AuthScreen`.
* **Status:** Verified & Fixed.

---

### BUG-006: Broken Leading-Slash Imports Across the Codebase
* **Severity:** High
* **Category:** Compilation / Static Analysis
* **Affected Files:** 12 files across `lib/` and `test/`.
* **Root Cause:** Non-standard import paths beginning with leading slashes (e.g. `import '/constants/colors.dart';` and `import '/data/models/transaction_model.dart';`) are rejected by modern Dart compilers.
* **Fix Applied:** Replaced all leading-slash imports with package-relative imports (e.g., `import 'package:personal_expense_tracker/constants/colors.dart';`).
* **Status:** Verified & Fixed.

---

### BUG-007: Billing Due Date Logic Bug (False "Overdue" on Due Date)
* **Severity:** Medium
* **Category:** Business Logic
* **Affected Files:**
  * [subscription_model.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/models/subscription_model.dart)
* **Root Cause:** `isOverdue()` compared full `DateTime` timestamps including hour, minute, and second:
  `return nextBillingDate.isBefore(now);`
  If a subscription was due today, but checked at 2:00 PM, a midnight due date evaluated as "overdue" instead of "due today".
* **Fix Applied:** Normalized comparison to date-only boundaries (`DateTime(now.year, now.month, now.day)`).
* **Status:** Verified & Fixed.

---

### BUG-008: Upcoming Subscriptions Overwritten on Stream Update
* **Severity:** Medium
* **Category:** State Management
* **Affected Files:**
  * [subscription_cubit.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/business_logic/cubit/subscription_cubit.dart)
* **Root Cause:** When `getSubscriptions()` received a new stream emission from Firestore, it emitted `SubscriptionLoaded` with `upcomingSubscriptions: []`, wiping out the upcoming subscriptions calculated by `getUpcomingSubscriptions()`.
* **Fix Applied:** Maintained `_cachedUpcoming` inside `SubscriptionCubit` so stream updates preserve the current upcoming list and re-calculate upcoming dues when subscriptions change.
* **Status:** Verified & Fixed.

---

### BUG-009: Keyboard RenderFlex Pixel Overflows
* **Severity:** Medium
* **Category:** UI / Responsiveness
* **Affected Files:**
  * [add_transaction_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/add_transaction_screen.dart)
  * [edit_transaction_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/edit_transaction_screen.dart)
* **Root Cause:** Form columns were placed inside a non-scrollable `Padding` container. Opening the on-screen numeric keyboard reduced screen height and triggered a yellow/black zebra render overflow error.
* **Fix Applied:** Wrapped the body contents in `SingleChildScrollView(physics: const BouncingScrollPhysics(), ...)`.
* **Status:** Verified & Fixed.

---

### BUG-010: Unreachable Screens (`StatisticsScreen` and `CurrencyScreen`)
* **Severity:** Medium
* **Category:** Navigation / User Experience
* **Affected Files:**
  * [home_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/home_screen.dart)
* **Root Cause:** `StatisticsScreen` and `CurrencyScreen` existed in `lib/presentation/screens/` but were never linked in any menu, AppBar, or navigation route.
* **Fix Applied:** Added AppBar action icons for Pie Chart analytics (`StatisticsScreen`) and Currency Converter (`CurrencyScreen`) on `HomeScreen`.
* **Status:** Verified & Fixed.

---

### BUG-011: Missing Icon Assets
* **Severity:** Medium
* **Category:** Assets / UI
* **Affected Files:**
  * `pubspec.yaml`
  * `assets/icon/`
* **Root Cause:** `assets/icon/appIcon.jpeg` was referenced by `AuthScreen` but was absent from `assets/icon/` and omitted from the `flutter: assets:` bundle list.
* **Fix Applied:** Declared `- assets/icon/` in `pubspec.yaml` and generated standard `appIcon.jpeg` and `icon.png` in `assets/icon/`.
* **Status:** Verified & Fixed.

---

### BUG-012: Broken Default Smoke Test
* **Severity:** Low
* **Category:** Automated Testing
* **Affected Files:**
  * [test/widget_test.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/test/widget_test.dart)
* **Root Cause:** `test/widget_test.dart` was the default template testing `MyApp` with a counter `0 -> 1` which failed immediately because `personal_expense_tracker` requires Firebase and has no counter.
* **Fix Applied:** Replaced with a comprehensive unit test suite covering `TransactionModel`, `SubscriptionModel` billing date calculations, and `AppColors` palette assertions.
* **Status:** Verified & Fixed.

---

### BUG-013: Missing Network Timeouts on HTTP Client
* **Severity:** Low
* **Category:** Networking / Resiliency
* **Affected Files:**
  * [currency_api.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/web_services/currency_api.dart)
* **Root Cause:** The `Dio` HTTP client was instantiated without `BaseOptions`, meaning network requests could hang indefinitely on slow or unresponsive mobile networks.
* **Fix Applied:** Configured 10-second connect and receive timeouts.
* **Status:** Verified & Fixed.
