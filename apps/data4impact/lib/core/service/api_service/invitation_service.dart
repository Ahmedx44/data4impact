import 'package:data4impact/core/service/api_service/Model/invitation_model.dart';
import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InvitationService {
  InvitationService({required this.apiClient, required this.secureStorage});

  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  Future<List<InvitationModel>> getMyInvitation() async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final result = await apiClient.get(
        '/invitations/my',
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      final data = result.data;
      if (data is List) {
        final invitationResponse = data
            .map((invitation) =>
                InvitationModel.fromJson(invitation as Map<String, dynamic>))
            .toList();
        return invitationResponse;
      } else if (data is Map && data['data'] is List) {
        final invitationResponse = (data['data'] as List)
            .map((invitation) =>
                InvitationModel.fromJson(invitation as Map<String, dynamic>))
            .toList();
        return invitationResponse;
      } else {
        throw Exception(
            'Unexpected response format: ${data.runtimeType} — expected List or {data: List}');
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Map<String,dynamic>> acceptInvitation(String invitationId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final result = await apiClient.post(
        '/invitations/${invitationId}/accept',
        options: Options(
          headers: {
            'Cookie': cookie,
          },
        ),
      );
      return result.data as Map<String,dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message']);
    }
  }

  Future<Map<String,dynamic>> declineInvitation(String invitationId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final result = await apiClient.post(
        '/invitations/${invitationId}/decline',
        options: Options(
          headers: {
            'Cookie': cookie,
          },
        ),
      );
      return result.data as Map<String,dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message']);
    }
  }
}
