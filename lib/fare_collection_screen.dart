import 'package:flutter/material.dart';
import 'services/nfc_service.dart';
import 'services/transaction_service.dart';
import 'services/api_service.dart'; // Keep this for balance checking

class FareCollectionScreen extends StatefulWidget {
  final String route;
  final int fare;
  final int passengerCapacity;
  final String conductorId;

  const FareCollectionScreen({
    super.key,
    required this.route,
    required this.fare,
    required this.passengerCapacity,
    required this.conductorId,
  });

  @override
  State<FareCollectionScreen> createState() => _FareCollectionScreenState();
}

class _FareCollectionScreenState extends State<FareCollectionScreen> {
  int _collectedAmount = 0;
  int _passengersPaid = 0;
  final List<Payment> _recentCollections = [];
  bool _isScanning = false;
  bool _isProcessingPayment = false; // ADD THIS LINE
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkNFCAvailability();
    print('🚀 FareCollectionScreen initialized');
    print('📍 Route: ${widget.route}');
    print('💰 Fare: Ksh ${widget.fare}');
    print('👥 Capacity: ${widget.passengerCapacity}');
    print('🎫 Conductor ID: ${widget.conductorId}');
  }

  @override
  void dispose() {
    // Stop NFC without setState since we're disposing
    NFCService.stopNFCScan();
    print('🛑 FareCollectionScreen disposed');
    super.dispose();
  }

  void _checkNFCAvailability() async {
    print('🔍 Checking NFC availability...');
    final isAvailable = await NFCService.isAvailable;
    print('📱 NFC Available: $isAvailable');
    if (!isAvailable) {
      _showNFCDialog('NFC Not Available',
          'NFC is not available on this device. Please use an NFC-enabled device.');
    }
  }

  void _startNFCSession() {
    if (_isScanning) {
      print('🔄 NFC: Already scanning, ignoring duplicate start');
      return;
    }

    setState(() {
      _isScanning = true;
    });

    print('🎬 Starting NFC scan session...');

    NFCService.startNFCScan(
      onCardDiscovered: (String cardUid) {
        print('✅ NFC Card Discovered: $cardUid');
        _processNFCPayment(cardUid);
      },
      onError: (String error) {
        print('❌ NFC Error: $error');
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
        // Only show error for non-timeout issues
        if (!error.toLowerCase().contains('timeout')) {
          _showErrorDialog('NFC Error', error);
        } else {
          // Restart scanning on timeout
          _startNFCSession();
        }
      },
    );
  }

  void _stopNFC() {
    print('🛑 Stopping NFC scan...');
    NFCService.stopNFCScan();
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _processNFCPayment(String cardUid) async {
    // Check if already processing - use a separate flag
    if (_isProcessingPayment) {
      print('🔄 Payment: Already processing a payment, ignoring new request');
      return;
    }

    // Set processing flag to prevent duplicates
    _isProcessingPayment = true;

    // Stop NFC scanning during payment processing
    _stopNFC();

    print('💳 Processing NFC payment for card: $cardUid');
    print('💰 Fare Amount: Ksh ${widget.fare}');
    print('🛣️ Route: ${widget.route}');

    try {
      final result = await TransactionService.processNFCPayment(
        cardUid: cardUid,
        fareAmount: widget.fare.toDouble(),
        routeId: widget.route,
      );

      print('📊 Payment Result: ${result['success']}');
      if (result['success'] == true) {
        _handleSuccessfulPayment(result, cardUid);
      } else {
        print('❌ Payment Failed: ${result['error']}');
        _handleFailedPayment(result, cardUid);
      }
    } catch (e) {
      print('💥 Payment Error: $e');
      _handlePaymentError(e.toString());
    } finally {
      // Reset processing flag
      _isProcessingPayment = false;

      // Restart NFC scanning after processing
      if (mounted) {
        _startNFCSession();
      }
    }
  }

  void _handleSuccessfulPayment(Map<String, dynamic> result, String cardUid) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final cardLastFour =
        cardUid.length >= 4 ? cardUid.substring(cardUid.length - 4) : cardUid;

    print('🎉 Payment Successful!');
    print('💳 Card: •••• $cardLastFour');
    print('💰 Amount: Ksh ${widget.fare}');
    print('📈 Previous Balance: Ksh ${result['previousBalance']}');
    print('📉 New Balance: Ksh ${result['newBalance']}');

    if (mounted) {
      setState(() {
        _collectedAmount += widget.fare;
        _passengersPaid++;
        _recentCollections.insert(
          0,
          Payment(
            amount: widget.fare,
            cardLastFour: cardLastFour,
            time: time,
            status: _isOffline ? 'Pending Sync' : 'Completed',
            cardUid: cardUid,
            previousBalance: result['previousBalance'],
            newBalance: result['newBalance'],
            isRegistered: true,
            transactionId: result['transactionId'],
          ),
        );
      });
    }

    _showSuccessDialog(
      'Payment Successful! ✅',
      'Payment of Ksh ${widget.fare} processed successfully.\n\n'
          'Card: •••• $cardLastFour\n'
          'Previous Balance: Ksh ${result['previousBalance']?.toStringAsFixed(2)}\n'
          'New Balance: Ksh ${result['newBalance']?.toStringAsFixed(2)}\n'
          'Transaction ID: ${result['transactionId']}',
      cardUid: cardUid,
      newBalance: result['newBalance'],
    );
  }

  void _handleFailedPayment(Map<String, dynamic> result, String cardUid) {
    final errorType = result['error'];
    final message = result['message'];

    print('❌ Payment Failed - Error Type: $errorType');
    print('📝 Error Message: $message');

    switch (errorType) {
      case 'UNREGISTERED_CARD':
        _showUnregisteredCardDialog(cardUid);
        break;
      case 'INSUFFICIENT_FUNDS':
        final currentBalance = result['currentBalance'] ?? 0.0;
        _showInsufficientFundsDialog(currentBalance, message);
        break;
      default:
        _showErrorDialog('Payment Failed', message);
    }
  }

  void _handlePaymentError(String error) {
    print('💥 Payment Processing Error: $error');
    if (error.toLowerCase().contains('timeout')) {
      // Don't show error for timeouts, just restart scanning
      print('⏱️ Payment timeout - restarting scan');
      if (mounted) {
        _startNFCSession();
      }
    } else {
      _showErrorDialog('Payment Error', error);
      if (mounted) {
        _startNFCSession();
      }
    }
  }

  void _showInsufficientFundsDialog(double currentBalance, String message) {
    print('💰 Showing insufficient funds dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Insufficient Funds',
                  style: TextStyle(color: Colors.orange)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Balance: Ksh ${currentBalance.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              const Text('Minimum Required: Ksh 10.00'),
              const SizedBox(height: 12),
              const Text(
                'Please top up your card to continue using it for transit.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showNFCDialog(String title, String message) {
    print('📱 Showing NFC Dialog: $title');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showUnregisteredCardDialog(String cardUid) {
    print('💳 Showing unregistered card dialog for: $cardUid');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Unregistered Card', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Card UID: $cardUid'),
              const SizedBox(height: 12),
              const Text(
                'This NFC card is not registered in the transit system.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'To use this card for travel:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildInstructionStep(
                  '1. Visit any transit office or authorized agent'),
              _buildInstructionStep('2. Present your ID for registration'),
              _buildInstructionStep('3. Load minimum Ksh 50.00 to activate'),
              _buildInstructionStep('4. Start using for fare payments'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message,
      {String? cardUid, double? newBalance}) {
    print('✅ Showing success dialog: $title');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: cardUid != null
            ? SnackBarAction(
                label: 'View Balance',
                textColor: Colors.white,
                onPressed: () => _showCardBalance(cardUid),
              )
            : null,
      ),
    );
  }

  void _showCardBalance(String cardUid) {
    print('💰 Showing card balance for: $cardUid');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Card Balance'),
          content: FutureBuilder<Map<String, dynamic>>(
            future: ApiService.checkCardBalance(cardUid),
            builder: (context, snapshot) {
              print('🔍 Checking card balance...');
              print('📊 Snapshot state: ${snapshot.connectionState}');
              print('❌ Snapshot error: ${snapshot.error}');
              print('📦 Snapshot data: ${snapshot.data}');

              if (snapshot.connectionState == ConnectionState.waiting) {
                print('⏳ Loading balance...');
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Checking balance...'),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                print('💥 Balance check error: ${snapshot.error}');
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 40),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                  ],
                );
              }

              if (!snapshot.hasData || !snapshot.data!['isRegistered']) {
                print('❌ Card not registered or no data');
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.credit_card_off, color: Colors.orange, size: 40),
                    SizedBox(height: 16),
                    Text('Card not registered'),
                  ],
                );
              }

              final balance = snapshot.data!['balance'] ?? 0.0;
              final cardHolder = snapshot.data!['cardHolder'] ?? 'Unknown';

              print('✅ Balance loaded: Ksh $balance');
              print('👤 Card Holder: $cardHolder');

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card: •••• ${cardUid.substring(cardUid.length - 4)}'),
                  const SizedBox(height: 8),
                  Text('Holder: $cardHolder'),
                  const SizedBox(height: 8),
                  const Text('Status: ✅ Registered',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Balance:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ksh ${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    print('❌ Showing error dialog: $title - $message');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.red)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building FareCollectionScreen UI');
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            print('🔙 Back button pressed');
            _showExitConfirmation(context);
          },
        ),
        title: const Text(
          'Fare Collection',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('🛑 End Trip button pressed');
              _showTripSummary(context);
            },
            child: Text(
              'End Trip',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTripInfoCard(),
            const SizedBox(height: 24),
            _buildTapCardSection(),
            const SizedBox(height: 24),
            _buildRecentCollections(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfoCard() {
    print('📊 Building trip info card');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: _isOffline ? Border.all(color: Colors.orange, width: 2) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Trip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_isOffline)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.signal_wifi_off,
                          size: 14, color: Colors.orange[800]),
                      const SizedBox(width: 4),
                      const Text(
                        'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTripStat('Route', widget.route),
              _buildTripStat('Fare', 'Ksh ${widget.fare}'),
              _buildTripStat('Capacity', '${widget.passengerCapacity}'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTripStat('Collected', 'Ksh $_collectedAmount'),
              _buildTripStat(
                  'Passengers', '$_passengersPaid/${widget.passengerCapacity}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTapCardSection() {
    print('💳 Building tap card section - Scanning: $_isScanning');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isScanning ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: _isScanning ? Border.all(color: Colors.blue, width: 2) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card,
            size: 64,
            color: _isScanning ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _isScanning ? 'Reading Card...' : 'Tap NFC Card to Pay',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fare: Ksh ${widget.fare}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isScanning ? null : _startNFCSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScanning ? Colors.grey : Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isScanning
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Reading Card...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'TAP CARD TO PAY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hold the NFC card near the back of your device',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCollections() {
    print(
        '📋 Building recent collections - Count: ${_recentCollections.length}');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Payments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (_recentCollections.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No payments yet. Tap an NFC card to process payment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            )
          else
            Column(
              children: _recentCollections
                  .map((payment) => _buildCollectionItem(payment))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCollectionItem(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: payment.status == 'Pending Sync'
            ? Colors.orange[50]
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: payment.status == 'Pending Sync'
            ? Border.all(color: Colors.orange)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: payment.status == 'Pending Sync'
                  ? Colors.orange[100]
                  : const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              payment.status == 'Pending Sync'
                  ? Icons.sync
                  : Icons.check_circle,
              color: payment.status == 'Pending Sync'
                  ? Colors.orange
                  : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card •••• ${payment.cardLastFour}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${payment.time} ${payment.status == 'Pending Sync' ? '• ${payment.status}' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (payment.previousBalance != null &&
                    payment.newBalance != null)
                  Text(
                    'Balance: Ksh ${payment.previousBalance!.toStringAsFixed(2)} → Ksh ${payment.newBalance!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Ksh ${payment.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: payment.status == 'Pending Sync'
                      ? Colors.orange
                      : Colors.green,
                  fontSize: 16,
                ),
              ),
              if (payment.newBalance != null)
                Text(
                  'Ksh ${payment.newBalance!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getBalanceColor(payment.newBalance!),
                    fontWeight: payment.newBalance! < 10.0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBalanceColor(double balance) {
    if (balance == 0.0) {
      return Colors.grey;
    } else if (balance < 10.0) {
      return Colors.red;
    } else if (balance < 100.0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  void _showExitConfirmation(BuildContext context) {
    print('🚪 Showing exit confirmation dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Trip?'),
          content: const Text(
              'Are you sure you want to end this trip? All unsaved data will be lost.'),
          actions: [
            TextButton(
              onPressed: () {
                print('❌ Exit cancelled');
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('✅ Exit confirmed');
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'End Trip',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTripSummary(BuildContext context) {
    final platformFee = _passengersPaid * 2;
    final netAmount = _collectedAmount - platformFee;

    print('📊 Showing trip summary');
    print('💰 Total Collected: Ksh $_collectedAmount');
    print('👥 Passengers Paid: $_passengersPaid');
    print('💸 Platform Fee: Ksh $platformFee');
    print('📈 Net Amount: Ksh $netAmount');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSummaryRow('Route', widget.route),
                _buildSummaryRow('Fare per Passenger', 'Ksh ${widget.fare}'),
                _buildSummaryRow('Passengers Paid',
                    '$_passengersPaid/${widget.passengerCapacity}'),
                _buildSummaryRow('Total Collected', 'Ksh $_collectedAmount'),
                _buildSummaryRow(
                    'Platform Fee (Ksh 2/pax)', 'Ksh $platformFee'),
                const Divider(),
                _buildSummaryRow('Net Amount', 'Ksh $netAmount', isTotal: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      print('🏁 Trip ended successfully');
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm & End Trip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black87 : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.green : Colors.black87,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class Payment {
  final int amount;
  final String cardLastFour;
  final String time;
  final String status;
  final String? cardUid;
  final double? previousBalance;
  final double? newBalance;
  final bool? isRegistered;
  final String? transactionId;

  Payment({
    required this.amount,
    required this.cardLastFour,
    required this.time,
    this.status = 'Completed',
    this.cardUid,
    this.previousBalance,
    this.newBalance,
    this.isRegistered,
    this.transactionId,
  });
}
