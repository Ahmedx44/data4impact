import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CollectorService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  CollectorService({required this.apiClient, required this.secureStorage});

  /// Fetch list of collectors
  Future<List<dynamic>> getCollectors({
    String? segment,
    String? projectSlug,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null || cookie.isEmpty) {
        throw Exception('No authentication cookie found');
      }

      final trimmedCookie = cookie.trim();

      final response = await apiClient.get(
        '/collectors',
        queryParameters: {
          if (segment != null) 'segment': segment,
          if (projectSlug != null) 'projectSlug': projectSlug,
        },
        options: Options(
          headers: {'Cookie': trimmedCookie},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch collectors');
      }

      if (response.data is List) {
        return response.data as List;
      }

      throw Exception(
          'Unexpected response format - Expected List but got ${response.data.runtimeType}');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Join as a collector
  Future<void> joinAsCollector({
    required String collectorId,
    required Map<String, dynamic> attributes,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null || cookie.isEmpty) {
        throw Exception('No session cookie found');
      }

      final trimmedCookie = cookie.trim();

      final response = await apiClient.post(
        '/collectors/$collectorId',
        data: {'attributes': attributes},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Cookie': trimmedCookie,
          },
        ),
      );

      if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update collector information');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      // NOTE: Do NOT delete cookie
      throw Exception('Session expired. Please login again.');
    }

    final errorMessage = e.response?.data?['message'] ?? 'Request failed';
    throw Exception(errorMessage);
  }
}
