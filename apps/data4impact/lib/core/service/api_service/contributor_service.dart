import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ContributorService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  ContributorService({required this.apiClient, required this.secureStorage});

  Future<List<dynamic>> getContributors() async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null || cookie.isEmpty) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/contributors',
        options: Options(headers: {'Cookie': cookie}),
      );

      if (response.data is List) {
        return response.data as List<dynamic>;
      } else {
        return [response.data];
      }
    } on DioException catch (e) {
      print('Error fetching contributors: ${e.message}');
      rethrow;
    }
  }
}
