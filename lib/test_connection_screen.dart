import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
      _status = 'Testing Supabase connection...';
    });

    try {
      final result = await ApiService.testSupabaseConnection();

      setState(() {
        if (result['success'] == true) {
          _status = '✅ Supabase connection successful!\n\n'
              'Connection Details:\n'
              '- Conductors: ${result['details']['conductors']}\n'
              '- NFC Card: ${result['details']['nfc_card']}\n'
              '- Transactions: ${result['details']['transactions']}';
        } else {
          _status = '❌ Supabase connection failed\n\n'
              'Error: ${result['error']}\n\n'
              'Connection Details:\n'
              '- Conductors: ${result['details']['conductors']}\n'
              '- NFC Card: ${result['details']['nfc_card']}\n'
              '- Transactions: ${result['details']['transactions']}';
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
              child: const Text('Test Supabase Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
