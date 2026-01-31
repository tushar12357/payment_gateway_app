import 'package:flutter/material.dart';
import 'package:frontend/features/auth/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneNumber;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get phoneNumber => _phoneNumber;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    _phoneNumber = phone;
    notifyListeners();

    try {
      await _authService.sendOtp(phone);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      _errorMessage = 'Phone number is missing';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.verifyOtp(_phoneNumber!, otp);
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _phoneNumber = null;
    notifyListeners();
  }
}