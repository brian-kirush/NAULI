import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP client for talking to the Nauli Tap API backend from the conductor POS
/// app.
class HttpApiService {
  static const String _baseUrl = 'https://naulitap-api.onrender.com';

  /// Checks the balance of an NFC card via the Nauli Tap API.
  ///
  /// This currently calls the **customer** balance endpoint:
  ///   GET /payment/balance/:nfc_uid
  ///
  /// The backend enforces role-based access, so the JWT used here must
  /// belong to a user with the `customer` role. If the stored token belongs
  /// to another role (e.g. `conductor`), the request will fail with a
  /// 403/401 and this method will surface that as an error.
  static Future<Map<String, dynamic>> checkCardBalance(String cardUid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return <String, dynamic>{
          'success': false,
          'error': 'AUTH_ERROR',
          'message': 'Missing auth token. Please log in again.',
        };
      }

      final uri = Uri.parse('$_baseUrl/payment/balance/$cardUid');
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      Map<String, dynamic> body = <String, dynamic>{};
      try {
        if (response.body.isNotEmpty) {
          body = jsonDecode(response.body) as Map<String, dynamic>;
        }
      } catch (_) {
        // If body is not valid JSON, keep it empty and fall through.
      }

      if (response.statusCode == 200 && body['success'] == true) {
        final double balance =
            (body['current_balance'] as num?)?.toDouble() ?? 0.0;
        return <String, dynamic>{
          'success': true,
          'balance': balance,
          'isRegistered': true,
          'nfc_uid': body['nfc_uid']?.toString() ?? cardUid,
          'lastUpdated': body['last_updated']?.toString(),
        };
      }

      if (response.statusCode == 404) {
        return <String, dynamic>{
          'success': false,
          'error': 'UNREGISTERED_CARD',
          'isRegistered': false,
          'message': body['message']?.toString() ??
              "Card not found or doesn't belong to this user.",
        };
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return <String, dynamic>{
          'success': false,
          'error': 'FORBIDDEN',
          'message': body['message']?.toString() ??
              'Not authorised to view this card balance.',
        };
      }

