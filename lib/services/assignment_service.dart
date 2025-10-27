import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../models/vehicle.dart';
import '../models/route.dart' as route_model; // Use alias
// Removed unused api_service.dart import
import 'conductor_service.dart';

class AssignmentService {
  static final AssignmentService _instance = AssignmentService._internal();
  factory AssignmentService() => _instance;
  AssignmentService._internal();

  // Get current assignments for a conductor
  Future<List<VehicleAssignment>> getConductorAssignments(
      String conductorId) async {
    try {
      // This would call your backend API
      // For now, returning sample data that integrates with your system

      return [
        VehicleAssignment(
          id: '1',
          vehicleId: '1',
          conductorId: conductorId,
          routeId: '1',
          scheduleStart: const TimeOfDay(hour: 6, minute: 0),
          scheduleEnd: const TimeOfDay(hour: 14, minute: 0),
          daysOfWeek: [1, 2, 3, 4, 5], // Monday to Friday
          status: 'active',
          assignedAt: DateTime.now().subtract(const Duration(days: 7)),
          vehicle: Vehicle(
            id: '1',
            licensePlate: 'KBS 123A',
            vehicleType: 'bus',
            capacity: 45,
            status: 'active',
            currentLocation: null,
            currentSpeed: 0.0,
            fuelLevel: 0,
            lastMaintenance: DateTime.now(),
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            updatedAt: DateTime.now(),
          ),
          route: route_model.Route(
            // Use aliased Route
            id: '1',
            routeCode: 'RIT001',
            name: 'Nairobi CBD - Westlands',
            startPoint: 'Nairobi CBD',
            endPoint: 'Westlands',
            totalDistance: 8.5,
            baseFare: 80.0,
            status: 'active',
            colorHex: '#3366FF',
            stops: [],
            createdAt: DateTime.now().subtract(const Duration(days: 60)),
          ),
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch assignments: $e');
    }
  }

  // Assign vehicle to conductor
  Future<void> assignVehicle({
    required String vehicleId,
    required String conductorId,
    required String routeId,
    required TimeOfDay scheduleStart,
    required TimeOfDay scheduleEnd,
    required List<int> daysOfWeek,
  }) async {
    // Implementation for assigning vehicle
    // This would call your backend API

    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
  }

  // Start an assignment (when conductor starts their shift)
  Future<void> startAssignment(String assignmentId) async {
    // Implementation for starting assignment
    await Future.delayed(const Duration(seconds: 1));
  }

  // Complete an assignment (when conductor ends their shift)
  Future<void> completeAssignment(String assignmentId) async {
    // Implementation for completing assignment
    await Future.delayed(const Duration(seconds: 1));
  }

  // Get available vehicles for assignment
  Future<List<Vehicle>> getAvailableVehicles() async {
    // This would fetch from your backend
    return [
      Vehicle(
        id: '1',
        licensePlate: 'KBS 123A',
        vehicleType: 'bus',
        capacity: 45,
        status: 'active',
        currentLocation: null,
        currentSpeed: 0.0,
        fuelLevel: 0,
        lastMaintenance: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Vehicle(
        id: '2',
        licensePlate: 'KBS 456B',
        vehicleType: 'minibus',
        capacity: 25,
        status: 'active',
        currentLocation: null,
        currentSpeed: 0.0,
        fuelLevel: 0,
        lastMaintenance: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Get current assignment for logged-in conductor
  Future<VehicleAssignment?> getCurrentAssignment() async {
    final conductor = ConductorService.currentConductor;
    if (conductor == null) return null;

    final assignments = await getConductorAssignments(conductor.id);
    return assignments.firstWhere(
      (assignment) => assignment.isCurrentlyActive,
      orElse: () => assignments.isNotEmpty
          ? assignments.first
          : throw StateError('No assignments'),
    );
  }
}
