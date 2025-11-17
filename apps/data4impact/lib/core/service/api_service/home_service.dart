// lib/core/service/api_service/home_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class HomeService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  HomeService({required this.apiClient, required this.secureStorage});

  Future<List<Map<String, dynamic>>> getMyCollectors({

    required String project,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/collectors/my',
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      if (response.data is List) {
        final list = response.data as List;
        if (list.isEmpty) return [];

        if (list.first is! Map<String, dynamic>) {
          throw Exception('Expected List<Map> but got ${list.first.runtimeType}');
        }

        return list.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      print('DioError in getMyCollectors: ${e.response?.data}');
      rethrow;
    }
  }
}