      return <String, dynamic>{
        'success': false,
        'error': 'NETWORK_ERROR',
        'message': body['message']?.toString() ??
            'Failed to fetch card balance. Please try again.',
      };
    } catch (e) {
      // ignore: avoid_print
      print('💥 checkCardBalance error: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'NETWORK_ERROR',
        'message': 'Failed to fetch card balance. Please try again.',
      };
    }
  }

  /// Logs in a conductor using the shared /user/login endpoint.
  ///
  /// [username] is treated as the conductor's login email.
  /// Returns a map compatible with [ConductorService.login], or null on
  /// failure.
  static Future<Map<String, dynamic>?> loginConductor(
    String username,
    String password,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/user/login');
      final response = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': username,
          'password': password,
        }),
      );

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || body['token'] == null) {
        return null;
      }

      // Enforce that this user is actually a conductor
      if (body['role']?.toString() != 'conductor') {
        return null;
      }

      final token = body['token'] as String;

      // Persist the JWT for subsequent authenticated requests
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      // Fetch profile to get stable ID and name
      final profileResp = await http.get(
        Uri.parse('$_baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic>? profileBody;
      if (profileResp.statusCode == 200) {
        profileBody = jsonDecode(profileResp.body) as Map<String, dynamic>;
      }

      final dynamic rawUser =
          profileBody?['profile'] ?? profileBody?['user'] ?? <String, dynamic>{};
      final Map<String, dynamic> user =
          rawUser is Map<String, dynamic> ? rawUser : <String, dynamic>{};

      final String id = user['_id']?.toString() ?? '';
      final String fullName =
          user['name']?.toString() ?? body['name']?.toString() ?? username;
      final String createdAt =
          user['createdAt']?.toString() ?? DateTime.now().toIso8601String();

      return <String, dynamic>{
        'id': id,
        'username': username,
        'full_name': fullName,
        'vehicle_assigned': null,
        'created_at': createdAt,
      };
    } catch (e) {
      // On any error, treat as failed login
      // (ConductorService.login will handle the false return)
      // ignore: avoid_print
      print('💥 loginConductor error: $e');
      return null;
    }
  }

  /// Full NFC payment flow against the Nauli Tap API.
  ///
  /// Uses the conductor JWT (stored as `auth_token`) to call:
  /// - POST /payment/fare/deduct/initiate
  /// - POST /payment/fare/deduct/confirm
  ///
  /// Returns a map shaped for [TransactionService.processNFCPayment].
  static Future<Map<String, dynamic>> processNFCPayment({
    required String cardUid,
    required double fareAmount,
    required String routeId, // Currently unused by backend but kept for logs
    required String conductorId, // Currently unused by backend but kept for logs
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return <String, dynamic>{
          'success': false,
          'error': 'AUTH_ERROR',
          'message': 'Missing auth token. Please log in again.',
        };
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // STEP 1: Initiate fare deduction
      final initResp = await http.post(
        Uri.parse('$_baseUrl/payment/fare/deduct/initiate'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          'nfc_uid': cardUid,
          'fare_amount': fareAmount,
        }),
      );

      final Map<String, dynamic> initBody =
          jsonDecode(initResp.body) as Map<String, dynamic>;

      if (initResp.statusCode != 202 || initBody['success'] != true) {
        final String msg =
            initBody['message']?.toString() ?? 'Failed to initiate fare deduction.';
        final lowerMsg = msg.toLowerCase();

        if (lowerMsg.contains('card not found') ||
            lowerMsg.contains('nfc card not found') ||
            lowerMsg.contains('inactive')) {
          return <String, dynamic>{
            'success': false,
            'error': 'UNREGISTERED_CARD',
            'message': msg,
          };
        }

        if (lowerMsg.contains('insufficient funds') ||
            lowerMsg.contains('minimum balance')) {
          return <String, dynamic>{
            'success': false,
            'error': 'INSUFFICIENT_FUNDS',
            'message': msg,
            'currentBalance': initBody['current_balance'] ?? 0.0,
          };
        }

        return <String, dynamic>{
          'success': false,
          'error': 'INIT_FAILED',
          'message': msg,
        };
      }

      final String? transactionId = initBody['transaction_id']?.toString();
      if (transactionId == null || transactionId.isEmpty) {
        return <String, dynamic>{
          'success': false,
          'error': 'INIT_FAILED',
          'message': 'Missing transaction id from initiate response.',
        };
      }

      // STEP 2: Confirm deduction
      final confirmResp = await http.post(
        Uri.parse('$_baseUrl/payment/fare/deduct/confirm'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{'transaction_id': transactionId}),
      );

      final Map<String, dynamic> confirmBody =
          jsonDecode(confirmResp.body) as Map<String, dynamic>;

      if (confirmResp.statusCode != 200 || confirmBody['success'] != true) {
        return <String, dynamic>{
          'success': false,
          'error': 'CONFIRM_FAILED',
          'message': confirmBody['message']?.toString() ??
              'Failed to confirm fare deduction.',
        };
      }

      final double newBalance =
          (confirmBody['new_balance'] as num?)?.toDouble() ?? 0.0;
      final double totalDebited =
          (confirmBody['total_debited'] as num?)?.toDouble() ?? fareAmount;
      final double previousBalance = newBalance + totalDebited;

      return <String, dynamic>{
        'success': true,
        'transactionId': transactionId,
        'previousBalance': previousBalance,
        'newBalance': newBalance,
      };
    } catch (e) {
      // ignore: avoid_print
      print('💥 processNFCPayment error: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'NETWORK_ERROR',
        'message': 'Failed to process payment. Please try again.',
      };
    }
  }
}
