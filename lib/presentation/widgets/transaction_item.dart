import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/data/models/transaction_model.dart';
import 'package:personal_expense_tracker/utils/app_colors.dart';
import 'package:personal_expense_tracker/presentation/screens/edit_transaction_screen.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == 'income';
    final Color amountColor = isIncome ? AppColors.income : AppColors.expense;
    final String amountSign = isIncome ? '+' : '-';
    final String dateFormat =
        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.category,
              color: amountColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.note,
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountSign\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat,
                style: TextStyle(
                  color: AppColors.grey500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditTransactionScreen(transaction: transaction),
                    ),
                  );
                },
                color: AppColors.primary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                color: AppColors.grey400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
