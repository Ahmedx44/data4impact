import 'dart:convert';
import 'dart:io';

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
          final userFriendlyMessage = _getUserFriendlyErrorMessage(e);

          // Handle redirect errors specifically
          if ([301, 302, 303, 307, 308].contains(e.response?.statusCode)) {
            AppLogger.logWarning(
                'Redirect not followed to: ${e.response?.headers['location']}');
          }

          // Log error responses
          if (e.response != null) {
            AppLogger.logError('''
🚨 ERROR RESPONSE 🚨
User Message: $userFriendlyMessage
Status: ${e.response?.statusCode}
URL: ${e.requestOptions.uri}
Headers: ${e.response?.headers}
Body: ${e.response?.data}
Technical: ${e.message}
''');
          } else {
            AppLogger.logError('''
🚨 NETWORK ERROR 🚨
User Message: $userFriendlyMessage
Technical: ${e.message}
''');
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
      final userMessage = _getUserFriendlyErrorMessage(e);
      AppLogger.logError(
        "GET request failed: $userMessage\nURL: $endpoint",
        e,
        stack,
      );
      // You can throw a custom exception with user-friendly message
      throw Exception(userMessage);
    }
  }

  /// POST request
  Future<Response> post(
      String endpoint, {
        dynamic data,
        Map<String, String>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e, stack) {
      final userMessage = _getUserFriendlyErrorMessage(e);
      AppLogger.logError(
        "POST request failed: $userMessage\nURL: $endpoint",
        e,
        stack,
      );
      throw Exception(userMessage);
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
      final userMessage = _getUserFriendlyErrorMessage(e);
      AppLogger.logError(
        "PUT request failed: $userMessage\nURL: $endpoint",
        e,
        stack,
      );
      throw Exception(userMessage);
    }
  }

  /// DELETE request
  Future<Response> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await dio.delete(endpoint, data: data);
      return response;
    } on DioException catch (e, stack) {
      final userMessage = _getUserFriendlyErrorMessage(e);
      AppLogger.logError(
        "DELETE request failed: $userMessage\nURL: $endpoint",
        e,
        stack,
      );
      throw Exception(userMessage);
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

  /// User-friendly error message helper
  String _getUserFriendlyErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please check your connection and try again.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network and try again.';

      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please try again later.';

      case DioExceptionType.badResponse:
        return _getResponseErrorMessage(error.response);

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No internet connection. Please check your network.';
        }
        return 'Something went wrong. Please try again.';

      default:
        return 'Network error occurred. Please try again.';
    }
  }

  String _getResponseErrorMessage(Response? response) {
    if (response == null) {
      return 'Server error occurred. Please try again.';
    }

    final statusCode = response.statusCode;
    final errorMessage = _extractErrorMessageFromResponse(response);

    switch (statusCode) {
      case 400:
        return errorMessage ?? 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Requested resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 409:
        return errorMessage ?? 'Conflict occurred. Please try again.';
      case 422:
        return errorMessage ?? 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Server is down for maintenance. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again.';
      default:
        return errorMessage ?? 'Something went wrong. Please try again.';
    }
  }

  String? _extractErrorMessageFromResponse(Response response) {
    try {
      final data = response.data;

      if (data is Map) {
        // Try common error message fields
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['error'] != null) {
          return data['error'].toString();
        }
        if (data['detail'] != null) {
          return data['detail'].toString();
        }

        // For validation errors, format them nicely
        if (data['errors'] is Map) {
          final errors = Map<String, dynamic>.from(data['errors'] as Map<String,dynamic>);
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List) {
              return firstError.first?.toString();
            }
            return firstError.toString();
          }
        }
      }

      if (data is String && data.isNotEmpty) {
        return data;
      }
    } catch (e) {
      // If parsing fails, return null to use default message
    }

    return null;
  }
}