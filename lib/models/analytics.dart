class PassengerAnalytics {
  final int hour;
  final int passengerCount;
  final double revenue;
  final bool peakHour;

  PassengerAnalytics({
    required this.hour,
    required this.passengerCount,
    required this.revenue,
    required this.peakHour,
  });
}

class RevenueSummary {
  final double todayRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;
  final double totalRevenue;
  final int todayPassengers;
  final int totalPassengers;
  final double averageFare;
  final Map<String, dynamic> revenueByRoute;

  RevenueSummary({
    required this.todayRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.totalRevenue,
    required this.todayPassengers,
    required this.totalPassengers,
    required this.averageFare,
    required this.revenueByRoute,
  });
}

class PassengerAnalyticsData {
  final List<PassengerAnalytics> hourlyData;
  final int totalPassengers;
  final int todayPassengers;
  final double averageFare;
  final Map<String, dynamic> revenueByRoute;

  PassengerAnalyticsData({
    required this.hourlyData,
    required this.totalPassengers,
    required this.todayPassengers,
    required this.averageFare,
    required this.revenueByRoute,
  });
}
