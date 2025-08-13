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
}
