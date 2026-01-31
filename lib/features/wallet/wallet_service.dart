import 'package:dio/dio.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class WalletService {
  final Dio _dio = ApiClient.dio;
  final Razorpay _razorpay = Razorpay();

  WalletService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // ── Get Wallet Balance ────────────────────────────────────────────────
  Future<double> getBalance() async {
    try {
      final response = await _dio.get('/wallet/balance');
      final data = response.data as Map<String, dynamic>?;
      
      final balanceValue = data?['balance'];
      if (balanceValue is num) {
        return balanceValue.toDouble();
      } else if (balanceValue is String) {
        return double.tryParse(balanceValue) ?? 0.0;
      }
      
      return 0.0;
    } on DioException catch (e) {
      throw e.error?.toString() ?? 'Failed to fetch wallet balance';
    } catch (e) {
      throw 'Unexpected error fetching balance: $e';
    }
  }

  // ── Add Money (Top-up) ────────────────────────────────────────────────

  /// Calls backend to create Razorpay order for top-up
  Future<Map<String, dynamic>> createTopupOrder(double amount) async {
    try {
      final response = await _dio.post(
        '/wallet/topup',
        data: {
          'amount': amount,
          'receipt': 'topup_${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error?.toString() ?? 'Failed to create top-up order';
    }
  }

  /// Opens Razorpay checkout
  void openCheckout({
    required Map<String, dynamic> orderData,
    required String name,
    required String email,
    required String phone,
  }) {
    final options = {
      'key': 'rzp_test_Rz9SJSBrW4Tn1b', // ← replace with real key from env
      'amount': orderData['amount'],
      'name': 'Your App',
      'description': 'Add Money to Wallet',
      'order_id': orderData['orderId'],
      'prefill': {
        'name': name,
        'contact': phone,
        'email': email,
      },
      'external': {'wallets': []},
      'theme': {'color': '#528FF0'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error launching Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success → paymentId: ${response.paymentId}');
    // Backend should handle via webhook
    // You can trigger balance refresh here if you want
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Failed: ${response.code} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
  }

  void dispose() {
    _razorpay.clear();
  }

  // ── Transfer Money ─────────────────────────────────────────────────────

  Future<void> transferToPhone({
    required String toPhone,
    required double amount,
    required String note,
  }) async {
    try {
      await _dio.post(
        '/wallet/transfer',
        data: {
          'toPhone': toPhone,
          'amount': amount,
          'note': note.isEmpty ? 'Transfer' : note,
        },
      );
      print('Transfer request sent successfully');
    } on DioException catch (e) {
      throw e.error?.toString() ?? 'Transfer failed';
    }
  }
}