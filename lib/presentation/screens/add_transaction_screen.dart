import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker/business_logic/cubit/expense_cubit.dart';
import 'package:personal_expense_tracker/data/models/transaction_model.dart';
import 'package:personal_expense_tracker/utils/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _categoryController = TextEditingController();

  String _type = 'expense';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    suffixText: ' EGP',
                    suffixStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey500,
                    ),
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey300,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final num = double.tryParse(value.trim());
                    if (num == null) {
                      return 'Enter a valid number';
                    }
                    if (num <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
              // Expense / Income Segmented Button
              Center(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'expense',
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_upward, size: 16),
                    ),
                    ButtonSegment(
                      value: 'income',
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_downward, size: 16),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _type = newSelection.first;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return _type == 'expense'
                            ? AppColors.expense
                            : AppColors.income;
                      }
                      return AppColors.grey100;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return AppColors.grey600;
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              const Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  hintText: 'e.g., Food, Transport, Shopping...',
                  hintStyle: TextStyle(color: AppColors.grey400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.grey50,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'DATE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today,
                          color: AppColors.grey500, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'NOTE (OPTIONAL)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Add a note...',
                  hintStyle: TextStyle(color: AppColors.grey400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.grey50,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newTransaction = TransactionModel(
                        amount: double.parse(_amountController.text),
                        type: _type,
                        category: _categoryController.text,
                        date: _selectedDate,
                        note: _noteController.text.isEmpty
                            ? 'No note'
                            : _noteController.text,
                      );
                      context
                          .read<ExpenseCubit>()
                          .addTransaction(newTransaction);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
