import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker/data/models/subscription_model.dart';
import 'package:personal_expense_tracker/data/web_services/firebase_service.dart';
import 'package:personal_expense_tracker/data/web_services/subscription_service.dart';

// States
abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionModel> subscriptions;
  final double totalMonthlySpending;
  final List<SubscriptionModel> upcomingSubscriptions;

  SubscriptionLoaded(
    this.subscriptions,
    this.totalMonthlySpending, {
    this.upcomingSubscriptions = const [],
  });
}

class SubscriptionError extends SubscriptionState {
  final String message;
  SubscriptionError(this.message);
}

// Cubit
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final FirebaseService _firebaseService = FirebaseService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  StreamSubscription<List<SubscriptionModel>>? _subscriptionsSubscription;
  StreamSubscription<User?>? _authSubscription;
  List<SubscriptionModel> _cachedUpcoming = [];

  SubscriptionCubit() : super(SubscriptionInitial()) {
    _init();
  }

  void _init() {
    _startListening();
    _authSubscription = _firebaseService.authStateChanges.listen((user) {
      if (!isClosed) {
        _startListening();
      }
    });
  }

  void _startListening() {
    _subscriptionsSubscription?.cancel();
    _subscriptionsSubscription =
        _firebaseService.getSubscriptionsStream().listen((subscriptions) {
      if (!isClosed) {
        double total = 0;
        for (var s in subscriptions) {
          if (s.isActive) {
            if (s.frequency == 'monthly') {
              total += s.amount;
            } else if (s.frequency == 'yearly') {
              total += s.amount / 12;
            } else if (s.frequency == 'weekly') {
              total += s.amount * 4;
            }
          }
        }
        emit(SubscriptionLoaded(
          subscriptions,
          total,
          upcomingSubscriptions: _cachedUpcoming,
        ));
        _loadUpcomingSubscriptions();
      }
    }, onError: (error) {
      if (!isClosed) {
        emit(SubscriptionError(error.toString()));
      }
    });
  }

  Future<void> _loadUpcomingSubscriptions() async {
    final upcoming = await _subscriptionService.getUpcomingSubscriptions();
    _cachedUpcoming = upcoming;
    if (!isClosed && state is SubscriptionLoaded) {
      final currentState = state as SubscriptionLoaded;
      emit(SubscriptionLoaded(
        currentState.subscriptions,
        currentState.totalMonthlySpending,
        upcomingSubscriptions: upcoming,
      ));
    }
  }

  Future<void> addSubscription(SubscriptionModel subscription) async {
    await _firebaseService.addSubscription(subscription);
    await _subscriptionService.processDueSubscriptions();
  }

  Future<void> deleteSubscription(String id) async {
    await _firebaseService.deleteSubscription(id);
  }

  Future<void> toggleSubscription(String id, bool isActive) async {
    await _firebaseService.toggleSubscription(id, isActive);
  }

  Future<void> refreshUpcoming() async {
    await _loadUpcomingSubscriptions();
    await _subscriptionService.processDueSubscriptions();
  }

  Future<void> updateSubscription(
      String id, SubscriptionModel subscription) async {
    await _firebaseService.updateSubscription(id, subscription);
  }

  @override
  Future<void> close() {
    _subscriptionsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
