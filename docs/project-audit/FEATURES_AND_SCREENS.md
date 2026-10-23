# Features and Screens Inventory

This document provides a complete inventory of every screen, view, and major reusable UI component implemented in the `personal_expense_tracker` mobile application.

---

## 1. Screen Inventory Summary

| # | Screen / Widget | File Path | Status | Primary Purpose |
|---|-----------------|-----------|--------|-----------------|
| 1 | `AuthScreen` | `lib/presentation/screens/auth_screen.dart` | Implemented & Verified | User authentication (Login & Register toggle) |
| 2 | `HomeScreen` | `lib/presentation/screens/home_screen.dart` | Implemented & Verified | Dashboard with balance cards, quick actions, & history |
| 3 | `AddTransactionScreen` | `lib/presentation/screens/add_transaction_screen.dart` | Implemented & Verified | Add income or expense transaction |
| 4 | `EditTransactionScreen` | `lib/presentation/screens/edit_transaction_screen.dart` | Implemented & Verified | Modify or delete existing transaction |
| 5 | `SubscriptionsScreen` | `lib/presentation/screens/subscriptions_screen.dart` | Implemented & Verified | List subscriptions, toggle active status, upcoming dues |
| 6 | `AddSubscriptionScreen` | `lib/presentation/screens/add_subscription_screen.dart` | Implemented & Verified | Create or edit recurring subscription |
| 7 | `StatisticsScreen` | `lib/presentation/screens/statistics_screen.dart` | Implemented & Verified | Visual category breakdown and spend percentage |
| 8 | `CurrencyScreen` | `lib/presentation/screens/currency_screen.dart` | Implemented & Verified | Real-time exchange rate currency converter |
| 9 | `TransactionItem` | `lib/presentation/widgets/transaction_item.dart` | Implemented & Verified | Reusable transaction card with category icons |

---

## 2. Detailed Screen Breakdown

### 2.1 AuthScreen
* **File Path:** [auth_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/auth_screen.dart)
* **Purpose:** Handles user sign-in and account registration using Firebase Authentication.
* **State Management Dependencies:** `FirebaseAuth.instance` directly.
* **Data Sources:** Firebase Authentication API.
* **User Actions:**
  * Enter email and password.
  * Toggle between "Login" and "Create Account" mode.
  * Submit form to log in or register.
  * Shows loading indicator (`CircularProgressIndicator`) during asynchronous auth calls.
  * Displays user-friendly error `SnackBar` upon invalid credentials or network errors.
* **Navigation Destinations:** Navigates to `HomeScreen` upon successful login/register.
* **Validation & Error Handling:**
  * Validates non-empty email and password.
  * Validates password length >= 6 characters.
  * Catches `FirebaseAuthException` and maps error codes to clear messages.
* **Status:** Implemented & Verified.

---

### 2.2 HomeScreen
* **File Path:** [home_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/home_screen.dart)
* **Purpose:** Serves as the central operational hub displaying financial balance, real-time transaction list, and shortcuts.
* **State Management Dependencies:** `BlocBuilder<ExpenseCubit, ExpenseState>`, `BlocBuilder<SubscriptionCubit, SubscriptionState>`.
* **Data Sources:** `ExpenseCubit` (real-time Firestore transactions stream).
* **User Actions:**
  * View current balance, total income, and total expenses in a styled gradient card.
  * Access Statistics via the AppBar analytics icon.
  * Access Currency Converter via the AppBar currency icon.
  * Access Subscriptions Screen via the quick-actions navigation chip.
  * Filter transactions list (All / Income / Expense).
  * Tap any transaction to open `EditTransactionScreen`.
  * Tap floating action button (`+`) to open `AddTransactionScreen`.
  * Log out of the account via the AppBar exit icon (with confirmation dialog).
* **Navigation Destinations:** `AddTransactionScreen`, `EditTransactionScreen`, `StatisticsScreen`, `SubscriptionsScreen`, `CurrencyScreen`, `AuthScreen`.
* **Status:** Implemented & Verified.

---

### 2.3 AddTransactionScreen
* **File Path:** [add_transaction_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/add_transaction_screen.dart)
* **Purpose:** Form to record a new income or expense transaction.
* **State Management Dependencies:** `context.read<ExpenseCubit>()`.
* **User Actions:**
  * Toggle transaction type (`expense` vs `income`).
  * Input transaction title/note.
  * Input monetary amount.
  * Select category from a grid/dropdown (Food, Transport, Entertainment, Bills, Salary, Other).
  * Pick date using `showDatePicker`.
  * Submit button to save transaction to Firestore.
