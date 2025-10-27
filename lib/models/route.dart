import 'location.dart';

class Route {
  final String id;
  final String routeCode;
  final String name;
  final String startPoint;
  final String endPoint;
  final double totalDistance;
  final Duration? estimatedDuration;
  final double baseFare;
  final String status;
  final String colorHex;
  final List<RouteStop> stops;
  final DateTime createdAt;

  Route({
    required this.id,
    required this.routeCode,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.totalDistance,
    this.estimatedDuration,
    required this.baseFare,
    required this.status,
    required this.colorHex,
    required this.stops,
    required this.createdAt,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    final stops = (json['route_stops'] as List<dynamic>?)
            ?.map((stop) => RouteStop.fromJson(stop))
            .toList() ??
        [];

    return Route(
      id: json['id'] ?? '',
      routeCode: json['route_code'] ?? '',
      name: json['name'] ?? '',
      startPoint: json['start_point'] ?? '',
      endPoint: json['end_point'] ?? '',
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0.0,
      estimatedDuration: json['estimated_duration'] != null
          ? Duration(seconds: json['estimated_duration'])
          : null,
      baseFare: (json['base_fare'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'active',
      colorHex: json['color_hex'] ?? '#3366FF',
      stops: stops,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_code': routeCode,
      'name': name,
      'start_point': startPoint,
      'end_point': endPoint,
      'total_distance': totalDistance,
      'estimated_duration': estimatedDuration?.inSeconds,
      'base_fare': baseFare,
      'status': status,
      'color_hex': colorHex,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class RouteStop {
  final String id;
  final String routeId;
  final String stopName;
  final String? stopCode;
  final int sequenceOrder;
  final Location location;
  final double? zoneFare;
  final Duration? arrivalEstimate;

  RouteStop({
    required this.id,
    required this.routeId,
    required this.stopName,
    this.stopCode,
    required this.sequenceOrder,
    required this.location,
    this.zoneFare,
    this.arrivalEstimate,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'] ?? '',
      routeId: json['route_id'] ?? '',
      stopName: json['stop_name'] ?? '',
      stopCode: json['stop_code'],
      sequenceOrder: json['sequence_order'] ?? 0,
      location: Location.fromJson(json['location'] ?? {}),
      zoneFare: json['zone_fare']?.toDouble(),
      arrivalEstimate: json['arrival_estimate'] != null
          ? Duration(seconds: json['arrival_estimate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'stop_name': stopName,
      'stop_code': stopCode,
      'sequence_order': sequenceOrder,
      'location': location.toJson(),
      'zone_fare': zoneFare,
      'arrival_estimate': arrivalEstimate?.inSeconds,
    };
  }
}
