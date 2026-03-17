class ChitDetails {
  final String customerId;
  final String customerName;
  final double pendingAmount;
  final DateTime dueDate;
  final String chitCycle;
  final int currentMonth;
  final int totalMonths;
  final bool isCallActive;
  final DateTime? callStartTime;
  final String? phoneNumber; // Customer mobile number

  ChitDetails({
    required this.customerId,
    required this.customerName,
    required this.pendingAmount,
    required this.dueDate,
    required this.chitCycle,
    required this.currentMonth,
    required this.totalMonths,
    this.isCallActive = false,
    this.callStartTime,
    this.phoneNumber,
  });

  factory ChitDetails.fromJson(Map<String, dynamic> json) {
    return ChitDetails(
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      pendingAmount: (json['pending_amount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      chitCycle: json['chit_cycle'] ?? '',
      currentMonth: json['current_month'] ?? 0,
      totalMonths: json['total_months'] ?? 0,
      isCallActive: json['is_call_active'] ?? false,
      callStartTime: json['call_start_time'] != null
          ? DateTime.parse(json['call_start_time'])
          : null,
      phoneNumber: json['phone_number'] ?? json['mobile_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'pending_amount': pendingAmount,
      'due_date': dueDate.toIso8601String(),
      'chit_cycle': chitCycle,
      'current_month': currentMonth,
      'total_months': totalMonths,
      'is_call_active': isCallActive,
      'call_start_time': callStartTime?.toIso8601String(),
      'phone_number': phoneNumber,
    };
  }

  int get overdueDays {
    final now = DateTime.now();
    if (now.isAfter(dueDate)) {
      return now.difference(dueDate).inDays;
    }
    return 0;
  }

  bool get isOverdue => overdueDays > 0;
}
