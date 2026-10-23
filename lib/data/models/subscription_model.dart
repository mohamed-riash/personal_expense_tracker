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
        int maxDayThisMonth = DateTime(now.year, now.month + 1, 0).day;
        int billingDayThisMonth = dayOfMonth.clamp(1, maxDayThisMonth);
        if (now.day <= billingDayThisMonth) {
          nextDate = DateTime(now.year, now.month, billingDayThisMonth);
        } else {
          int nextYear = now.month == 12 ? now.year + 1 : now.year;
          int nextMonth = now.month == 12 ? 1 : now.month + 1;
          int maxDayNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
          int billingDayNextMonth = dayOfMonth.clamp(1, maxDayNextMonth);
          nextDate = DateTime(nextYear, nextMonth, billingDayNextMonth);
        }
        break;
      case 'yearly':
        int targetMonth = nextBillingDate.month;
        int maxDayThisYear = DateTime(now.year, targetMonth + 1, 0).day;
        int billingDayThisYear = dayOfMonth.clamp(1, maxDayThisYear);
        if (now.month < targetMonth ||
            (now.month == targetMonth && now.day <= billingDayThisYear)) {
          nextDate = DateTime(now.year, targetMonth, billingDayThisYear);
        } else {
          int maxDayNextYear = DateTime(now.year + 1, targetMonth + 1, 0).day;
          int billingDayNextYear = dayOfMonth.clamp(1, maxDayNextYear);
          nextDate = DateTime(now.year + 1, targetMonth, billingDayNextYear);
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

    switch (frequency) {
      case 'monthly':
        int maxDayThisMonth = DateTime(today.year, today.month + 1, 0).day;
        int billingDayThisMonth = dayOfMonth.clamp(1, maxDayThisMonth);
        DateTime currentCycleDate =
            DateTime(today.year, today.month, billingDayThisMonth);

        if (todayDateOnly.isAfter(currentCycleDate)) {
          final alreadyProcessedThisMonth = lastProcessedDate != null &&
              lastProcessedDate!.year == today.year &&
              lastProcessedDate!.month == today.month;
          return !alreadyProcessedThisMonth;
        }
        return false;

      case 'yearly':
        int targetMonth = nextBillingDate.month;
        int maxDayThisYear = DateTime(today.year, targetMonth + 1, 0).day;
        int billingDayThisYear = dayOfMonth.clamp(1, maxDayThisYear);
        DateTime currentCycleDate =
            DateTime(today.year, targetMonth, billingDayThisYear);

        if (todayDateOnly.isAfter(currentCycleDate)) {
          final alreadyProcessedThisYear = lastProcessedDate != null &&
              lastProcessedDate!.year == today.year;
          return !alreadyProcessedThisYear;
        }
        return false;

      default:
        DateTime targetDateOnly = DateTime(
          nextBillingDate.year,
          nextBillingDate.month,
          nextBillingDate.day,
        );
        return todayDateOnly.isAfter(targetDateOnly);
    }
  }
}
