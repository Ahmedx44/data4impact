import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ProjectService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  ProjectService({required this.apiClient, required this.secureStorage});

  Future<List<Map<String, dynamic>>> getAllProjects() async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/projects',
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      print('Raw API response: ${response.data}'); // Debug log

      if (response.data is List) {
        final list = response.data as List;
        if (list.isEmpty) return [];

        // Verify first item is a Map
        if (list.first is! Map<String, dynamic>) {
          throw Exception('Expected List<Map> but got ${list.first.runtimeType}');
        }

        return list.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      print('DioError: ${e.response?.data}');
      rethrow;
    }
  }
}
