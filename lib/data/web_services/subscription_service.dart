import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal_expense_tracker/data/models/subscription_model.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference? get _subscriptionsRef {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions');
  }

  CollectionReference? get _transactionsRef {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions');
  }

  Future<void> processDueSubscriptions() async {
    final ref = _subscriptionsRef;
    if (ref == null) return;

    final today = DateTime.now();
    final todayDay = today.day;
    final currentMonth = today.month;
    final currentYear = today.year;

    final snapshot =
        await ref.where('isActive', isEqualTo: true).get();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final subscription = SubscriptionModel.fromMap(data, id: doc.id);

      final lastProcessed = subscription.lastProcessedDate;

      final isBillingDayToday = subscription.dayOfMonth == todayDay;

      final alreadyProcessedThisMonth = lastProcessed != null &&
          lastProcessed.year == currentYear &&
          lastProcessed.month == currentMonth;

      if (isBillingDayToday && !alreadyProcessedThisMonth) {
        await _addTransactionFromSubscription(subscription, today);

        await ref.doc(doc.id).update({
          'lastProcessedDate': today.toIso8601String(),
        });
      }
    }
  }

  Future<void> _addTransactionFromSubscription(
      SubscriptionModel subscription, DateTime date) async {
    final ref = _transactionsRef;
    if (ref == null) return;

    await ref.add({
      'amount': subscription.amount,
      'type': 'expense',
      'category': subscription.category,
      'date': date.toIso8601String(),
      'note':
          'اشتراك: ${subscription.name} (${_getFrequencyArabic(subscription.frequency)})',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _getFrequencyArabic(String frequency) {
    switch (frequency) {
      case 'monthly':
        return 'شهري';
      case 'yearly':
        return 'سنوي';
      case 'weekly':
        return 'أسبوعي';
      default:
        return frequency;
    }
  }

  Future<double> calculateExpectedMonthlySpending() async {
    final ref = _subscriptionsRef;
    if (ref == null) return 0;

    final snapshot =
        await ref.where('isActive', isEqualTo: true).get();
    double total = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final subscription = SubscriptionModel.fromMap(data, id: doc.id);

      if (subscription.frequency == 'monthly') {
        total += subscription.amount;
      } else if (subscription.frequency == 'yearly') {
        total += subscription.amount / 12;
      } else if (subscription.frequency == 'weekly') {
        total += subscription.amount * 4;
      }
    }

    return total;
  }

  Future<List<SubscriptionModel>> getUpcomingSubscriptions(
      {int days = 7}) async {
    final ref = _subscriptionsRef;
    if (ref == null) return [];

    final snapshot =
        await ref.where('isActive', isEqualTo: true).get();
    final List<SubscriptionModel> upcoming = [];
    final today = DateTime.now();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final subscription = SubscriptionModel.fromMap(data, id: doc.id);

      final lastProcessed = subscription.lastProcessedDate;
      final currentMonth = today.month;
      final currentYear = today.year;

      final notProcessedThisMonth = lastProcessed == null ||
          lastProcessed.year != currentYear ||
          lastProcessed.month != currentMonth;

      if (notProcessedThisMonth &&
          subscription.dayOfMonth >= today.day &&
          subscription.dayOfMonth <= today.day + days) {
        upcoming.add(subscription);
      }
    }

    upcoming.sort((a, b) => a.dayOfMonth.compareTo(b.dayOfMonth));
    return upcoming;
  }

  static Future<void> checkSubscriptionsOnStartup() async {
    final service = SubscriptionService();
    await service.processDueSubscriptions();
  }
}
