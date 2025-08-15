import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProjectService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  ProjectService({required this.apiClient, required this.secureStorage});

  Future<List<dynamic>> getAllProjects() async {
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

      // Make sure this matches the API's actual shape
      if (response.data is List) {
        return response.data as List;
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException {
      rethrow;
    }
  }


}
