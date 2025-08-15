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

      if (response['success'] == true || response['verified'] == true) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        ToastService.showSuccessToast(message: 'Email verified successfully!');
        return;
      } else {
        final errorMessage = response['message'] ?? 'Email verification failed';
        emit(state.copyWith(
          isLoading: false,
        ));
        ToastService.showErrorToast(message: errorMessage.toString());
        return;
      }
    } on DioException catch (e) {
      final errorMessage = _getErrorMessage(e);
      emit(state.copyWith(
        isLoading: false,
      ));
      ToastService.showErrorToast(message: errorMessage.toString());
      return;
    } catch (e) {
      const errorMessage = 'Email verification failed';
      emit(state.copyWith(
        isLoading: false,
      ));
      ToastService.showErrorToast(message: errorMessage.toString());
      return;
    }
  }

  String _getErrorMessage(DioException e) {
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
