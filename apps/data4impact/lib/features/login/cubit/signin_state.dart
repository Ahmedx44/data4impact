
import 'package:data4impact/core/model/signup/signin/signin_response_model.dart';

class SigninState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final SignInResponseModel? user;

  const SigninState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.user,
  });

  SigninState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    SignInResponseModel? user,
  }) {
    return SigninState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  @override
  String toString() =>
      'SigninState{isLoading: $isLoading, isSuccess: $isSuccess, error: $error, user: $user}';
}
