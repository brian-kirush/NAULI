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

  // New method for quick balance check.
  // NOTE: This uses the Nauli Tap API's customer balance endpoint under the
  // hood via [HttpApiService.checkCardBalance]. The JWT stored on the device
  // must be authorised for that endpoint, otherwise an AUTH/FORBIDDEN error
  // will be returned.
  static Future<Map<String, dynamic>> checkCardBalance(String cardUid) async {
    try {
      print('ℹ️ Checking balance for card $cardUid via HttpApiService...');
      final result = await HttpApiService.checkCardBalance(cardUid);
      return result;
    } catch (e) {
      print('💥 checkCardBalance error in TransactionService: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'PROCESSING_ERROR',
        'message': 'Failed to check card balance. Please try again.',
      };
    }
  }
}
