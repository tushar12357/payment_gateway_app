import 'package:dio/dio.dart';
import 'package:frontend/core/config/env.dart';
import 'package:frontend/core/storage/secure_storage.dart';

class ApiClient {
  static Dio? _dioInstance;
  static final SecureStorage _secureStorage = SecureStorage();

  static Dio get dio {
    _dioInstance ??= _initDio();
    return _dioInstance!;
  }

  static Dio _initDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException err, handler) async {
          String errorMessage = 'Something went wrong';

          if (err.response != null) {
            final status = err.response?.statusCode;
            final data = err.response?.data;

            if (data is Map<String, dynamic> && data.containsKey('message')) {
              errorMessage = data['message'] as String;
            } else if (status == 401) {
              errorMessage = 'Session expired. Please login again.';
            } else if (status == 400 || status == 422) {
              errorMessage = data?['error'] ?? data?['message'] ?? 'Invalid request';
            } else if (status == 403) {
              errorMessage = 'You do not have permission to perform this action.';
            } else if (status == 429) {
              errorMessage = 'Too many requests. Please try again later.';
            } else {
              errorMessage = 'Server error (${status ?? 'unknown'})';
            }
          } else {
            switch (err.type) {
              case DioExceptionType.connectionTimeout:
              case DioExceptionType.sendTimeout:
              case DioExceptionType.receiveTimeout:
                errorMessage = 'Connection timeout. Please check your internet.';
                break;
              case DioExceptionType.cancel:
                errorMessage = 'Request cancelled.';
                break;
              default:
                errorMessage = err.message ?? 'Network error';
            }
          }

          return handler.next(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: errorMessage,
            ),
          );
        },
      ),
    );

    return dio;
  }

  static Future<void> clearInstance() async {
    await _secureStorage.deleteAuthToken();
    _dioInstance = null;
  }
}