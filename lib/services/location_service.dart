import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location.dart';

// Mock classes since geolocator package might not be available
class Position {
  final double latitude;
  final double longitude;
  final double speed;

  Position(
      {required this.latitude, required this.longitude, required this.speed});
}

class Geolocator {
  static Future<bool> isLocationServiceEnabled() async => true;

  static Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  static Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;

  static Future<Position> getCurrentPosition({
    required LocationAccuracy desiredAccuracy,
  }) async {
    return Position(
      latitude: -1.2921,
      longitude: 36.8219,
      speed: 0.0,
    );
  }

  static double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return 0.0;
  }
}

enum LocationPermission { denied, whileInUse, always }

enum LocationAccuracy { best }

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final _locationController = StreamController<Location>.broadcast();
  final _positionController = StreamController<Position>.broadcast();

  Stream<Location> get locationStream => _locationController.stream;
  Stream<Position> get positionStream => _positionController.stream;

  Timer? _trackingTimer;
  bool _isTracking = false;

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.denied) {
      return false;
    }

    return true;
  }

  void startContinuousTracking({
    required String vehicleId,
    Duration interval = const Duration(seconds: 10),
  }) {
    if (_isTracking) return;

    _isTracking = true;
    _trackingTimer = Timer.periodic(interval, (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        // Update local vehicle location
        final location = Location(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        _locationController.add(location);
        _positionController.add(position);

        // Send to backend - INTEGRATES WITH YOUR EXISTING SYSTEM
        await _sendLocationToServer(vehicleId, position);
      } catch (e) {
        debugPrint('Location tracking error: $e');
      }
    });
  }

  void stopTracking() {
    _trackingTimer?.cancel();
    _isTracking = false;
  }

  Future<void> _sendLocationToServer(
      String vehicleId, Position position) async {
    try {
      // TODO: Add this endpoint to your backend
      // This would call your existing ApiService
      debugPrint(
          '📍 Vehicle $vehicleId at ${position.latitude}, ${position.longitude}');

      // Example of how to integrate with your backend:
      // await ApiService.updateVehicleLocation(
      //   vehicleId: vehicleId,
      //   latitude: position.latitude,
      //   longitude: position.longitude,
      //   speed: position.speed,
      // );
    } catch (e) {
      debugPrint('Error sending location to server: $e');
    }
  }

  Future<double> calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    return Geolocator.distanceBetween(
          startLat,
          startLng,
          endLat,
          endLng,
        ) /
        1000; // Convert to kilometers
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  void dispose() {
    stopTracking();
    _locationController.close();
    _positionController.close();
  }
}
