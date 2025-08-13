import 'package:bloc/bloc.dart';
import 'package:data4impact/core/model/signup/signin/signin_Request_model.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/login/cubit/signin_state.dart';
import 'package:dio/dio.dart';

class SigninCubit extends Cubit<SigninState> {
  final AuthService authService;

  SigninCubit({required this.authService}) : super(const SigninState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, error: null, isSuccess: false));

    try {
      final response = await authService.signIn(
        SignInRequestModel(email: email, password: password),
      );

      ToastService.showSuccessToast(message: 'Login successful');
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        user: response,
      ));
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: errorMessage,
      ));
    } catch (e, stack) {
      const errorMessage = 'An unexpected error occurred. Please try again.';
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: errorMessage,
      ));
    }
  }

  String _extractErrorMessage(DioException e) {
    try {
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] is String) {
          return data['message'] as String;
        }
      }
      return e.message ?? 'Login failed. Please try again.';
    } catch (_) {
      return 'Login failed. Please try again.';
    }
  }
}