class TransactionModel {
  final String? id;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String note;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TransactionModel(
      id: id ?? map['id']?.toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] as String? ?? 'expense',
      category: map['category'] as String? ?? 'General',
      date: map['date'] != null
          ? (DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
