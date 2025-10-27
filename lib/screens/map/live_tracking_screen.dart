import 'package:flutter/material.dart';
import '../../controllers/fleet_controller.dart';
import '../../models/vehicle.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final FleetController _fleetController = FleetController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    await _fleetController.loadVehicles();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Vehicle Tracking'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
          ),
        ],
      ),
      body: _fleetController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTrackingContent(),
    );
  }

  Widget _buildTrackingContent() {
    final activeVehicles = _fleetController.activeVehicles;

    return Column(
      children: [
        _buildStatsOverview(),
        Expanded(
          child: activeVehicles.isEmpty
              ? _buildNoVehicles()
              : _buildVehicleList(activeVehicles),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    final activeVehicles = _fleetController.activeVehicles;
    final totalVehicles = _fleetController.vehicles.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Active', '${activeVehicles.length}', Colors.green),
          _buildStatItem('Total', '$totalVehicles', Colors.blue),
          _buildStatItem('Offline', '${totalVehicles - activeVehicles.length}',
              Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNoVehicles() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Vehicles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All vehicles are currently offline or in maintenance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(List<Vehicle> vehicles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildVehicleIcon(vehicle),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.licensePlate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.vehicleType.toUpperCase()} • ${vehicle.capacity} seats',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (vehicle.currentLocation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '📍 ${vehicle.currentLocation!.latitude.toStringAsFixed(4)}, '
                      '${vehicle.currentLocation!.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusIndicator(vehicle.status),
                const SizedBox(height: 4),
                if (vehicle.currentSpeed > 0)
                  Text(
                    '${vehicle.currentSpeed.toStringAsFixed(1)} km/h',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (vehicle.fuelLevel > 0)
                  Text(
                    '${vehicle.fuelLevel}% fuel',
                    style: TextStyle(
                      fontSize: 10,
                      color: vehicle.fuelLevel < 20 ? Colors.red : Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleIcon(Vehicle vehicle) {
    IconData icon;
    Color color;

    switch (vehicle.vehicleType) {
      case 'bus':
        icon = Icons.directions_bus;
        color = Colors.blue;
        break;
      case 'minibus':
        icon = Icons.airport_shuttle;
        color = Colors.orange;
        break;
      case 'shuttle':
        icon = Icons.directions_car;
        color = Colors.green;
        break;
      default:
        icon = Icons.directions_bus;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'maintenance':
        color = Colors.orange;
        label = 'Maintenance';
        break;
      case 'offline':
        color = Colors.grey;
        label = 'Offline';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