* **Validation & Error Handling:**
  * Enforces title is not empty.
  * Enforces amount > 0.0 with number formatting validation.
  * Wrapped in `SingleChildScrollView` to prevent keyboard viewport pixel overflows.
* **Navigation Destinations:** Pops back to `HomeScreen` upon saving.
* **Status:** Implemented & Verified.

---

### 2.4 EditTransactionScreen
* **File Path:** [edit_transaction_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/edit_transaction_screen.dart)
* **Purpose:** Allows the user to inspect, modify, or permanently delete an existing transaction.
* **State Management Dependencies:** `context.read<ExpenseCubit>()`.
* **User Actions:**
  * Pre-populates all existing transaction fields (type, title, amount, category, date).
  * Modify title, amount, category, or date.
  * Tap "Save Changes" to update Firestore.
  * Tap "Delete" with confirmation dialog to remove transaction.
* **Validation & Error Handling:**
  * Guarded against null transaction IDs.
  * Amount validated > 0.0.
  * Form wrapped in `SingleChildScrollView` to prevent overflow when keyboard appears.
* **Status:** Implemented & Verified.

---

### 2.5 SubscriptionsScreen
* **File Path:** [subscriptions_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/subscriptions_screen.dart)
* **Purpose:** Tracks recurring recurring billing commitments (Netflix, Gym, Rent, Spotify, etc.) and alerts users to upcoming payment due dates.
* **State Management Dependencies:** `BlocBuilder<SubscriptionCubit, SubscriptionState>`.
* **User Actions:**
  * View monthly recurring cost summary card.
  * View "Upcoming This Week" alert section displaying bills due within the next 7 days.
  * View full list of active and inactive subscriptions.
  * Toggle subscription active/inactive status via a quick switch.
  * Tap subscription to edit via `AddSubscriptionScreen`.
  * Tap FAB (`+`) to register a new recurring subscription.
  * Dismiss or delete subscription with confirmation.
* **Status:** Implemented & Verified.

---

### 2.6 AddSubscriptionScreen
* **File Path:** [add_subscription_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/add_subscription_screen.dart)
* **Purpose:** Create a new subscription or edit an existing one.
* **State Management Dependencies:** `context.read<SubscriptionCubit>()`.
* **User Actions:**
  * Input subscription name.
  * Input billing amount.
  * Choose billing cycle (`Monthly` or `Yearly`).
  * Choose category.
  * Select start date.
  * Configure reminder notification threshold (e.g., 3 days before).
  * Save or update subscription.
* **Status:** Implemented & Verified.

---

### 2.7 StatisticsScreen
* **File Path:** [statistics_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/statistics_screen.dart)
* **Purpose:** Visual analysis of expenses broken down by category with percentage calculations and colored indicators.
* **State Management Dependencies:** `BlocBuilder<ExpenseCubit, ExpenseState>`.
* **User Actions:**
  * View total expense amount.
  * View category-by-category cards with proportional expenditure, percentage bar, and transaction counts.
  * Back button to return to dashboard.
* **Status:** Implemented & Verified (Linked and reachable via HomeScreen AppBar action).

---

### 2.8 CurrencyScreen
* **File Path:** [currency_screen.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/screens/currency_screen.dart)
* **Purpose:** Converts EGP (Egyptian Pound) amounts to USD, EUR, GBP, SAR, AED, etc., using real-time foreign exchange rates.
* **State Management Dependencies:** `StatefulWidget` managing local `CurrencyApi` fetch lifecycle.
* **User Actions:**
  * Enter amount in base currency (EGP).
  * Select target currency from dropdown (USD, EUR, GBP, SAR, AED, KWD).
  * Tap "Convert" to calculate converted amount based on live exchange rates.
  * View last updated timestamp of exchange rates.
* **Status:** Implemented & Verified (Linked and reachable via HomeScreen AppBar action).

---

### 2.9 TransactionItem (Widget)
* **File Path:** [transaction_item.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/presentation/widgets/transaction_item.dart)
* **Purpose:** Reusable ListTile widget displaying category icon, title, date, formatted currency amount (+/- colored), and swipe/tap affordances.
* **Status:** Implemented & Verified.
