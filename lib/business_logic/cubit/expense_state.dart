import 'package:personal_expense_tracker/data/models/transaction_model.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<TransactionModel> transactions;
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  ExpenseLoaded({
    required this.transactions,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}