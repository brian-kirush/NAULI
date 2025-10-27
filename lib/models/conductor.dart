class Conductor {
  final String id;
  final String username;
  final String fullName;
  final String? vehicleAssigned;
  final DateTime createdAt;

  Conductor({
    required this.id,
    required this.username,
    required this.fullName,
    this.vehicleAssigned,
    required this.createdAt,
  });

  factory Conductor.fromJson(Map<String, dynamic> json) {
    return Conductor(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      vehicleAssigned: json['vehicle_assigned'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'vehicle_assigned': vehicleAssigned,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
