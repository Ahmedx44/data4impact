import 'package:data4impact/core/service/app_logger.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  final LogType _logType = LogType.network; // Specific log type for API calls

  ApiClient({String? baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? "https://example.com/api",
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    // Initialize logger if not already initialized
    if (AppLogger.log == null) {
      AppLogger.initialize();
    }

    // Add interceptors with AppLogger
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await AppLogger.logInfo(
            "➡️ Request: ${options.method} ${options.uri}",
          );
          if (options.data != null) {
            await AppLogger.logInfo(
              "Request Body: ${options.data}",
            );
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          await AppLogger.logInfo(
            "✅ Response: ${response.statusCode} ${response.requestOptions.uri}",
          );
          await AppLogger.logInfo(
            "Response Data: ${response.data}",
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          await AppLogger.reportError(
            e,
            e.stackTrace,
            "❌ API Error: ${e.message}\nURL: ${e.requestOptions.uri}\nError Type: ${e.type}",
            _logType,
          );
          return handler.next(e);
        },
      ),
    );
  }

  /// GET request
  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await dio.get(endpoint, queryParameters: queryParams);
      return response;
    } on DioException catch (e, stack) {
      await AppLogger.reportError(
        e,
        stack,
        "GET request failed: ${e.message}\nURL: $endpoint",
        _logType,
      );
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e, stack) {
      await AppLogger.reportError(
        e,
        stack,
        "POST request failed: ${e.message}\nURL: $endpoint",
        _logType,
      );
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await dio.put(endpoint, data: data);
      return response;
    } on DioException catch (e, stack) {
      await AppLogger.reportError(
        e,
        stack,
        "PUT request failed: ${e.message}\nURL: $endpoint",
        _logType,
      );
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await dio.delete(endpoint, data: data);
      return response;
    } on DioException catch (e, stack) {
      await AppLogger.reportError(
        e,
        stack,
        "DELETE request failed: ${e.message}\nURL: $endpoint",
      );
      rethrow;
    }
  }

  /// Add auth token dynamicall
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    AppLogger.logInfo("Auth token set");
  }

  /// Clear auth token
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
    AppLogger.logInfo("Auth token cleared");
  }
}
