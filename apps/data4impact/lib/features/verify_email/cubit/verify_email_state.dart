// features/verify_email/cubit/verify_email_state.dart
part of 'verify_email_cubit.dart';

class VerifyEmailState {
  final bool isLoading;
  final bool isSuccess;


  VerifyEmailState({
    this.isLoading = false,
    this.isSuccess = false,

  });

  VerifyEmailState copyWith({
    bool? isLoading,
    bool? isSuccess,
  }) {
    return VerifyEmailState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}