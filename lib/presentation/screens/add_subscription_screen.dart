import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker/business_logic/cubit/subscription_cubit.dart';
import 'package:personal_expense_tracker/data/models/subscription_model.dart';
import 'package:personal_expense_tracker/utils/app_colors.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final SubscriptionModel? subscription;
  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _frequency = 'monthly';
  int _dayOfMonth = 1;
  DateTime _startDate = DateTime.now();

  final List<Map<String, dynamic>> _frequencyOptions = [
    {'value': 'monthly', 'label': 'Monthly', 'icon': Icons.calendar_month},
    {'value': 'yearly', 'label': 'Yearly', 'icon': Icons.calendar_today},
    {'value': 'weekly', 'label': 'Weekly', 'icon': Icons.weekend},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.subscription != null) {
      _nameController.text = widget.subscription!.name;
      _amountController.text = widget.subscription!.amount.toString();
      _frequency = widget.subscription!.frequency;
      _dayOfMonth = widget.subscription!.dayOfMonth;
      _startDate = widget.subscription!.nextBillingDate;
      _noteController.text = widget.subscription!.note;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscription == null
            ? 'Add Subscription'
            : 'Edit Subscription'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NAME',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Netflix, Gym, Spotify...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 16),
                const Text('AMOUNT',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      prefixText: 'EGP ', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter amount';
                    final num = double.tryParse(v.trim());
                    if (num == null) return 'Invalid number';
                    if (num <= 0) return 'Amount must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('FREQUENCY',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _frequency,
                  items: _frequencyOptions.map<DropdownMenuItem<String>>((opt) {
                    return DropdownMenuItem<String>(
                      value: opt['value'].toString(),
                      child: Row(
                        children: [
                          Icon(opt['icon'], size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(opt['label']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _frequency = v!),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                const Text('BILLING DAY',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _dayOfMonth,
                  items: List.generate(31, (i) => i + 1).map((day) {
                    return DropdownMenuItem(
                        value: day, child: Text('Day $day'));
                  }).toList(),
                  onChanged: (v) => setState(() => _dayOfMonth = v!),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                const Text('START DATE',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${_startDate.year}/${_startDate.month}/${_startDate.day}'),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('NOTE (OPTIONAL)',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                      hintText: 'Add a note...', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.black,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final subscription = SubscriptionModel(
                          name: _nameController.text,
                          amount: double.parse(_amountController.text),
                          category: 'Subscription', // كاتيجوري ثابتة
                          frequency: _frequency,
                          dayOfMonth: _dayOfMonth,
                          nextBillingDate: _startDate,
                          note: _noteController.text,
                          isActive: true,
                        );

                        if (widget.subscription != null &&
                            widget.subscription!.id != null) {
                          context.read<SubscriptionCubit>().updateSubscription(
                                widget.subscription!.id!,
                                subscription,
                              );
                        } else {
                          context
                              .read<SubscriptionCubit>()
                              .addSubscription(subscription);
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      widget.subscription == null ? 'SAVE' : 'UPDATE',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
