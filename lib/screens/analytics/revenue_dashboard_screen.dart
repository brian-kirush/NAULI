import 'package:flutter/material.dart';
import '../../controllers/analytics_controller.dart';
import '../../models/analytics.dart'; // Import the RevenueSummary class

class RevenueDashboardScreen extends StatefulWidget {
  const RevenueDashboardScreen({super.key});

  @override
  State<RevenueDashboardScreen> createState() => _RevenueDashboardScreenState();
}

class _RevenueDashboardScreenState extends State<RevenueDashboardScreen> {
  final AnalyticsController _analyticsController = AnalyticsController();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    await _analyticsController.loadAnalytics();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _analyticsController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    final summary = _analyticsController.revenueSummary;

    if (summary == null) {
      return const Center(child: Text('No revenue data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRevenueOverview(summary),
          const SizedBox(height: 24),
          _buildRoutePerformance(),
          const SizedBox(height: 24),
          _buildVehicleOccupancy(),
        ],
      ),
    );
  }

  Widget _buildRevenueOverview(RevenueSummary summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRevenueMetric(
                    'Today',
                    'Ksh ${summary.todayRevenue.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildRevenueMetric(
                    'This Week',
                    'Ksh ${summary.weeklyRevenue.toStringAsFixed(2)}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildRevenueMetric(
                    'This Month',
                    'Ksh ${summary.monthlyRevenue.toStringAsFixed(2)}',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRevenueMetric(
              'Total Revenue',
              'Ksh ${summary.totalRevenue.toStringAsFixed(2)}',
              Colors.purple,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueMetric(String label, String value, Color color,
      {bool isTotal = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoutePerformance() {
    final routePerformance = _analyticsController.routePerformance;
    final bestRoute = _analyticsController.bestPerformingRoute;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Route Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (bestRoute != null) ...[
              const SizedBox(height: 8),
              Text(
                'Best Performing: $bestRoute',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...routePerformance.entries.map((entry) {
              final routeCode = entry.key;
              final data = entry.value;
              return _buildRoutePerformanceRow(routeCode, data);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutePerformanceRow(
      String routeCode, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              routeCode,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Ksh ${(data['revenue'] as double).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                '${data['passengers']} passengers',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleOccupancy() {
    final vehicleOccupancy = _analyticsController.vehicleOccupancy;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Occupancy Rates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...vehicleOccupancy.entries.map((entry) {
              return _buildOccupancyRow(entry.key, entry.value);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyRow(String vehiclePlate, double occupancy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              vehiclePlate,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: occupancy,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancy > 0.7
                    ? Colors.green
                    : occupancy > 0.4
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(occupancy * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: occupancy > 0.7
                  ? Colors.green
                  : occupancy > 0.4
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
