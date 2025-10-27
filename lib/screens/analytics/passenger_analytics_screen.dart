import 'package:flutter/material.dart';
import '../../controllers/analytics_controller.dart';
import '../../models/analytics.dart';

class PassengerAnalyticsScreen extends StatefulWidget {
  const PassengerAnalyticsScreen({super.key});

  @override
  State<PassengerAnalyticsScreen> createState() =>
      _PassengerAnalyticsScreenState();
}

class _PassengerAnalyticsScreenState extends State<PassengerAnalyticsScreen> {
  final AnalyticsController _analyticsController = AnalyticsController();
  List<PassengerAnalytics> _hourlyData = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    await _analyticsController.loadAnalytics();
    setState(() {
      _hourlyData = _analyticsController.hourlyAnalytics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Analytics'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _analyticsController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAnalyticsContent(),
    );
  }

  Widget _buildAnalyticsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildHourlyChart(),
          const SizedBox(height: 24),
          _buildPeakHours(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Passengers',
            '${_analyticsController.todayPassengers}',
            Colors.blue,
            Icons.people,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Today Revenue',
            'Ksh ${(_analyticsController.todayRevenue ?? 0.0).toStringAsFixed(2)}', // Changed 0 to 0.0
            Colors.green,
            Icons.attach_money,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hourly Passenger Traffic',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _hourlyData.length,
                itemBuilder: (context, index) {
                  final data = _hourlyData[index];
                  return _buildHourlyBar(data);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyBar(PassengerAnalytics data) {
    final maxPassengers = _hourlyData
        .map((e) => e.passengerCount)
        .reduce((a, b) => a > b ? a : b);
    final heightFactor =
        maxPassengers > 0 ? data.passengerCount / maxPassengers : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 20,
            height: (150 * heightFactor).toDouble(),
            decoration: BoxDecoration(
              color: data.peakHour ? Colors.orange : Colors.blue,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.hour}:00',
            style: const TextStyle(fontSize: 10),
          ),
          Text(
            '${data.passengerCount}',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakHours() {
    final peakHours = _analyticsController.peakHours;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Peak Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: peakHours.map((hour) {
                return Chip(
                  label: Text('${hour}:00'),
                  backgroundColor: Colors.orange.withAlpha(25),
                  labelStyle: const TextStyle(color: Colors.orange),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
