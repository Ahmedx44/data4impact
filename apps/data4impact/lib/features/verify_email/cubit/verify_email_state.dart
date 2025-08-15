part of 'verify_email_cubit.dart';

class VerifyEmailState {
  final bool isLoading;
  final bool isSuccess;
  final String? verificationMessage;
  final String? errorMessage;

  VerifyEmailState({
    this.isLoading = false,
    this.isSuccess = false,
    this.verificationMessage,
    this.errorMessage,
  });

  VerifyEmailState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? verificationMessage,
    String? errorMessage,
  }) {
    return VerifyEmailState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      verificationMessage: verificationMessage ?? this.verificationMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}