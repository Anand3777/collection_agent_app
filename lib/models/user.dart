class User {
  final String id;
  final String name;
  final String chitId;
  final double pendingAmount;
  final DateTime dueDate;
  final int overdueDays;
  final String status; // 'pending', 'overdue', 'completed'
  final String? phoneNumber; // Customer mobile number

  User({
    required this.id,
    required this.name,
    required this.chitId,
    required this.pendingAmount,
    required this.dueDate,
    required this.overdueDays,
    this.status = 'pending',
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      chitId: json['chit_id'] ?? '',
      pendingAmount: (json['pending_amount'] ?? 0).toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      overdueDays: json['overdue_days'] ?? 0,
      status: json['status'] ?? 'pending',
      phoneNumber: json['phone_number'] ?? json['mobile_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'chit_id': chitId,
      'pending_amount': pendingAmount,
      'due_date': dueDate.toIso8601String(),
      'overdue_days': overdueDays,
      'status': status,
      'phone_number': phoneNumber,
    };
  }
}
