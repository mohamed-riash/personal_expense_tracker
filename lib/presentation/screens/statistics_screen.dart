import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_expense_tracker/business_logic/cubit/expense_cubit.dart';
import 'package:personal_expense_tracker/business_logic/cubit/expense_state.dart';
import 'package:personal_expense_tracker/utils/app_colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ExpenseLoaded) {
            final expenses =
                state.transactions.where((t) => t.type == 'expense').toList();

            if (expenses.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No expenses to show statistics'),
                  ],
                ),
              );
            }

            final Map<String, double> categoryTotals = {};
            for (var expense in expenses) {
              categoryTotals[expense.category] =
                  (categoryTotals[expense.category] ?? 0) + expense.amount;
            }

            final sortedCategories = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            const pieColors = [
              Color(0xFFE57373),
              Color(0xFFFFB74D),
              Color(0xFF81C784),
              Color(0xFF64B5F6),
              Color(0xFFBA68C8),
              Color(0xFFFFD54F),
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expense Distribution',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: sortedCategories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final total =
                              categoryTotals.values.reduce((a, b) => a + b);
                          final percentage = (category.value / total) * 100;
                          return PieChartSectionData(
                            value: category.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            color: pieColors[index % pieColors.length],
                            radius: 100,
                            titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Top Categories',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedCategories.length > 5
                        ? 5
                        : sortedCategories.length,
                    itemBuilder: (context, index) {
                      final category = sortedCategories[index];
                      final total =
                          categoryTotals.values.reduce((a, b) => a + b);
                      final percentage = (category.value / total) * 100;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                pieColors[index % pieColors.length],
                            child: Text('${index + 1}',
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(category.key,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${category.value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text('${percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.expense),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Expenses',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('\$${state.totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.expense)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
