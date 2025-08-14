// forget_password_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/forget_password/cubit/forget_password_state.dart';
import 'package:dio/dio.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final AuthService authService;

  ForgetPasswordCubit({required this.authService}) : super(const ForgetPasswordState());

  Future<void> sendResetEmail(String email) async {
    emit(state.copyWith(isLoading: true, error: null, isSuccess: false));

    try {
      await authService.forgetPassword(email);
      emit(state.copyWith(
        isLoading: false,
        email: email,
        currentStep: 1, // Move to OTP step
      ));
      ToastService.showSuccessToast(message: 'Reset email sent successfully');
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isLoading: false,
        error: errorMessage,
      ));
      ToastService.showErrorToast(message: errorMessage);
    } catch (e) {
      const errorMessage = 'Failed to send reset email. Please try again.';
      emit(state.copyWith(
        isLoading: false,
        error: errorMessage,
      ));
      ToastService.showErrorToast(message: errorMessage);
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (state.email == null) return;

    emit(state.copyWith(isLoading: true, error: null, isSuccess: false));

    try {
      await authService.verifyEmailOtp(state.email!, otp);
      emit(state.copyWith(
        isLoading: false,
        otp: otp,
        currentStep: 2,
      ));
      ToastService.showSuccessToast(message: 'OTP verified successfully');
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isLoading: false,
        error: errorMessage,
      ));
      ToastService.showErrorToast(message: errorMessage);
    } catch (e) {
      const errorMessage = 'Failed to verify OTP. Please try again.';
      emit(state.copyWith(
        isLoading: false,
        error: errorMessage,
      ));
      ToastService.showErrorToast(message: errorMessage);
    }
  }

  Future<void> resetPassword(String newPassword) async {
    if (state.email == null || state.otp == null) return;

    emit(state.copyWith(isLoading: true, error: null, isSuccess: false));

    try {
      await authService.setNewPassword(
        state.email!,
        state.otp!,
        newPassword,
      );
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
      ));
      ToastService.showSuccessToast(message: 'Password reset successfully');
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isLoading: false,
        error: errorMessage,
      ));
      ToastService.showErrorToast(message: errorMessage);
    } catch (e) {
      const errorMessage = 'Failed to reset password. Please try again.';
      emit(state.copyWith(
        isLoading: false,
        error: errorMessage,
      ));
      ToastService.showErrorToast(message: errorMessage);
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
      return e.message ?? 'An error occurred. Please try again.';
    } catch (_) {
      return 'An error occurred. Please try again.';
    }
  }
}