import 'package:dio/dio.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/core/storage/secure_storage.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;
  Future<void> sendOtp(String phone) async {
    try {
      await _dio.post(
        '/auth/send-otp',
        data: {
          'phone': phone, 
        },
      );
    } on DioException catch (e) {
      throw e.error?.toString() ?? 'Failed to send OTP. Please try again.';
    } catch (e) {
      throw 'Unexpected error while sending OTP';
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {
          'phone': "9821985448",
          'otp': otp,
        },
      );

      final data = response.data as Map<String, dynamic>;

      final token = data['token']?.toString();
      if (token == null || token.isEmpty) {
        throw 'No authentication token received';
      }

      await SecureStorage().setAuthToken(token);
      return true;
    } on DioException catch (e) {
      throw e.error?.toString() ?? 'OTP verification failed. Please check the code.';
    } catch (e) {
      throw 'Unexpected error during OTP verification';
    }
  }
}