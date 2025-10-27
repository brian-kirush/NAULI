import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/location.dart';
import '../services/location_service.dart';
// Removed unused import: '../services/api_service.dart'

class FleetController with ChangeNotifier {
  final List<Vehicle> _vehicles = [];
  final Map<String, Location> _vehicleLocations = {};
  bool _isLoading = false;
  String? _error;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all vehicles
  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call to your backend
      await Future.delayed(const Duration(seconds: 2));

      _vehicles.clear();
      _vehicles.addAll([
        Vehicle(
          id: '1',
          licensePlate: 'KBS 123A',
          vehicleType: 'bus',
          capacity: 45,
          status: 'active',
          currentLocation: Location(latitude: -1.2921, longitude: 36.8219),
          currentSpeed: 45.0,
          fuelLevel: 85,
          lastMaintenance: DateTime.now().subtract(const Duration(days: 15)),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        Vehicle(
          id: '2',
          licensePlate: 'KBS 456B',
          vehicleType: 'minibus',
          capacity: 25,
          status: 'active',
          currentLocation: Location(latitude: -1.2675, longitude: 36.8067),
          currentSpeed: 38.0,
          fuelLevel: 92,
          lastMaintenance: DateTime.now().subtract(const Duration(days: 8)),
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now(),
        ),
        Vehicle(
          id: '3',
          licensePlate: 'KBS 789C',
          vehicleType: 'shuttle',
          capacity: 14,
          status: 'maintenance',
          currentLocation: null,
          currentSpeed: 0.0,
          fuelLevel: 0,
          lastMaintenance: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
        ),
      ]);
    } catch (e) {
      _error = 'Failed to load vehicles: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update vehicle location
  void updateVehicleLocation(String vehicleId, Location location) {
    _vehicleLocations[vehicleId] = location;

    // Update the vehicle in the list
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _vehicles[index] = _vehicles[index].copyWith(currentLocation: location);
      notifyListeners();
    }
  }

  // Start tracking a specific vehicle
  void startTrackingVehicle(String vehicleId) {
    LocationService().startContinuousTracking(vehicleId: vehicleId);
  }

  // Get vehicles by status
  List<Vehicle> getVehiclesByStatus(String status) {
    return _vehicles.where((vehicle) => vehicle.status == status).toList();
  }

  // Get active vehicles (for mapping)
  List<Vehicle> get activeVehicles {
    return _vehicles
        .where((vehicle) =>
            vehicle.status == 'active' && vehicle.currentLocation != null)
        .toList();
  }

  // Find vehicle by license plate
  Vehicle? findVehicleByPlate(String licensePlate) {
    try {
      return _vehicles.firstWhere(
        (vehicle) => vehicle.licensePlate == licensePlate,
      );
    } catch (e) {
      return null;
    }
  }

  // Update vehicle status
  Future<void> updateVehicleStatus(String vehicleId, String status) async {
    try {
      // This would call your backend API
      // For now, just update locally
      await Future.delayed(const Duration(seconds: 1));

      // Update local state
      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles[index] = _vehicles[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update vehicle status: $e';
      notifyListeners();
    }
  }
}
