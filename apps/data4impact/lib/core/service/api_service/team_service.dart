import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TeamService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  TeamService({required this.apiClient, required this.secureStorage});

  Future<dynamic> getTeams() async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null || cookie.isEmpty) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/teams',
        options: Options(headers: {'Cookie': cookie}),
      );

      return response.data;
    } on DioException catch (e) {
      print('Error fetching study details: ${e.message}');
      rethrow;
    }
  }
}
