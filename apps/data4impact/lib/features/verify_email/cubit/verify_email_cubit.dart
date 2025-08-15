// features/verify_email/cubit/verify_email_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/login/page/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  final AuthService authService;

  VerifyEmailCubit({required this.authService}) : super(VerifyEmailState());

  Future<void> sendVerificationEmail({
    required String email,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      await authService.sendEmailVerification(email);
      emit(state.copyWith(isLoading: false, isSuccess: true));
      ToastService.showSuccessToast(
          message: 'Verification email sent successfully');
    } on DioException catch (e) {
      final errorMessage = _getErrorMessage(e);
      emit(state.copyWith(
        isLoading: false,
      ));
      ToastService.showErrorToast(message: errorMessage.toString());
    } catch (e) {
      const errorMessage = 'Failed to send verification email';
      emit(state.copyWith(
        isLoading: false,
      ));
      ToastService.showErrorToast(message: errorMessage.toString());
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await authService.verifyEmailOtp(email, otp);

      // Handle successful verification
      if (response is Map && response['message'] != null) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          verificationMessage: response['message'].toString(),
        ));
        ToastService.showSuccessToast(message: response['message'].toString());
        return;
      }

      // Handle unexpected response format
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected response format',
      ));
      ToastService.showErrorToast(message: 'Unexpected response format');

    } on DioException catch (e) {
      // Special case: Handle 200 status code responses caught as DioException
      if (e.response?.statusCode == 200) {
        final message = e.response?.data['message'] ?? 'Email verified successfully';
        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          verificationMessage: message.toString(),
        ));
        ToastService.showSuccessToast(message: message.toString());
      } else {
        final errorMessage = _getErrorMessage(e);
        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ));
        ToastService.showErrorToast(message: errorMessage);
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Email verification failed',
      ));
      ToastService.showErrorToast(message: 'Email verification failed');
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.statusCode == 200) {
      return e.response?.data['message'].toString() ?? 'Operation completed successfully';
    }

    try {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return responseData['message'] as String? ??
            responseData['error'] as String? ??
            'Verification failed';
      }
      return e.message ?? 'Verification failed';
    } catch (_) {
      return 'Verification failed';
    }
  }
}
