import '../models/analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Future<PassengerAnalyticsData> getPassengerAnalytics() async {
    await Future.delayed(const Duration(seconds: 2));

    return PassengerAnalyticsData(
      hourlyData: [
        PassengerAnalytics(
            hour: 6, passengerCount: 45, revenue: 3600.0, peakHour: false),
        PassengerAnalytics(
            hour: 7, passengerCount: 120, revenue: 9600.0, peakHour: true),
        PassengerAnalytics(
            hour: 8, passengerCount: 180, revenue: 14400.0, peakHour: true),
        PassengerAnalytics(
            hour: 9, passengerCount: 95, revenue: 7600.0, peakHour: false),
        PassengerAnalytics(
            hour: 10, passengerCount: 60, revenue: 4800.0, peakHour: false),
        PassengerAnalytics(
            hour: 11, passengerCount: 45, revenue: 3600.0, peakHour: false),
        PassengerAnalytics(
            hour: 12, passengerCount: 80, revenue: 6400.0, peakHour: false),
        PassengerAnalytics(
            hour: 13, passengerCount: 65, revenue: 5200.0, peakHour: false),
        PassengerAnalytics(
            hour: 14, passengerCount: 110, revenue: 8800.0, peakHour: true),
        PassengerAnalytics(
            hour: 15, passengerCount: 130, revenue: 10400.0, peakHour: true),
        PassengerAnalytics(
            hour: 16, passengerCount: 160, revenue: 12800.0, peakHour: true),
        PassengerAnalytics(
            hour: 17, passengerCount: 140, revenue: 11200.0, peakHour: true),
        PassengerAnalytics(
            hour: 18, passengerCount: 90, revenue: 7200.0, peakHour: false),
      ],
      totalPassengers: 1320,
      todayPassengers: 1320,
      averageFare: 80.0,
      revenueByRoute: {
        'RIT001': {'passengers': 450, 'revenue': 36000.0},
        'RIT002': {'passengers': 380, 'revenue': 30400.0},
        'RIT003': {'passengers': 490, 'revenue': 39200.0},
      },
    );
  }

  Future<RevenueSummary> getRevenueSummary() async {
    await Future.delayed(const Duration(seconds: 1));

    return RevenueSummary(
      todayRevenue: 105600.0,
      weeklyRevenue: 739200.0,
      monthlyRevenue: 3168000.0,
      totalRevenue: 105600.0,
      todayPassengers: 1320,
      totalPassengers: 1320,
      averageFare: 80.0,
      revenueByRoute: {
        'RIT001': {'passengers': 450, 'revenue': 36000.0},
        'RIT002': {'passengers': 380, 'revenue': 30400.0},
        'RIT003': {'passengers': 490, 'revenue': 39200.0},
      },
    );
  }

  Future<Map<String, double>> getVehicleOccupancy() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'KBS 123A': 0.85,
      'KBS 456B': 0.72,
      'KBS 789C': 0.91,
      'KBS 012D': 0.68,
      'KBS 345E': 0.79,
    };
  }
}
