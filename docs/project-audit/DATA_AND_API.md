# Data and API Architecture

This document provides a comprehensive technical reference for all data models, local and remote databases, network APIs, and data serialization patterns in `personal_expense_tracker`.

---

## 1. Remote Database: Cloud Firestore

The primary data store is **Google Cloud Firestore**, operating in a multi-tenant model partitioned by Firebase Authentication `uid`.

### 1.1 Collections Hierarchy

```
/users/{uid}/transactions/{transaction_id}
/users/{uid}/subscriptions/{subscription_id}
```

### 1.2 Data Schemas

#### Transaction Document (`/users/{uid}/transactions/{id}`)

| Field | Data Type | Nullable | Description |
|-------|-----------|----------|-------------|
| `id` | `String` | No | Auto-generated Firestore document ID |
| `title` | `String` | No | Description or payee name |
| `amount` | `double` (or `int`) | No | Monetary value (coerced safely to double) |
| `date` | `Timestamp` | No | Transaction occurrence date and time |
| `type` | `String` | No | Either `'income'` or `'expense'` |
| `category` | `String` | No | Category (e.g., `'Food'`, `'Transport'`, `'Salary'`) |

*Serialization / Deserialization:*
* [transaction_model.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/models/transaction_model.dart)
* Deserialization handles both Firestore `Timestamp` objects and string ISO dates.
* Numeric casting safely handles both `int` and `double` values (`(map['amount'] as num?)?.toDouble() ?? 0.0`).

#### Subscription Document (`/users/{uid}/subscriptions/{id}`)

| Field | Data Type | Nullable | Description |
|-------|-----------|----------|-------------|
| `id` | `String` | No | Auto-generated Firestore document ID |
| `name` | `String` | No | Name of recurring service (e.g. Netflix) |
| `amount` | `double` (or `int`) | No | Periodic cost |
| `billingCycle` | `String` | No | `'Monthly'` or `'Yearly'` |
| `startDate` | `Timestamp` | No | Inception date of subscription |
| `category` | `String` | No | Category classification |
| `isActive` | `bool` | No | Active status toggle |
| `reminderDays` | `int` | No | Number of days prior to due date for reminder |

*Billing Calculation Engine:*
* [subscription_model.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/models/subscription_model.dart) dynamically calculates the next billing date by projecting months or years forward from `startDate` up to the current calendar date.
* `isDueSoon()` returns true if the next billing date is between today and `today + reminderDays`.
* `isOverdue()` checks if the current cycle date has passed without payment.

---

## 2. External REST API: ExchangeRate-API

The application integrates with the public Foreign Exchange Rates API for live currency conversion against the Egyptian Pound (`EGP`).

### 2.1 Endpoint Specification

* **Base URL:** `https://api.exchangerate-api.com`
* **Path:** `/v4/latest/EGP`
* **Method:** `GET`
* **Headers:** Standard JSON (`Content-Type: application/json`)
* **Authentication:** Public endpoint (no API key required)
* **Client Implementation:** [currency_api.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/web_services/currency_api.dart)

### 2.2 Response Structure Example

```json
{
  "provider": "https://www.exchangerate-api.com",
  "WARNING_UPGRADE_TO_V6": "https://www.exchangerate-api.com/docs/free",
  "terms": "https://www.exchangerate-api.com/terms",
  "base": "EGP",
  "date": "2026-10-23",
  "time_last_updated": 1774224001,
  "rates": {
    "EGP": 1,
    "USD": 0.0205,
    "EUR": 0.0192,
    "GBP": 0.0163,
    "SAR": 0.0769,
    "AED": 0.0753,
    "KWD": 0.0063
  }
}
```

### 2.3 Resiliency & Timeout Configuration

The HTTP client using `Dio` has been configured with strict timeouts to prevent infinite loading screens or UI hangs:
* `connectTimeout`: 10,000 ms (10 seconds)
* `receiveTimeout`: 10,000 ms (10 seconds)
* Numeric casting safeguards `(rates[currency] as num).toDouble()` to prevent Dart runtime type exceptions when exchange rates are integers (e.g., `1`).

---

## 3. Local Storage: SQLite (sqflite)

An offline SQLite persistence layer exists in [db_helper.dart](file:///c:/Users/abori/Desktop/VS Code/Projects/personal_expense_tracker/lib/data/local/db_helper.dart).

### 3.1 Schema (`expenses.db`)

```sql
CREATE TABLE transactions (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    type TEXT NOT NULL,
    category TEXT NOT NULL
);
```

### 3.2 Operational Status

* **Status:** Dormant / Ready for Offline Sync.
* **Current Usage:** The active Cubits (`ExpenseCubit` and `SubscriptionCubit`) currently stream directly from Firebase Firestore. The `DatabaseHelper` provides a fully working local SQLite CRUD implementation which can be connected to support an offline-first caching policy in a future release.

---

## 4. Error Handling and Network Fault Tolerance

| Scenario | Handled By | Behavior |
|----------|------------|----------|
| User logged out / Unauthenticated | `FirebaseService`, `SubscriptionService` | Returns empty `Stream.value([])` instead of crashing on null user |
| Firestore offline / Disconnected | Firestore SDK | Internal local cache automatically queues writes |
| Currency API timeout / failure | `CurrencyApi` & `CurrencyScreen` | Catches `DioException`, logs error, and presents error message SnackBar without freezing UI |
| Malformed numbers from API / DB | `TransactionModel`, `SubscriptionModel` | Uses `(value as num?)?.toDouble() ?? 0.0` safe casting |
