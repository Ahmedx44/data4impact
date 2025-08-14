import 'package:data4impact/core/model/signup/signin/signin_Request_model.dart';
import 'package:data4impact/core/model/signup/signin/signin_response_model.dart';
import 'package:data4impact/core/model/signup/signup_response_model.dart';
import 'package:data4impact/core/model/signup/singup_request_modell.dart';
import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

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
      // Rethrow the original DioException so cubit can handle it
      rethrow;
    }
  }

  Future<SignInResponseModel> signIn(SignInRequestModel request) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      return SignInResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e;
    }
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
      final response = await apiClient.get(
        '/oauth/url/$provider',
      );
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

      await apiClient.get(
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

  Future<void> verifyEmailOtp(String email, String otp) async {
    try {
      await apiClient.post(
        '/auth/verify-email',
        data: {
          'email': email,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<void> setNewPassword(String email, String otp, String newPassword) async {
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

}
