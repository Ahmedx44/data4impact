// forget_password_state.dart
import 'package:data4impact/core/model/signup/signin/signin_response_model.dart';

class ForgetPasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final String? email;
  final String? otp;
  final int currentStep; // 0: Email, 1: OTP, 2: New Password

  const ForgetPasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.email,
    this.otp,
    this.currentStep = 0,
  });

  ForgetPasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    String? email,
    String? otp,
    int? currentStep,
  }) {
    return ForgetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}