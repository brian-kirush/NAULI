import '../models/analytics.dart';
import '../services/analytics_service.dart';

class AnalyticsController {
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _isLoading = false;
  List<PassengerAnalytics> _hourlyAnalytics = [];
  RevenueSummary? _revenueSummary;
  Map<String, Map<String, dynamic>> _routePerformance = {};
  Map<String, double> _vehicleOccupancy = {};

  bool get isLoading => _isLoading;
  List<PassengerAnalytics> get hourlyAnalytics => _hourlyAnalytics;
  RevenueSummary? get revenueSummary => _revenueSummary;
  Map<String, Map<String, dynamic>> get routePerformance => _routePerformance;
  Map<String, double> get vehicleOccupancy => _vehicleOccupancy;

  int get todayPassengers => _revenueSummary?.todayPassengers ?? 0;
  double? get todayRevenue => _revenueSummary?.todayRevenue;

  List<int> get peakHours {
    if (_hourlyAnalytics.isEmpty) return [];

    final sortedByPassengers = List<PassengerAnalytics>.from(_hourlyAnalytics)
      ..sort((a, b) => b.passengerCount.compareTo(a.passengerCount));

    return sortedByPassengers.take(3).map((data) => data.hour).toList();
  }

  String? get bestPerformingRoute {
    if (_routePerformance.isEmpty) return null;

    var bestRoute = '';
    var highestRevenue = 0.0;

    _routePerformance.forEach((routeCode, data) {
      final revenue = data['revenue'] as double;
      if (revenue > highestRevenue) {
        highestRevenue = revenue;
        bestRoute = routeCode;
      }
    });

    return bestRoute;
  }

  Future<void> loadAnalytics() async {
    _isLoading = true;

    try {
      final passengerData = await _analyticsService.getPassengerAnalytics();
      _hourlyAnalytics = passengerData.hourlyData;

      _revenueSummary = await _analyticsService.getRevenueSummary();

      _vehicleOccupancy = await _analyticsService.getVehicleOccupancy();

      _routePerformance = passengerData.revenueByRoute.map((key, value) {
        return MapEntry(key, {
          'passengers': value['passengers'],
          'revenue': value['revenue'],
        });
      });
    } catch (e) {
      print('Error loading analytics: $e');
    } finally {
      _isLoading = false;
    }
  }
}
