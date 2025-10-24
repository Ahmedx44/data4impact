import 'package:data4impact/core/service/api_service/api_client.dart';

class InvitationService {
  InvitationService({required this.apiClient});

  final ApiClient apiClient;

  Future<void> getListOfInvitations({required String userId}) async {
    try {
     final result=  await apiClient.get('/invite/user/$userId');

     print('Result Inviation List: ${result}');


    } catch (e, stack) {}
  }
}
