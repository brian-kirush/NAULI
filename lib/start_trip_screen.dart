import 'package:flutter/material.dart';
import 'fare_collection_screen.dart';
import 'services/conductor_service.dart';

class StartTripScreen extends StatefulWidget {
  const StartTripScreen({super.key});

  @override
  State<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTripScreen> {
  String? _selectedRoute;
  int _selectedFare = 80;
  int _passengerCapacity = 14;
  final List<int> _quickFares = [50, 80, 100, 120, 150];
  final List<int> _commonCapacities = [14, 22, 33];

  // Custom route and fare management
  final TextEditingController _customRouteController = TextEditingController();
  final TextEditingController _customFareController = TextEditingController();
  final List<String> _customRoutes = [];
  final List<int> _customFares = [];

  @override
  void initState() {
    super.initState();
    // Load saved custom routes and fares (you can replace with actual storage)
    _loadCustomData();
  }

  void _loadCustomData() {
    // Simulate loading custom data - replace with actual storage
    setState(() {
      _customRoutes
          .addAll(['RIT004 - CBD - Karen', 'RIT005 - Westlands - JKIA']);
      _customFares.addAll([90, 120]);
    });
  }

  @override
  void dispose() {
    _customRouteController.dispose();
    _customFareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRoutes = [
      'RIT001 - Nairobi CBD - Westlands',
      'RIT002 - Westlands - Nairobi CBD',
      'RIT003 - CBD - Thika Road',
      ..._customRoutes,
    ];

    final allFares = [..._quickFares, ..._customFares]..sort();

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Start New Trip',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_getCurrentDate()} - ${_getCurrentTime()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Select Route Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Route',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddRouteDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Add Route',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedRoute,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Choose route'),
                  items: allRoutes.map((route) {
                    return DropdownMenuItem(
                      value: route,
                      child: Text(route),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoute = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Set Fare Amount Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Set Fare Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddFareDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Add Fare',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Use Suggested',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Fare Input
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Ksh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: TextEditingController(
                            text: _selectedFare.toString()),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedFare =
                                int.tryParse(value) ?? _selectedFare;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Range: Ksh 20 - Ksh 500',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Select Fares
              const Text(
                'Quick Select',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allFares.map((fare) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFare = fare;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedFare == fare
                            ? Colors.blue[700]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Ksh $fare',
                        style: TextStyle(
                          color: _selectedFare == fare
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Passenger Capacity Section
              const Text(
                'Passenger Capacity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Matatu',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '$_passengerCapacity passengers',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Common Capacities
              const Text(
                'Common Capacities',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonCapacities.map((capacity) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _passengerCapacity = capacity;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _passengerCapacity == capacity
                            ? Colors.blue[700]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$capacity',
                        style: TextStyle(
                          color: _passengerCapacity == capacity
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Platform Fee Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Platform fee: Ksh 2 per passenger will be deducted from collections',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Start Trip Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedRoute != null
                      ? () {
                          _startTrip(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Start Trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRouteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Custom Route'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customRouteController,
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  hintText: 'e.g., RIT006 - CBD - Karen',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text(
                'Format: RouteID - Start - Destination',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _customRouteController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final routeName = _customRouteController.text.trim();
                if (routeName.isNotEmpty) {
                  setState(() {
                    _customRoutes.add(routeName);
                    _selectedRoute = routeName;
                  });
                  Navigator.pop(context);
                  _customRouteController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Route "$routeName" added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add Route'),
            ),
          ],
        );
      },
    );
  }

  void _showAddFareDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Custom Fare'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customFareController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Fare Amount (Ksh)',
                  hintText: 'e.g., 75',
                  border: OutlineInputBorder(),
                  prefixText: 'Ksh ',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Range: Ksh 20 - Ksh 500',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _customFareController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final fareText = _customFareController.text.trim();
                final fare = int.tryParse(fareText);

                if (fare != null && fare >= 20 && fare <= 500) {
                  setState(() {
                    if (!_customFares.contains(fare)) {
                      _customFares.add(fare);
                    }
                    _selectedFare = fare;
                  });
                  Navigator.pop(context);
                  _customFareController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fare Ksh $fare added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please enter a valid fare between Ksh 20 and Ksh 500'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add Fare'),
            ),
          ],
        );
      },
    );
  }

  void _startTrip(BuildContext context) {
    final conductor = ConductorService.currentConductor;
    if (conductor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conductor not logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to fare collection screen with trip details
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FareCollectionScreen(
          route: _selectedRoute!,
          fare: _selectedFare,
          passengerCapacity: _passengerCapacity,
          conductorId: conductor.id,
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
