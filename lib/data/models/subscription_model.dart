class SubscriptionModel {
  final String? id;
  final String name;
  final double amount;
  final String category;
  final String frequency; 
  final int dayOfMonth;
  final DateTime nextBillingDate;
  final String note;
  final bool isActive;
  final DateTime? lastProcessedDate; 

  SubscriptionModel({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.dayOfMonth,
    required this.nextBillingDate,
    required this.note,
    this.isActive = true,
    this.lastProcessedDate,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SubscriptionModel(
      id: id ?? map['id']?.toString(),
      name: map['name'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      frequency: map['frequency'] ?? 'monthly',
      dayOfMonth: (map['dayOfMonth'] as num?)?.toInt() ?? 1,
      nextBillingDate: map['nextBillingDate'] != null
          ? (DateTime.tryParse(map['nextBillingDate'].toString()) ?? DateTime.now())
          : DateTime.now(),
      note: map['note'] ?? '',
      isActive: map['isActive'] ?? true,
      lastProcessedDate: map['lastProcessedDate'] != null
          ? DateTime.tryParse(map['lastProcessedDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'dayOfMonth': dayOfMonth,
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'note': note,
      'isActive': isActive,
      if (lastProcessedDate != null)
        'lastProcessedDate': lastProcessedDate!.toIso8601String(),
    };
  }

  DateTime getNextBillingDate() {
    DateTime now = DateTime.now();
    DateTime nextDate;

    switch (frequency) {
      case 'monthly':
        if (now.day <= dayOfMonth) {
          nextDate = DateTime(now.year, now.month, dayOfMonth);
        } else {
          nextDate = DateTime(now.year, now.month + 1, dayOfMonth);
        }
        break;
      case 'yearly':
        if (now.month < nextBillingDate.month ||
            (now.month == nextBillingDate.month && now.day <= dayOfMonth)) {
          nextDate = DateTime(now.year, nextBillingDate.month, dayOfMonth);
        } else {
          nextDate = DateTime(now.year + 1, nextBillingDate.month, dayOfMonth);
        }
        break;
      default:
        nextDate = nextBillingDate;
    }
    return nextDate;
  }

  bool isDueSoon() {
    DateTime today = DateTime.now();
    DateTime todayDateOnly = DateTime(today.year, today.month, today.day);
    DateTime next = getNextBillingDate();
    DateTime nextDateOnly = DateTime(next.year, next.month, next.day);
    int daysUntilDue = nextDateOnly.difference(todayDateOnly).inDays;
    return daysUntilDue >= 0 && daysUntilDue <= 7;
  }

  bool isOverdue() {
    DateTime today = DateTime.now();
    DateTime todayDateOnly = DateTime(today.year, today.month, today.day);
    DateTime next = getNextBillingDate();
    DateTime nextDateOnly = DateTime(next.year, next.month, next.day);
    return todayDateOnly.isAfter(nextDateOnly);
  }
}
