import 'package:shared_preferences/shared_preferences.dart';
import '../models/conductor.dart';
import 'http_api_service.dart'; // Add this import

class ConductorService {
  static Conductor? _currentConductor;
  static bool _isOnline = true;

  static Conductor? get currentConductor => _currentConductor;
  static bool get isOnline => _isOnline;

  static Future<bool> login(String username, String password) async {
    try {
      print('🔐 Attempting login for: $username');

      // Use HttpApiService for Supabase authentication
      final result = await HttpApiService.loginConductor(username, password);

      if (result != null) {
        _currentConductor = Conductor(
          id: result['id'] ?? '',
          username: result['username'] ?? '',
          fullName: result['full_name'] ?? 'Conductor',
          vehicleAssigned: result['vehicle_assigned'],
          createdAt: DateTime.parse(
              result['created_at'] ?? DateTime.now().toIso8601String()),
        );

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('conductor_id', _currentConductor!.id);
        await prefs.setString('username', username);
        await prefs.setString(
            'auth_token', 'supabase_token'); // In real app, store actual token

        print('✅ Login successful: ${_currentConductor!.fullName}');
        return true;
      }

      print('❌ Login failed: Invalid credentials');
      return false;
    } catch (e) {
      print('💥 Login error: $e');
      return false;
    }
  }

  static Future<bool> checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final conductorId = prefs.getString('conductor_id');
    final username = prefs.getString('username');

    if (conductorId != null && username != null) {
      // Try to validate with backend
      try {
        // For demo, we'll just restore from local storage
        // In production, validate token with backend
        _currentConductor = Conductor(
          id: conductorId,
          username: username,
          fullName: 'Samuel Kiproitch', // This should come from backend
          vehicleAssigned: 'KBS 123A',
          createdAt: DateTime.now(),
        );
        return true;
      } catch (e) {
        print('❌ Saved login validation failed: $e');
        await logout();
        return false;
      }
    }
    return false;
  }

  // ... rest of the existing methods remain the same
  static Future<void> logout() async {
    _currentConductor = null;

    // Clear saved login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('conductor_id');
    await prefs.remove('username');
    await prefs.remove('auth_token');
  }

  static String getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static void updateOnlineStatus(bool status) {
    _isOnline = status;
  }
}
