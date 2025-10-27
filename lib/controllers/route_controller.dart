import 'package:flutter/material.dart' hide Route;
import '../models/route.dart';
import '../models/location.dart';
import '../services/geospatial_service.dart';
// Removed unused import: '../services/api_service.dart'

class RouteController with ChangeNotifier {
  final List<Route> _routes = [];
  Route? _selectedRoute;
  bool _isLoading = false;
  String? _error;

  List<Route> get routes => _routes;
  Route? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all routes
  Future<void> loadRoutes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call to your backend
      await Future.delayed(const Duration(seconds: 2));

      _routes.clear();
      _routes.addAll([
        Route(
          id: '1',
          routeCode: 'RIT001',
          name: 'Nairobi CBD - Westlands',
          startPoint: 'Nairobi CBD',
          endPoint: 'Westlands',
          totalDistance: 8.5,
          baseFare: 80.0,
          status: 'active',
          colorHex: '#3366FF',
          stops: [
            RouteStop(
              id: '1',
              routeId: '1',
              stopName: 'CBD Terminus',
              sequenceOrder: 1,
              location: Location(latitude: -1.2921, longitude: 36.8219),
              zoneFare: 0.0,
            ),
            RouteStop(
              id: '2',
              routeId: '1',
              stopName: 'University Way',
              sequenceOrder: 2,
              location: Location(latitude: -1.2834, longitude: 36.8178),
              zoneFare: 40.0,
            ),
            RouteStop(
              id: '3',
              routeId: '1',
              stopName: 'Westlands Stage',
              sequenceOrder: 3,
              location: Location(latitude: -1.2675, longitude: 36.8067),
              zoneFare: 80.0,
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        Route(
          id: '2',
          routeCode: 'RIT002',
          name: 'Westlands - Nairobi CBD',
          startPoint: 'Westlands',
          endPoint: 'Nairobi CBD',
          totalDistance: 8.5,
          baseFare: 80.0,
          status: 'active',
          colorHex: '#FF6633',
          stops: [
            RouteStop(
              id: '4',
              routeId: '2',
              stopName: 'Westlands Stage',
              sequenceOrder: 1,
              location: Location(latitude: -1.2675, longitude: 36.8067),
              zoneFare: 0.0,
            ),
            RouteStop(
              id: '5',
              routeId: '2',
              stopName: 'University Way',
              sequenceOrder: 2,
              location: Location(latitude: -1.2834, longitude: 36.8178),
              zoneFare: 40.0,
            ),
            RouteStop(
              id: '6',
              routeId: '2',
              stopName: 'CBD Terminus',
              sequenceOrder: 3,
              location: Location(latitude: -1.2921, longitude: 36.8219),
              zoneFare: 80.0,
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
      ]);
    } catch (e) {
      _error = 'Failed to load routes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a route
  void selectRoute(Route route) {
    _selectedRoute = route;
    notifyListeners();
  }

  // Clear selected route
  void clearSelectedRoute() {
    _selectedRoute = null;
    notifyListeners();
  }

  // Find route by code
  Route? findRouteByCode(String routeCode) {
    try {
      return _routes.firstWhere((route) => route.routeCode == routeCode);
    } catch (e) {
      return null;
    }
  }

  // Get active routes only
  List<Route> get activeRoutes {
    return _routes.where((route) => route.status == 'active').toList();
  }

  // Calculate fare between stops
  double calculateFareBetweenStops(RouteStop fromStop, RouteStop toStop) {
    // Simple calculation based on sequence difference
    final stopDifference =
        (toStop.sequenceOrder - fromStop.sequenceOrder).abs();
    return stopDifference * 40.0; // 40 KSH per stop segment
  }

  // Find nearest stop on any route
  RouteStop? findNearestStop(Location location) {
    RouteStop? nearestStop;
    double minDistance = double.maxFinite;

    for (var route in _routes) {
      for (var stop in route.stops) {
        final distance = GeospatialService.calculateDistance(
          location.latitude,
          location.longitude,
          stop.location.latitude,
          stop.location.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestStop = stop;
        }
      }
    }

    return nearestStop;
  }

  // Create new route
  Future<void> createRoute(Map<String, dynamic> routeData) async {
    try {
      // This would call your backend API
      // For now, just add locally
      await Future.delayed(const Duration(seconds: 1));

      final newRoute = Route(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        routeCode: routeData['routeCode'] ?? 'NEW001',
        name: routeData['name'] ?? 'New Route',
        startPoint: routeData['startPoint'] ?? 'Start',
        endPoint: routeData['endPoint'] ?? 'End',
        totalDistance: routeData['totalDistance'] ?? 0.0,
        baseFare: routeData['baseFare'] ?? 50.0,
        status: 'active',
        colorHex: routeData['colorHex'] ?? '#3366FF',
        stops: [],
        createdAt: DateTime.now(),
      );

      _routes.add(newRoute);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create route: $e';
      notifyListeners();
    }
  }
}
