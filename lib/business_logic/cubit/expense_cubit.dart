import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker/business_logic/cubit/expense_state.dart';
import 'package:personal_expense_tracker/data/models/transaction_model.dart';
import 'package:personal_expense_tracker/data/web_services/firebase_service.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;
  StreamSubscription<User?>? _authSubscription;

  ExpenseCubit() : super(ExpenseInitial()) {
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
    _transactionsSubscription?.cancel();
    _transactionsSubscription =
        _firebaseService.getTransactionsStream().listen((transactions) {
      if (!isClosed) {
        double totalIncome = 0;
        double totalExpense = 0;

        for (var t in transactions) {
          if (t.type == 'income') {
            totalIncome += t.amount;
          } else {
            totalExpense += t.amount;
          }
        }

        emit(ExpenseLoaded(
          transactions: transactions,
          totalBalance: totalIncome - totalExpense,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
        ));
      }
    }, onError: (error) {
      if (!isClosed) {
        emit(ExpenseError(error.toString()));
      }
    });
  }

  Future<void> loadTransactions() async {
    if (!isClosed) {
      _startListening();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _firebaseService.addTransaction(transaction);
  }

  Future<void> deleteTransaction(String docId) async {
    await _firebaseService.deleteTransaction(docId);
  }

  Future<void> updateTransaction(
      String docId, TransactionModel transaction) async {
    await _firebaseService.updateTransaction(docId, transaction);
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
