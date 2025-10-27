import 'http_api_service.dart';
import 'conductor_service.dart';

class TransactionService {
  static Future<Map<String, dynamic>> processNFCPayment({
    required String cardUid,
    required double fareAmount,
    required String routeId,
  }) async {
    try {
      final conductor = ConductorService.currentConductor;
      if (conductor == null) {
        return {
          'success': false,
          'error': 'AUTH_ERROR',
          'message': 'Conductor not logged in. Please login again.',
        };
      }

      print('💳 Starting payment process...');
      print('   Card UID: $cardUid');
      print('   Fare Amount: $fareAmount');
      print('   Route ID: $routeId');
      print('   Conductor: ${conductor.id}');

      // Validate inputs
      if (cardUid.isEmpty) {
        return {
          'success': false,
          'error': 'INVALID_CARD',
          'message': 'Invalid card UID',
        };
      }

      if (fareAmount <= 0) {
        return {
          'success': false,
          'error': 'INVALID_FARE',
          'message': 'Fare amount must be greater than 0',
        };
      }

      // Use the complete payment flow from HttpApiService
      final paymentResult = await HttpApiService.processNFCPayment(
        cardUid: cardUid,
        fareAmount: fareAmount,
        routeId: routeId,
        conductorId: conductor.id,
      );

      print('📊 Payment result: ${paymentResult['success']}');

      return paymentResult;
    } catch (e) {
      print('💥 Payment processing error: $e');
      return {
        'success': false,
        'error': 'PROCESSING_ERROR',
        'message': 'System error: ${e.toString()}',
      };
    }
  }

  // New method for quick balance check
  static Future<Map<String, dynamic>> checkCardBalance(String cardUid) async {
    try {
      return await HttpApiService.checkCardBalance(cardUid);
    } catch (e) {
      print('💥 Balance check error: $e');
      return {
        'success': false,
        'balance': 0.0,
        'isRegistered': false,
        'error': 'Failed to check balance: ${e.toString()}',
      };
    }
  }
}
