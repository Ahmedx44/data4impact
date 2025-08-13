import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/features/verify_email/cubit/verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit({required this.authService})
      : super(const VerifyEmailState());

  final AuthService authService;

  Future<void> sendVerificationEmail({required String email}) async {

    print('debugg:  calledd');
    try {
      final response = await authService.sendEmailVerification(email);

      print('debugg:  ${response}');
    } catch (e) {}
  }
}
