import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker/data/models/subscription_model.dart';
import 'package:personal_expense_tracker/business_logic/cubit/subscription_cubit.dart';
import 'package:personal_expense_tracker/utils/app_colors.dart';
import 'package:personal_expense_tracker/presentation/screens/add_subscription_screen.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscriptions'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubscriptionError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is SubscriptionLoaded) {
            if (state.subscriptions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.subscriptions, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No subscriptions yet'),
                    SizedBox(height: 8),
                    Text('Tap + to add one'),
                  ],
                ),
              );
            }

            final activeSubs =
                state.subscriptions.where((s) => s.isActive).toList();
            final inactiveSubs =
                state.subscriptions.where((s) => !s.isActive).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Monthly Spending on Subscriptions',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${state.totalMonthlySpending.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.upcomingSubscriptions.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(Icons.notification_important,
                          color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text('Due Next 7 Days',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...state.upcomingSubscriptions
                      .map((sub) => _buildSubscriptionCard(sub, context, true)),
                  const SizedBox(height: 24),
                ],

                if (activeSubs.isNotEmpty) ...[
                  const Text('Active Subscriptions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...activeSubs
                      .map((sub) => _buildSubscriptionCard(sub, context, true)),
                  const SizedBox(height: 24),
                ],

                if (inactiveSubs.isNotEmpty) ...[
                  const Text('Inactive Subscriptions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...inactiveSubs.map(
                      (sub) => _buildSubscriptionCard(sub, context, false)),
                ],
              ],
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
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<SubscriptionCubit>(),
                    child: const AddSubscriptionScreen(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 24),
            label: const Text(
              'ADD NEW SUBSCRIPTION',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(
      SubscriptionModel sub, BuildContext context, bool isActive) {
    Color statusColor;
    String statusText;
    if (sub.isOverdue()) {
      statusColor = Colors.red;
      statusText = 'Overdue!';
    } else if (sub.isDueSoon()) {
      statusColor = Colors.orange;
      statusText = 'Due soon';
    } else {
      statusColor = Colors.green;
      statusText = 'On track';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(sub.id ?? '${sub.name}_${sub.dayOfMonth}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          if (sub.id != null) {
            context.read<SubscriptionCubit>().deleteSubscription(sub.id!);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${sub.name} deleted'),
                backgroundColor: Colors.red),
          );
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isActive ? AppColors.primary : Colors.grey,
            child:
                const Icon(Icons.subscriptions, color: Colors.white, size: 20),
          ),
          title: Text(sub.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\$${sub.amount.toStringAsFixed(2)}'),
              Text('Day ${sub.dayOfMonth} - Every ${sub.frequency}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(statusText,
                    style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<SubscriptionCubit>(),
                        child: AddSubscriptionScreen(subscription: sub),
                      ),
                    ),
                  );
                },
              ),
              Switch(
                value: sub.isActive,
                onChanged: (_) {
                  if (sub.id != null) {
                    context
                        .read<SubscriptionCubit>()
                        .toggleSubscription(sub.id!, !sub.isActive);
                  }
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
