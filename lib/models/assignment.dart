import 'package:flutter/material.dart' hide Route; // Hide Route from material
import '../models/route.dart' as route_model; // Use alias for Route
import '../models/vehicle.dart';
// Removed unused location.dart import

class VehicleAssignment {
  final String id;
  final String vehicleId;
  final String conductorId;
  final String routeId;
  final TimeOfDay scheduleStart;
  final TimeOfDay scheduleEnd;
  final List<int> daysOfWeek;
  final String status;
  final DateTime assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Vehicle? vehicle;
  final route_model.Route? route; // Use aliased Route

  VehicleAssignment({
    required this.id,
    required this.vehicleId,
    required this.conductorId,
    required this.routeId,
    required this.scheduleStart,
    required this.scheduleEnd,
    required this.daysOfWeek,
    required this.status,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.vehicle,
    this.route,
  });

  factory VehicleAssignment.fromJson(Map<String, dynamic> json) {
    return VehicleAssignment(
      id: json['id'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
      conductorId: json['conductor_id'] ?? '',
      routeId: json['route_id'] ?? '',
      scheduleStart: _parseTime(json['schedule_start'] ?? '06:00'),
      scheduleEnd: _parseTime(json['schedule_end'] ?? '18:00'),
      daysOfWeek: List<int>.from(json['days_of_week'] ?? [1, 2, 3, 4, 5]),
      status: json['status'] ?? 'scheduled',
      assignedAt: DateTime.parse(json['assigned_at']),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      vehicle:
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      route: json['route'] != null
          ? route_model.Route.fromJson(json['route'])
          : null,
    );
  }

  static TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool get isActiveToday {
    final today = DateTime.now().weekday;
    return daysOfWeek.contains(today);
  }

  bool get isCurrentlyActive {
    if (!isActiveToday) return false;

    final now = TimeOfDay.now();
    return now.hour >= scheduleStart.hour && now.hour <= scheduleEnd.hour;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'conductor_id': conductorId,
      'route_id': routeId,
      'schedule_start':
          '${scheduleStart.hour.toString().padLeft(2, '0')}:${scheduleStart.minute.toString().padLeft(2, '0')}',
      'schedule_end':
          '${scheduleEnd.hour.toString().padLeft(2, '0')}:${scheduleEnd.minute.toString().padLeft(2, '0')}',
      'days_of_week': daysOfWeek,
      'status': status,
      'assigned_at': assignedAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
