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

  Future<List<dynamic>> getTeamMembers(String teamId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null || cookie.isEmpty) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/teams/$teamId/members',
        options: Options(headers: {'Cookie': cookie}),
      );

      // Ensure we return a List<dynamic>
      if (response.data is List) {
        return response.data as List<dynamic>;
      } else {
        // If the response is not a list, wrap it in a list or return empty list
        return [response.data];
        // Or throw an exception:
        // throw Exception('Expected list but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('Error fetching team members: ${e.message}');
      rethrow;
    }
  }
}
