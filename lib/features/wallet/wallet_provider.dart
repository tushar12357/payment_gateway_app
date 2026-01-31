import 'package:flutter/material.dart';
import 'package:frontend/features/wallet/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _service = WalletService();

  double _balance = 0.0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  double get balance => _balance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> fetchBalance({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();
    }

    try {
      _balance = await _service.getBalance();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ── Add Money ──────────────────────────────────────────────────────────

  Future<void> addMoney({
    required double amount,
    required String name,
    required String email,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final order = await _service.createTopupOrder(amount);
      _service.openCheckout(
        orderData: order,
        name: name,
        email: email,
        phone: phone,
      );
      // Balance will be updated via webhook → you can poll or wait for manual refresh
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Transfer Money ─────────────────────────────────────────────────────

  Future<void> transferMoney({
    required String toPhone,
    required double amount,
    required String note,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.transferToPhone(
        toPhone: toPhone,
        amount: amount,
        note: note,
      );
      _successMessage = 'Transfer request sent successfully';
      // Optimistic update (subtract amount)
      _balance -= amount;
      // Or better: refresh real balance
      await fetchBalance(showLoading: false);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}