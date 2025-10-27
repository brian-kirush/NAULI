class Transaction {
  final String id;
  final double amount;
  final String route;
  final String cardLastFour;
  final DateTime time;
  final String type;
  final double platformFee;

  Transaction({
    required this.id,
    required this.amount,
    required this.route,
    required this.cardLastFour,
    required this.time,
    required this.type,
    this.platformFee = 2.0,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      route: json['route'] ?? '',
      cardLastFour: json['card_last_four'] ?? '',
      time: DateTime.parse(json['time']),
      type: json['type'] ?? 'fare',
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 2.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'route': route,
      'card_last_four': cardLastFour,
      'time': time.toIso8601String(),
      'type': type,
      'platform_fee': platformFee,
    };
  }
}
