import 'location.dart'; // Import Location

class Stop {
  final String id;
  final String name;
  final String? code;
  final Location location;
  final String? address;
  final String status;
  final DateTime createdAt;

  Stop({
    required this.id,
    required this.name,
    this.code,
    required this.location,
    this.address,
    required this.status,
    required this.createdAt,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'],
      location: Location.fromJson(json['location'] ?? {}),
      address: json['address'],
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'location': location.toJson(),
      'address': address,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
