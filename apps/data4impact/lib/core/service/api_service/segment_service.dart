import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SegmentService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  SegmentService({required this.apiClient, required this.secureStorage});

  Future<Map<String, dynamic>> getSegmentById({
    required String segmentId,
    required String projectSlug,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/segments/$segmentId',
        queryParameters: {'projectSlug': projectSlug},
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      print('DioError: ${e.response?.data}');
      rethrow;
    }
  }

  Future<void> joinSegment({
    required String segmentId,
    required String projectSlug,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      await apiClient.post(
        '/segments/$segmentId/join',
        queryParameters: {'projectSlug': projectSlug},
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );
    } on DioException catch (e) {
      print('DioError: ${e.response?.data}');
      rethrow;
    }
  }
}