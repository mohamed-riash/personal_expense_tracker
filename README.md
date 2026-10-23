# Personal Expense Tracker & Subscription Manager

A modern, responsive, and robust personal finance mobile application built with **Flutter**, **BLoC / Cubit**, and **Firebase**.

The application empowers users to monitor their personal finances in real-time, track recurring subscription costs, visualize category expenditures through interactive analytics, and convert amounts against global currencies using live foreign exchange rates.

---

## 🌟 Key Features

* **Dashboard & Balance Overview:** Real-time summary cards displaying net balance, total income, and total expenses.
* **Transaction Management:** Record, edit, and categorize income and expense transactions with date tracking.
* **Subscription & Recurring Bill Tracker:**
  * Track monthly and yearly subscriptions (e.g., Netflix, Gym, Rent).
  * Compute total monthly recurring commitments.
  * Predictive upcoming bill alerts for commitments due within the next 7 days.
  * Active/inactive toggle switch per subscription.
* **Visual Expense Analytics:** Category-by-category breakdown with expenditure percentages and visual progress bars.
* **Live Currency Converter:** Real-time currency conversions from Egyptian Pound (`EGP`) to USD, EUR, GBP, SAR, AED, and KWD powered by `ExchangeRate-API`.
* **Multi-Tenant Cloud Sync:** Isolated cloud storage using Firebase Authentication and Cloud Firestore.
* **Modern Dark UI:** Tailored dark interface with custom typography and accent tones (`#1B5E20`).

---

## 🏗️ Architecture & Technology Stack

* **Architecture:** Layered Architecture with unidirectional reactive data flow.
* **Framework:** Flutter 3.x (Material 3).
* **Language:** Dart 3.5.3+ (Sound Null Safety).
* **State Management:** BLoC / Cubit (`flutter_bloc: ^8.1.6`).
* **Cloud Backend:** Google Cloud Firestore & Firebase Authentication (`firebase_core`, `firebase_auth`, `cloud_firestore`).
* **HTTP Client:** `dio: ^5.7.0` with timeout protection.
* **Local Persistence:** `sqflite: ^2.3.3+1` (dormant/ready for offline-first caching).
* **Typography & UI:** `google_fonts: ^6.2.1`, `fl_chart: ^0.69.0`, `intl: ^0.19.0`.

---

## 📁 Project Directory Structure

```
lib/
├── business_logic/
│   └── cubit/                 # ExpenseCubit, SubscriptionCubit & States
├── constants/
│   └── colors.dart            # AppColors palette definition
├── data/
│   ├── local/
│   │   └── db_helper.dart     # SQLite offline persistence helper
│   ├── models/
│   │   ├── subscription_model.dart # Subscription cycle & billing calculations
│   │   └── transaction_model.dart  # Transaction data model & serialization
│   └── web_services/
│       ├── currency_api.dart         # Live exchange rate Dio client
│       ├── firebase_service.dart     # Firestore transactions service
│       └── subscription_service.dart # Firestore subscriptions service
├── presentation/
│   ├── screens/               # 8 fully functional screens
│   └── widgets/               # Reusable widgets (TransactionItem, etc.)
└── main.dart                  # App root with reactive auth state builder
```

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK `>= 3.5.3` (Flutter 3.24+ recommended)
* Dart SDK `>= 3.5.3 < 4.0.0`
* Android Studio / JDK 17
* Firebase project with Authentication (Email/Password) and Cloud Firestore enabled.

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd personal_expense_tracker
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Ensure `android/app/google-services.json` and `lib/firebase_options.dart` correspond to your Firebase project.

4. **Run the application:**
   ```bash
   flutter run
   ```

5. **Run test suite:**
   ```bash
   flutter test
   ```

---

## 📑 Complete Audit & Technical Documentation

For an in-depth breakdown of the codebase, bugs fixed, security audits, and developer handoff, review the dedicated documentation suite in `docs/project-audit/`:

* [PROJECT_OVERVIEW.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/PROJECT_OVERVIEW.md) — Product purpose, features, and target users.
* [ARCHITECTURE.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/ARCHITECTURE.md) — Layered architecture, Cubit data flow, and navigation maps.
* [FEATURES_AND_SCREENS.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/FEATURES_AND_SCREENS.md) — Inventory of all 8 screens and widgets.
* [DATA_AND_API.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/DATA_AND_API.md) — Firestore schemas, REST endpoints, and SQLite storage.
* [DEPENDENCIES.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/DEPENDENCIES.md) — Detailed package audit and version constraints.
* [BUGS_AND_FIXES.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/BUGS_AND_FIXES.md) — Catalog of all 13 bugs identified and fixed.
* [TEST_REPORT.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/TEST_REPORT.md) — Test matrix, unit test suite, and environment status.
* [SETUP_AND_RUN.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/SETUP_AND_RUN.md) — Step-by-step developer setup and build commands.
* [AI_HANDOFF.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/AI_HANDOFF.md) — Critical guide and invariants for future AI assistants.
* [AUDIT_SUMMARY.md](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/docs/project-audit/AUDIT_SUMMARY.md) — Executive health scorecard and metrics table.

---

## 📄 License
This project is open-source and available under the standard MIT License.
