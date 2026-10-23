import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker/presentation/screens/auth_screen.dart';
import 'package:personal_expense_tracker/business_logic/cubit/expense_cubit.dart';
import 'package:personal_expense_tracker/business_logic/cubit/expense_state.dart';
import 'package:personal_expense_tracker/utils/app_colors.dart';
import 'package:personal_expense_tracker/presentation/screens/add_transaction_screen.dart';
import 'package:personal_expense_tracker/presentation/screens/statistics_screen.dart';
import 'package:personal_expense_tracker/presentation/screens/currency_screen.dart';
import 'package:personal_expense_tracker/presentation/widgets/transaction_item.dart';
import 'package:personal_expense_tracker/data/web_services/firebase_service.dart';
import 'package:personal_expense_tracker/business_logic/cubit/subscription_cubit.dart';
import 'package:personal_expense_tracker/presentation/screens/subscriptions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseCubit>().loadTransactions();
    });
  }

  void _showAllTransactions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoaded) {
              return DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'All Transactions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                state.transactions.reversed.toList()[index];
                            return TransactionItem(
                                transaction: transaction,
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete'),
                                      content: const Text(
                                          'Are you sure you want to delete this transaction?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<ExpenseCubit>()
                                                .deleteTransaction(
                                                    transaction.id!);
                                            Navigator.pop(ctx);
                                          },
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_wallet, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'ExpenseTracker',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Currency Rates',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CurrencyScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: 'Statistics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<ExpenseCubit>(),
                    child: const StatisticsScreen(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              final firebaseService = FirebaseService();
              await firebaseService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ExpenseCubit>().loadTransactions();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (state is ExpenseLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'TOTAL BALANCE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\$${state.totalBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(
                            color: Colors.white24, height: 32, thickness: 1),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.trending_up,
                                          color: AppColors.income, size: 16),
                                      SizedBox(width: 4),
                                      Text('INCOME',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '+\$${state.totalIncome.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.income,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.trending_down,
                                          color: AppColors.expense, size: 16),
                                      SizedBox(width: 4),
                                      Text('EXPENSES',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '-\$${state.totalExpense.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.expense,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _showAllTransactions,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  state.transactions.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(Icons.receipt,
                                  size: 64, color: AppColors.grey400),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: TextStyle(color: AppColors.grey600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first transaction',
                                style: TextStyle(
                                    color: AppColors.grey500, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.transactions.length > 4
                              ? 4
                              : state.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                state.transactions.reversed.toList()[index];
                            return TransactionItem(
                                transaction: transaction,
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete'),
                                      content: const Text(
                                          'Are you sure you want to delete this transaction?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<ExpenseCubit>()
                                                .deleteTransaction(transaction
                                                    .id!); // String id
                                            Navigator.pop(ctx);
                                          },
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                        ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.pie_chart,
                                size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Top Expenses',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...() {
                          final expenses = state.transactions
                              .where((t) => t.type == 'expense')
                              .toList();
                          final Map<String, double> categories = {};
                          for (var e in expenses) {
                            categories[e.category] =
                                (categories[e.category] ?? 0) + e.amount;
                          }
                          final sorted = categories.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));
                          return sorted.take(3).map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.expense,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(entry.key)),
                                  Text('\$${entry.value.toStringAsFixed(2)}'),
                                ],
                              ),
                            );
                          }).toList();
                        }(),
                        if (state.transactions
                            .where((t) => t.type == 'expense')
                            .isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('No expenses yet',
                                style: TextStyle(color: Colors.grey)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            // زر إضافة معاملة
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen()),
                  ).then((_) {
                    context.read<ExpenseCubit>().loadTransactions();
                  });
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'ADD',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => SubscriptionCubit(),
                        child: const SubscriptionsScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.subscriptions, size: 20),
                label: const Text(
                  'SUBS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
