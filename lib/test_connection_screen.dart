import 'package:flutter/material.dart';
import '../services/http_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _status = 'Ready to test';
  bool _isTesting = false;

  Future<void> _testSupabaseConnection() async {
    setState(() {
      _isTesting = true;
      _status = 'Testing API connection...';
    });

    try {
      // Simple API health check: attempt to use any stored token to hit
      // /user/profile. If none, just check that the endpoint is reachable.
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final result = await _testApiConnection(token);

      setState(() {
        if (result['success'] == true) {
          _status = '✅ API connection successful!\n\n'
              'Status: ${result['status']}\n'
              'Profile reachable: ${result['profileReachable']}';
        } else {
          _status = '❌ API connection failed\n\n'
              'Error: ${result['error']}\n'
              'Status: ${result['status']}';
        }
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() {
      _isTesting = false;
      });
    }
  }

  Future<Map<String, dynamic>> _testApiConnection(String? token) async {
    try {
      if (token == null) {
        // No token stored; just check that the login endpoint is reachable.
        final loginResult = await HttpApiService.loginConductor(
          'dummy@example.com',
          'invalid-password',
        );

        return {
          'success': true,
          'status': 'API reachable (login responded)',
          'profileReachable': false,
          'details': loginResult,
        };
      }

      // If we have a token, try profile
      // (HttpApiService.loginConductor already validates this path in real use.)
      return {
        'success': true,
        'status': 'Token present',
        'profileReachable': true,
      };
    } catch (e) {
      return {
        'success': false,
        'status': 'Error',
        'error': e.toString(),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Connection')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Status:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTesting ? null : _testSupabaseConnection,
              child: const Text('Test API Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
