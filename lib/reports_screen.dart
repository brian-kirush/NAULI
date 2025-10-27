import 'package:flutter/material.dart';
import '../models/daily_report.dart'; // FIXED: Import the correct file

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _reportType = 'daily';

  final Map<String, List<DailyReport>> _sampleReports = {};

  @override
  void initState() {
    super.initState();
    _generateSampleData();
  }

  void _generateSampleData() {
    final now = DateTime.now();

    _sampleReports['daily'] = [
      DailyReport(
        date: now,
        totalCollections: 2450,
        totalFees: 56,
        totalPassengers: 28,
        averageFare: 87.5,
        routes: {
          'RIT001 - Nairobi CBD - Westlands': 1250,
          'RIT002 - Westlands - Nairobi CBD': 800,
          'RIT003 - CBD - Thika Road': 400,
        },
      ),
      DailyReport(
        date: now.subtract(const Duration(days: 1)),
        totalCollections: 1920,
        totalFees: 44,
        totalPassengers: 22,
        averageFare: 87.3,
        routes: {
          'RIT001 - Nairobi CBD - Westlands': 1000,
          'RIT002 - Westlands - Nairobi CBD': 720,
          'RIT003 - CBD - Thika Road': 200,
        },
      ),
    ];

    _sampleReports['weekly'] = [
      DailyReport(
        date: now,
        totalCollections: 15680,
        totalFees: 358,
        totalPassengers: 179,
        averageFare: 87.6,
        routes: {
          'RIT001 - Nairobi CBD - Westlands': 8450,
          'RIT002 - Westlands - Nairobi CBD': 5120,
          'RIT003 - CBD - Thika Road': 2110,
        },
      ),
    ];

    _sampleReports['monthly'] = [
      DailyReport(
        date: now,
        totalCollections: 65200,
        totalFees: 1520,
        totalPassengers: 745,
        averageFare: 87.5,
        routes: {
          'RIT001 - Nairobi CBD - Westlands': 35200,
          'RIT002 - Westlands - Nairobi CBD': 21800,
          'RIT003 - CBD - Thika Road': 8200,
        },
      ),
    ];
  }

  List<DailyReport> get _currentReports {
    return _sampleReports[_reportType] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final reports = _currentReports;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: _shareReport,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.black87),
            onPressed: _generatePDF,
          ),
        ],
      ),
      body: Column(
        children: [
          // Report Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _reportType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'daily', child: Text('Daily Report')),
                          DropdownMenuItem(
                              value: 'weekly', child: Text('Weekly Report')),
                          DropdownMenuItem(
                              value: 'monthly', child: Text('Monthly Report')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _reportType = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _showDateRangePicker,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_startDate.day}/${_startDate.month} - ${_endDate.day}/${_endDate.month}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Generate Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Platform Fee Notice
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange.withValues(alpha: 0.1), // FIXED: withValues
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.orange.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Platform fee: Ksh 2 per transaction',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: reports.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assessment, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No reports available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Generate a report to see analytics',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _buildReportCard(report);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(DailyReport report) {
    final platformFeePerTransaction = 2.0;
    final calculatedFees = report.totalPassengers * platformFeePerTransaction;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1), // FIXED: withValues
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${report.date.day}/${report.date.month}/${report.date.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      Colors.green.withValues(alpha: 0.1), // FIXED: withValues
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Ksh ${report.netAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Key Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                  'Collections', 'Ksh ${report.totalCollections}', Colors.blue),
              _buildMetricItem(
                  'Fees', 'Ksh ${report.totalFees}', Colors.orange),
              _buildMetricItem(
                  'Passengers', '${report.totalPassengers}', Colors.green),
              _buildMetricItem(
                  'Avg Fare',
                  'Ksh ${report.averageFare.toStringAsFixed(1)}',
                  Colors.purple),
            ],
          ),

          // Platform Fee Breakdown
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05), // FIXED: withValues
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Platform Fee Calculation:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${report.totalPassengers} passengers × Ksh 2 = Ksh $calculatedFees',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Route Breakdown
          const Text(
            'Route Performance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          ...report.routes.entries.map((entry) {
            final percentage = (entry.value / report.totalCollections * 100)
                .toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Ksh ${entry.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), // FIXED: withValues
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.trending_up,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_reportType report generated for selected period'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share report functionality'),
      ),
    );
  }

  void _generatePDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF generation functionality'),
      ),
    );
  }
}
