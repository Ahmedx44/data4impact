// core/service/api_service/study_service.dart
import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudyService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  StudyService({required this.apiClient, required this.secureStorage});

  Future<List<Map<String, dynamic>>> getStudies(String projectSlug) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/studies',
        queryParameters: {'projectSlug': projectSlug},
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      if (response.data is List) {
        final list = response.data as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected response format - Expected List but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('DioError: ${e.response?.data}');
      rethrow;
    }
  }

  // Other methods remain the same but will now work with the switched project
  Future<Map<String, dynamic>> getStudyDetails(String studyId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.get(
        '/studies/$studyId',
        options: Options(headers: {'Cookie': cookie}),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      print('Error fetching study details: ${e.message}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStudyQuestions(String studyId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.get(
        '/studies/$studyId/collect',
        options: Options(headers: {'Cookie': cookie}),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      print('Error fetching study details: ${e.message}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitSurveyResponse({
    required String studyId,
    required Map<String, dynamic> responseData,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.post(
        '/responses?studyId=$studyId',
        data: responseData,
        options: Options(
          headers: {
            'Cookie': cookie,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      print('Error submitting survey response: ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response!.statusCode}');
        print('Response data: ${e.response!.data}');
      }
      rethrow;
    }
  }
}