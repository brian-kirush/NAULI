class DailyReport {
  final DateTime date;
  final double totalCollections;
  final double totalFees;
  final int totalPassengers;
  final double averageFare;
  final Map<String, double> routes;

  DailyReport({
    required this.date,
    required this.totalCollections,
    required this.totalFees,
    required this.totalPassengers,
    required this.averageFare,
    required this.routes,
  });

  double get netAmount => totalCollections - totalFees;

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      date: DateTime.parse(json['date']),
      totalCollections: (json['total_collections'] as num).toDouble(),
      totalFees: (json['total_fees'] as num).toDouble(),
      totalPassengers: json['total_passengers'] ?? 0,
      averageFare: (json['average_fare'] as num).toDouble(),
      routes: Map<String, double>.from(json['routes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'total_collections': totalCollections,
      'total_fees': totalFees,
      'total_passengers': totalPassengers,
      'average_fare': averageFare,
      'routes': routes,
    };
  }
}
