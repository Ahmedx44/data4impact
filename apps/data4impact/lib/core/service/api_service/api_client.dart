import 'dart:convert';

import 'package:data4impact/core/service/app_logger.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({String? baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? "",
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            validateStatus: (status) => status! < 500,
            followRedirects: true,
            maxRedirects: 5,
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.logInfo('''
🌐 REQUEST 🌐
Method: ${options.method}
URL: ${options.uri}
Headers: ${options.headers}
Body: ${options.data}
''');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final prettyBody = const JsonEncoder.withIndent('  ')
              .convert(response.data);
          // Check for redirect
          if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
            AppLogger.logWarning(
                'Redirect detected to: ${response.headers['location']}');
          }

          // Log the full response
          AppLogger.logInfo('''
📩 RESPONSE 📩
Status: ${response.statusCode} ${response.statusMessage}
URL: ${response.requestOptions.uri}
Headers: ${response.headers}
Body: $prettyBody
''');

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Handle redirect errors specifically
          if ([301, 302, 303, 307, 308].contains(e.response?.statusCode)) {
            AppLogger.logWarning(
                'Redirect not followed to: ${e.response?.headers['location']}');
          }

          // Log error responses
          if (e.response != null) {
            AppLogger.logError('''
🚨 ERROR RESPONSE 🚨
Status: ${e.response?.statusCode}
URL: ${e.requestOptions.uri}
Headers: ${e.response?.headers}
Body: ${e.response?.data}
Error: ${e.message}
''');
          } else {
            AppLogger.logError('🚨 NETWORK ERROR 🚨\nError: ${e.message}');
          }

          return handler.next(e);
        },
      ),
    );
  }

  /// GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e, stack) {
      AppLogger.logError(
        "GET request failed: ${e.message}\nURL: $endpoint",
        e,
        stack,
      );
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, String>? queryParameters,
    Options? options, // <- accept options
  }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options, // <- pass it here!
      );
      return response;
    } on DioException catch (e, stack) {
      AppLogger.logError(
        "POST request failed: ${e.message}\nURL: $endpoint",
        e,
        stack,
      );
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
      String endpoint, {
        dynamic data,
        Options? options,
      }) async {
    try {
      final response = await dio.put(
        endpoint,
        data: data,
        options: options,
      );
      return response;
    } on DioException catch (e, stack) {
      AppLogger.logError(
        "PUT request failed: ${e.message}\nURL: $endpoint",
        e,
        stack,
      );
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await dio.delete(endpoint, data: data);
      return response;
    } on DioException catch (e, stack) {
      AppLogger.logError(
        "DELETE request failed: ${e.message}\nURL: $endpoint",
        e,
        stack,
      );
      rethrow;
    }
  }

  /// Add auth token
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    AppLogger.logInfo("🔑 Auth token set");
  }

  /// Clear auth token
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
    AppLogger.logInfo("🔑 Auth token cleared");
  }
}
