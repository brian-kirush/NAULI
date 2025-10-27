import 'dart:math';
import '../models/route.dart';
import '../models/vehicle.dart';
import '../models/location.dart';

class GeospatialService {
  static const double earthRadiusKm = 6371.0;

  // Calculate distance between two points using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // Find nearest route stop to current location
  static RouteStop? findNearestStop(
    Location currentLocation,
    List<RouteStop> stops,
  ) {
    if (stops.isEmpty) return null;

    RouteStop? nearestStop;
    double minDistance = double.maxFinite;

    for (var stop in stops) {
      final distance = calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        stop.location.latitude,
        stop.location.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestStop = stop;
      }
    }

    return nearestStop;
  }

  // Check if vehicle is on route (within threshold distance)
  static bool isVehicleOnRoute(
    Vehicle vehicle,
    Route route, {
    double thresholdKm = 0.5, // Fixed: Added curly braces for named parameter
  }) {
    if (vehicle.currentLocation == null) return false;

    // For simplicity, check distance to any route stop
    // In production, you'd check distance to route geometry
    for (var stop in route.stops) {
      final distance = calculateDistance(
        vehicle.currentLocation!.latitude,
        vehicle.currentLocation!.longitude,
        stop.location.latitude,
        stop.location.longitude,
      );

      if (distance <= thresholdKm) {
        return true;
      }
    }

    return false;
  }

  // Calculate ETA to next stop
  static Duration? calculateETA(
    Location currentLocation,
    RouteStop nextStop,
    double averageSpeedKmH,
  ) {
    final distance = calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      nextStop.location.latitude,
      nextStop.location.longitude,
    );

    if (averageSpeedKmH <= 0) return null;

    final hours = distance / averageSpeedKmH;
    return Duration(minutes: (hours * 60).round());
  }

  // Find all vehicles within radius of a point
  static List<Vehicle> findVehiclesInRadius(
    List<Vehicle> vehicles,
    Location center,
    double radiusKm,
  ) {
    return vehicles.where((vehicle) {
      if (vehicle.currentLocation == null) return false;

      final distance = calculateDistance(
        center.latitude,
        center.longitude,
        vehicle.currentLocation!.latitude,
        vehicle.currentLocation!.longitude,
      );

      return distance <= radiusKm;
    }).toList();
  }
}
