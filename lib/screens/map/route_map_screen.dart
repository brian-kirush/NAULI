import 'package:flutter/material.dart' hide Route;
import '../../models/route.dart' as route_model;
import '../../controllers/route_controller.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final RouteController _routeController = RouteController();
  route_model.Route? _selectedRoute;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    await _routeController.loadRoutes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Map'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutes,
          ),
        ],
      ),
      body: _routeController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMapContent(),
    );
  }

  Widget _buildMapContent() {
    final routes = _routeController.activeRoutes;

    return Column(
      children: [
        _buildRouteSelector(routes),
        Expanded(
          child: _buildMapView(),
        ),
        _buildRouteDetails(),
      ],
    );
  }

  Widget _buildRouteSelector(List<route_model.Route> routes) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Route',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<route_model.Route>(
            value: _selectedRoute,
            isExpanded: true,
            hint: const Text('Choose a route...'),
            items: routes.map((route) {
              return DropdownMenuItem<route_model.Route>(
                value: route,
                child: Text('${route.routeCode} - ${route.name}'),
              );
            }).toList(),
            onChanged: (route_model.Route? route) {
              setState(() {
                _selectedRoute = route;
                if (route != null) {
                  _routeController.selectRoute(route);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: _selectedRoute == null
            ? _buildNoRouteSelected()
            : _buildRouteMap(_selectedRoute!),
      ),
    );
  }

  Widget _buildNoRouteSelected() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.map_outlined,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        const Text(
          'Select a route to view on map',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteMap(route_model.Route route) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.blue[50],
          child: CustomPaint(
            painter: RouteMapPainter(route: route),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.routeCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  route.name,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteDetails() {
    if (_selectedRoute == null) {
      return Container();
    }

    final route = _selectedRoute!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Route Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDetailItem('Distance', '${route.totalDistance} km'),
              _buildDetailItem('Base Fare', 'Ksh ${route.baseFare}'),
              _buildDetailItem('Stops', '${route.stops.length}'),
            ],
          ),
          const SizedBox(height: 12),
          _buildStopsList(route.stops),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
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
      ),
    );
  }

  Widget _buildStopsList(List<route_model.RouteStop> stops) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stops.length,
        itemBuilder: (context, index) {
          final stop = stops[index];
          return _buildStopItem(stop, index, stops.length);
        },
      ),
    );
  }

  Widget _buildStopItem(route_model.RouteStop stop, int index, int totalStops) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors
                .grey.shade300), // FIXED: Use shade300 for non-nullable Color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stop ${index + 1}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            stop.stopName,
            style: const TextStyle(
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (stop.zoneFare != null && stop.zoneFare! > 0)
            Text(
              'Ksh ${stop.zoneFare}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green[600] ?? Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class RouteMapPainter extends CustomPainter {
  final route_model.Route route;

  RouteMapPainter({required this.route});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getRouteColor()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final stopPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final path = Path();
    if (route.stops.isNotEmpty) {
      final firstStop = route.stops.first;
      path.moveTo(
        _scaleLongitude(firstStop.location.longitude, size.width),
        _scaleLatitude(firstStop.location.latitude, size.height),
      );

      for (final stop in route.stops.skip(1)) {
        path.lineTo(
          _scaleLongitude(stop.location.longitude, size.width),
          _scaleLatitude(stop.location.latitude, size.height),
        );
      }
    }

    canvas.drawPath(path, paint);

    for (final stop in route.stops) {
      final x = _scaleLongitude(stop.location.longitude, size.width);
      final y = _scaleLatitude(stop.location.latitude, size.height);

      canvas.drawCircle(Offset(x, y), 6, stopPaint);

      textPainter.text = TextSpan(
        text: stop.stopName,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + 8, y - 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  Color _getRouteColor() {
    try {
      return Color(int.parse(route.colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  double _scaleLongitude(double longitude, double maxWidth) {
    return (longitude + 180) / 360 * maxWidth;
  }

  double _scaleLatitude(double latitude, double maxHeight) {
    return (90 - latitude) / 180 * maxHeight;
  }
}
