import 'package:flutter_test/flutter_test.dart';
import 'package:personal_expense_tracker/data/models/transaction_model.dart';
import 'package:personal_expense_tracker/data/models/subscription_model.dart';
import 'package:personal_expense_tracker/utils/app_colors.dart';

void main() {
  group('TransactionModel Tests', () {
    test('Correctly serializes and deserializes transaction map', () {
      final now = DateTime(2026, 4, 15, 10, 30);
      final model = TransactionModel(
        id: 'tx_123',
        amount: 250.75,
        type: 'expense',
        category: 'Food',
        date: now,
        note: 'Grocery shopping',
      );

      final map = model.toMap();
      expect(map['amount'], 250.75);
      expect(map['type'], 'expense');
      expect(map['category'], 'Food');
      expect(map['date'], now.toIso8601String());
      expect(map['note'], 'Grocery shopping');

      final fromMap = TransactionModel.fromMap(map, id: 'tx_123');
      expect(fromMap.id, 'tx_123');
      expect(fromMap.amount, 250.75);
      expect(fromMap.type, 'expense');
      expect(fromMap.category, 'Food');
      expect(fromMap.date, now);
      expect(fromMap.note, 'Grocery shopping');
    });

    test('Safely handles integer amounts and integer IDs from SQLite', () {
      final mapWithInt = {
        'id': 42,
        'amount': 150,
        'type': 'income',
        'category': 'Salary',
        'date': '2026-04-01T00:00:00.000',
        'note': 'Bonus',
      };

      final model = TransactionModel.fromMap(mapWithInt);
      expect(model.id, '42');
      expect(model.amount, 150.0);
      expect(model.type, 'income');
    });

    test('Safely handles missing or corrupted date fields', () {
      final corruptedMap = {
        'amount': 50.0,
        'type': 'expense',
        'category': 'Other',
        'date': 'invalid-date-string',
        'note': '',
      };

      final model = TransactionModel.fromMap(corruptedMap);
      expect(model.amount, 50.0);
      expect(model.date, isNotNull);
    });
  });

  group('SubscriptionModel Tests', () {
    test('Correctly serializes and deserializes subscription', () {
      final billingDate = DateTime(2026, 5, 1);
      final sub = SubscriptionModel(
        id: 'sub_netflix',
        name: 'Netflix',
        amount: 15.99,
        category: 'Entertainment',
        frequency: 'monthly',
        dayOfMonth: 1,
        nextBillingDate: billingDate,
        note: 'Family plan',
        isActive: true,
      );

      final map = sub.toMap();
      expect(map['name'], 'Netflix');
      expect(map['amount'], 15.99);
      expect(map['frequency'], 'monthly');
      expect(map['dayOfMonth'], 1);
      expect(map['isActive'], true);

      final reconstructed = SubscriptionModel.fromMap(map, id: 'sub_netflix');
      expect(reconstructed.id, 'sub_netflix');
      expect(reconstructed.name, 'Netflix');
      expect(reconstructed.amount, 15.99);
      expect(reconstructed.frequency, 'monthly');
      expect(reconstructed.dayOfMonth, 1);
      expect(reconstructed.isActive, true);
    });

    test('getNextBillingDate calculates future billing cycle correctly', () {
      final now = DateTime.now();
      final sub = SubscriptionModel(
        name: 'Gym',
        amount: 50.0,
        category: 'Health',
        frequency: 'monthly',
        dayOfMonth: (now.day % 28) + 1,
        nextBillingDate: now,
        note: '',
      );

      final next = sub.getNextBillingDate();
      expect(next.day, (now.day % 28) + 1);
    });

    test('isDueSoon identifies upcoming due date within 7 days', () {
      final today = DateTime.now();
      final targetDay = today.day; // Due today

      final dueSub = SubscriptionModel(
        name: 'Spotify',
        amount: 9.99,
        category: 'Entertainment',
        frequency: 'monthly',
        dayOfMonth: targetDay,
        nextBillingDate: today,
        note: '',
      );

      expect(dueSub.isDueSoon(), isTrue);
    });
  });

  group('AppColors Tests', () {
    test('Validates theme primary and accent colors', () {
      expect(AppColors.primary.value, 0xFF1B5E20);
      expect(AppColors.accent.value, 0xFFFFC107);
      expect(AppColors.income.value, 0xFF81C784);
      expect(AppColors.expense.value, 0xFFE57373);
    });
  });
}
