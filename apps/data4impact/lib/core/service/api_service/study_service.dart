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

  // Get study respondents
  Future<List<Map<String, dynamic>>> getStudyRespondents(String studyId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.get(
        '/studies/$studyId/respondents',
        options: Options(headers: {'Cookie': cookie}),
      );

      if (response.data is List) {
        final list = response.data as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected response format - Expected List but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('Error fetching respondents: ${e.message}');
      rethrow;
    }
  }

  // Create study respondent
  Future<Map<String, dynamic>> createStudyRespondent({
    required String studyId,
    required Map<String, dynamic> respondentData,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.post(
        '/studies/$studyId/respondents',
        data: respondentData,
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
      rethrow;
    }
  }

  Future<List<dynamic>> submitSurveyResponse({
    required String studyId,
    required List responseData,
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

      if (response.data is List) {
        return response.data as List;
      }

      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('data') && responseMap['data'] is List) {
          return responseMap['data'] as List;
        }
        if (responseMap.containsKey('_id')) {
          return [responseMap];
        }
      }

      throw Exception('Unexpected response format: ${response.data.runtimeType}');
    } on DioException catch (e) {
      if (e.response != null) {
      }
      rethrow;
    } catch (e) {

      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStudyCohorts(String studyId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.get(
        '/studies/$studyId/cohorts',
        options: Options(headers: {'Cookie': cookie}),
      );

      if (response.data is List) {
        final list = response.data as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected response format - Expected List but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('Error fetching cohorts: ${e.message}');
      rethrow;
    }
  }

// Get study waves
  Future<List<Map<String, dynamic>>> getStudyWaves(String studyId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.get(
        '/studies/$studyId/waves',
        options: Options(headers: {'Cookie': cookie}),
      );

      if (response.data is List) {
        final list = response.data as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected response format - Expected List but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('Error fetching waves: ${e.message}');
      rethrow;
    }
  }

// Create study wave
  Future<Map<String, dynamic>> createStudyWave({
    required String studyId,
    required String cohortId,
    required Map<String, dynamic> waveData,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.post(
        '/studies/$studyId/cohorts/$cohortId/waves',
        data: waveData,
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
      print('Error creating wave: ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStudySubjects(String studyId, String waveId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.get(
        '/studies/$studyId/subjects',
        options: Options(headers: {'Cookie': cookie}),
      );

      if (response.data is List) {
        final list = response.data as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected response format - Expected List but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('Error fetching subjects: ${e.message}');
      rethrow;
    }
  }

// Create study subject
  Future<Map<String, dynamic>> createStudySubject({
    required String studyId,
    required String cohortId,
    required String waveId,
    required Map<String, dynamic> subjectData,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.post(
        '/studies/$studyId/cohorts/$cohortId/waves/$waveId/subjects',
        data: subjectData,
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
      print('Error creating subject: ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStudyGroups(String studyId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.get(
        '/studies/$studyId/groups',
        options: Options(headers: {'Cookie': cookie}),
      );

      if (response.data is List) {
        final list = response.data as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected response format - Expected List but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('Error fetching groups: ${e.message}');
      rethrow;
    }
  }

// Create study group
  Future<Map<String, dynamic>> createStudyGroup({
    required String studyId,
    required Map<String, dynamic> groupData,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) throw Exception('No authentication cookie found');

      final response = await apiClient.post(
        '/studies/$studyId/groups',
        data: groupData,
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
      print('Error creating group: ${e.response?.data}');
      rethrow;
    }
  }
}