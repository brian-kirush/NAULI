import 'location.dart'; // Import Location class

class Vehicle {
  final String id;
  final String licensePlate;
  final String vehicleType;
  final int capacity;
  final String status;
  final Location? currentLocation;
  final double currentSpeed;
  final int fuelLevel;
  final DateTime lastMaintenance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.vehicleType,
    required this.capacity,
    required this.status,
    this.currentLocation,
    required this.currentSpeed,
    required this.fuelLevel,
    required this.lastMaintenance,
    required this.createdAt,
    required this.updatedAt,
  });

  Vehicle copyWith({
    String? id,
    String? licensePlate,
    String? vehicleType,
    int? capacity,
    String? status,
    Location? currentLocation,
    double? currentSpeed,
    int? fuelLevel,
    DateTime? lastMaintenance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      capacity: json['capacity'] ?? 0,
      status: json['status'] ?? '',
      currentLocation: json['current_location'] != null
          ? Location.fromJson(json['current_location'])
          : null,
      currentSpeed: json['current_speed']?.toDouble() ?? 0.0,
      fuelLevel: json['fuel_level'] ?? 0,
      lastMaintenance: DateTime.parse(json['last_maintenance']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_plate': licensePlate,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'status': status,
      'current_location': currentLocation?.toJson(),
      'current_speed': currentSpeed,
      'fuel_level': fuelLevel,
      'last_maintenance': lastMaintenance.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
