import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker/business_logic/cubit/expense_cubit.dart';
import 'package:personal_expense_tracker/data/models/transaction_model.dart';
import 'package:personal_expense_tracker/utils/app_colors.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;
  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _categoryController = TextEditingController();

  String _type = 'expense';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.transaction.amount.toString();
    _noteController.text = widget.transaction.note;
    _categoryController.text = widget.transaction.category;
    _type = widget.transaction.type;
    _selectedDate = widget.transaction.date;
  }

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
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: 'EGP ',
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
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Expense')),
                  ButtonSegment(value: 'income', label: Text('Income')),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Food, Transport, Shopping...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Select Date'),
                subtitle: Text(
                    '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
                trailing: const Icon(Icons.calendar_today),
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final updatedTransaction = TransactionModel(
                        id: widget.transaction.id,
                        amount: double.parse(_amountController.text),
                        type: _type,
                        category: _categoryController.text,
                        date: _selectedDate,
                        note: _noteController.text.isEmpty
                            ? 'No note'
                            : _noteController.text,
                      );
                      if (widget.transaction.id != null) {
                        context.read<ExpenseCubit>().updateTransaction(
                              widget.transaction.id!,
                              updatedTransaction,
                            );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Update', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
