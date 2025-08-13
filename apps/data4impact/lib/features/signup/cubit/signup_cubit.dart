import 'package:bloc/bloc.dart';
import 'package:data4impact/core/model/signup/singup_request_modell.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/signup/cubit/signup_state.dart';
import 'package:dio/dio.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({required this.authService}) : super(const SignupState());

  final AuthService authService;

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? middleName,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        error: null,
        isSuccess: false,
      ),
    );

    try {
      final response = await authService.signUp(
        SignupRequestModel(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          password: password,
          middleName: middleName,
        ),
      );

      if (response.error ||
          (response.statusCode != null && response.statusCode != 200)) {
        ToastService.showErrorToast(message: response.message);
        emit(state.copyWith(isLoading: false, isSuccess: false));
        return;
      }

      ToastService.showSuccessToast(message: response.message);

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } on DioException catch (e) {
      String errorMessage = 'Registration failed. Please try again.';

      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response?.data as Map<String, dynamic>;
        if (data['message'] is String &&
            (data['message'] as String).isNotEmpty) {
          errorMessage = data['message'] as String;
        }
      } else if (e.response?.data is String &&
          (e.response?.data as String).isNotEmpty) {
        errorMessage = e.response?.data as String;
      }

      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(isLoading: false, isSuccess: false));
    } catch (e, stack) {
      const errorMessage = 'An unexpected error occurred. Please try again.';
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(isLoading: false, isSuccess: false));
    }
  }
}
