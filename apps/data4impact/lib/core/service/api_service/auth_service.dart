import 'dart:convert';

import 'package:data4impact/core/model/signup/signin/signin_Request_model.dart';
import 'package:data4impact/core/model/signup/signin/signin_response_model.dart';
import 'package:data4impact/core/model/signup/signup_response_model.dart';
import 'package:data4impact/core/model/signup/singup_request_modell.dart';
import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  AuthService({required this.apiClient, required this.secureStorage});

  Future<SignupResponseModel> signUp(SignupRequestModel request) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: request.toJson(),
      );

      return SignupResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<({SignInResponseModel user, Headers headers})> signIn(
      SignInRequestModel request) async {
    final response = await apiClient.post(
      '/auth/login',
      data: request.toJson(),
    );

    if (response.statusCode! < 200 || response.statusCode! >= 300) {
      // Throw DioException so it gets caught in your LoginCubit's DioException catch block
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Login failed with status ${response.statusCode}',
      );
    }

    return (
      user: SignInResponseModel.fromJson(response.data as Map<String, dynamic>),
      headers: response.headers,
    );
  }

  Future<Map<String, dynamic>> sendEmailVerification(String email) async {
    try {
      final response = await apiClient.post(
        '/auth/email-verification',
        data: {'email': email},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<String> getOAuthUrl(String provider) async {
    try {
      final response = await apiClient.get('/oauth/url/$provider');
      return response.data['url'] as String;
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<void> handleOAuthRedirect({
    required String provider,
    required String code,
    required String state,
    required String flavor,
  }) async {
    try {
      final appName = switch (flavor) {
        'production' => 'Data4impact',
        'staging' => '[STG] Data4impact',
        'development' => '[DEV] Data4impact',
        _ => 'Data4impact',
      };

      final response = await apiClient.get(
        '/oauth/redirect/$provider',
        queryParameters: {
          'code': code,
          'state': state,
        },
        options: Options(
          headers: {
            'user-agent': '$appName/1.0.0',
          },
        ),
      );
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<void> forgetPassword(String email) async {
    try {
      await apiClient.post(
        '/auth/forget-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp(String email, String otp) async {
    try {
      final response = await apiClient.post(
        '/auth/verify-email',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return responseData;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: responseData['message'] ?? 'Email verification failed',
      );
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/verify-email'),
        error: 'An unexpected error occurred during verification',
      );
    }
  }

  Future<void> setNewPassword(
      String email, String otp, String newPassword) async {
    try {
      await apiClient.post(
        '/auth/set-password',
        data: {
          'email': email,
          'otp': otp,
          'password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<CurrentUser> getCurrentUser() async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/auth/me',
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      if (response.data is Map<String, dynamic>) {
        return CurrentUser.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      print('DioError: ${e.response?.data}');
      rethrow;
    }
  }

  Future<CurrentUser?> getStoredCurrentUser() async {
    try {
      final userJson = await secureStorage.read(key: 'current_user');
      if (userJson != null) {
        final userMap = Map<String, dynamic>.from(userJson as Map<String,dynamic>);
        return CurrentUser.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error retrieving stored user: $e');
      return null;
    }
  }

  Future<void> clearStoredCurrentUser() async {
    await secureStorage.delete(key: 'current_user');
  }


  Future<String?> getStoredRole() async {
    return await secureStorage.read(key: 'user_role');
  }

  Future<void> clearStoredRole() async {
    await secureStorage.delete(key: 'user_role');
  }

  Future<void> switchProject(String projectId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');

      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      await apiClient.post(
        '/auth/switch-project',
        data: {'projectId': projectId},
        options: Options(
          headers: {
            'Cookie': cookie,
            'Content-Type': 'application/json',
          },
        ),
      );

      // Update stored project in secure storage
      await secureStorage.write(key: 'current_project_id', value: projectId);

    } on DioException catch (e) {
      print('Error switching project: ${e.message}');
      rethrow;
    }
  }

  // Get current project ID from storage
  Future<String?> getCurrentProjectId() async {
    return await secureStorage.read(key: 'current_project_id');
  }
}
