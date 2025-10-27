import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NFCService {
  static Future<bool> get isAvailable async {
    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      return availability == NFCAvailability.available;
    } catch (e) {
      print('❌ NFC Availability check failed: $e');
      return false;
    }
  }

  static bool _isScanning = false;
  static String? _lastProcessedUid;
  static DateTime? _lastProcessedTime;

  static Future<void> startNFCScan({
    required Function(String cardUid) onCardDiscovered,
    required Function(String error) onError,
  }) async {
    if (_isScanning) {
      print('🔄 NFC: Already scanning, ignoring duplicate start');
      return;
    }

    _isScanning = true;
    _lastProcessedUid = null;
    _lastProcessedTime = null;

    print('🎬 Starting NFC scan session...');

    while (_isScanning) {
      try {
        final tag = await FlutterNfcKit.poll(
          timeout: const Duration(seconds: 30), // Increased timeout
        );

        if (tag.id.isNotEmpty) {
          final cardUid = tag.id.toUpperCase(); // Normalize UID format
          final now = DateTime.now();

          // Prevent duplicate reads of same card within 2 seconds
          if (_lastProcessedUid == cardUid &&
              _lastProcessedTime != null &&
              now.difference(_lastProcessedTime!).inSeconds < 2) {
            print('🔄 Ignoring duplicate card read: $cardUid');
            continue;
          }

          _lastProcessedUid = cardUid;
          _lastProcessedTime = now;

          print('✅ NFC Card Discovered: $cardUid');
          onCardDiscovered(cardUid);

          // Brief pause to prevent rapid re-reads
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      } catch (e) {
        // Don't treat timeout as error - it's expected behavior
        if (e.toString().contains('timeout') || e.toString().contains('408')) {
          print('⏱️ NFC Polling timeout - continuing scan...');
          continue; // Continue scanning on timeout
        } else if (_isScanning) {
          print('❌ NFC Error: $e');
          onError('NFC Error: ${e.toString()}');
          break; // Only break on actual errors
        }
      }
    }
  }

  static Future<void> stopNFCScan() async {
    if (!_isScanning) {
      return;
    }

    _isScanning = false;
    _lastProcessedUid = null;
    _lastProcessedTime = null;

    try {
      await FlutterNfcKit.finish();
      print('🛑 NFC: Scan session stopped');
    } catch (e) {
      print('⚠️ NFC: Error stopping session: $e');
    }
  }

  static bool get isScanning => _isScanning;

  // New method to read tag without continuous scanning
  static Future<String?> readSingleTag(
      {Duration timeout = const Duration(seconds: 30)}) async {
    try {
      final tag = await FlutterNfcKit.poll(timeout: timeout);
      return tag.id.isNotEmpty ? tag.id.toUpperCase() : null;
    } catch (e) {
      if (e.toString().contains('timeout') || e.toString().contains('408')) {
        return null; // Timeout is expected
      }
      rethrow;
    } finally {
      await FlutterNfcKit.finish();
    }
  }
}
