import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_expense_tracker/data/models/transaction_model.dart';
import 'package:personal_expense_tracker/data/models/subscription_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Authentication ====================

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e);
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Please enter a valid email';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Wrong password';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // ==================== Firestore (Transactions) ====================

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference? get _transactionsRef {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  // إضافة معاملة
  Future<void> addTransaction(TransactionModel transaction) async {
    final ref = _transactionsRef;
    if (ref == null) throw Exception('User not authenticated');
    await ref.add({
      'amount': transaction.amount,
      'type': transaction.type,
      'category': transaction.category,
      'date': transaction.date.toIso8601String(),
      'note': transaction.note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // جلب كل المعاملات (Stream)
  Stream<List<TransactionModel>> getTransactionsStream() {
    final ref = _transactionsRef;
    if (ref == null) {
      return Stream.value([]);
    }
    return ref
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromMap(data, id: doc.id);
      }).toList();
    });
  }

  // حذف معاملة
  Future<void> deleteTransaction(String docId) async {
    final ref = _transactionsRef;
    if (ref == null) throw Exception('User not authenticated');
    await ref.doc(docId).delete();
  }

  // تحديث معاملة
  Future<void> updateTransaction(
      String docId, TransactionModel transaction) async {
    final ref = _transactionsRef;
    if (ref == null) throw Exception('User not authenticated');
    await ref.doc(docId).update({
      'amount': transaction.amount,
      'type': transaction.type,
      'category': transaction.category,
      'date': transaction.date.toIso8601String(),
      'note': transaction.note,
    });
  }

  // ==================== Subscriptions ====================

  CollectionReference? get _subscriptionsRef {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('subscriptions');
  }

  Future<void> addSubscription(SubscriptionModel subscription) async {
    final ref = _subscriptionsRef;
    if (ref == null) throw Exception('User not authenticated');
    await ref.add(subscription.toMap());
  }

  Stream<List<SubscriptionModel>> getSubscriptionsStream() {
    final ref = _subscriptionsRef;
    if (ref == null) {
      return Stream.value([]);
    }
    return ref
        .orderBy('nextBillingDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubscriptionModel.fromMap(data, id: doc.id);
      }).toList();
    });
  }

  Future<void> updateSubscription(
      String docId, SubscriptionModel subscription) async {
    final ref = _subscriptionsRef;
    if (ref == null) throw Exception('User not authenticated');
    await ref.doc(docId).update(subscription.toMap());
  }

  Future<void> deleteSubscription(String docId) async {
    final ref = _subscriptionsRef;
    if (ref == null) throw Exception('User not authenticated');
    await ref.doc(docId).delete();
  }

  Future<void> toggleSubscription(String docId, bool isActive) async {
    final ref = _subscriptionsRef;
    if (ref == null) throw Exception('User not authenticated');
    await ref.doc(docId).update({'isActive': isActive});
  }
}
