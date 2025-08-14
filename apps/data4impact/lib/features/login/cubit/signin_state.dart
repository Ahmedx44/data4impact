import 'package:data4impact/core/model/signup/signin/signin_response_model.dart';

class SigninState {
  final bool isLoading;
  final bool isSuccess;
  final bool isGoogleSignIn; // New field for tracking Google Sign-In
  final String? error;
  final SignInResponseModel? user;

  const SigninState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isGoogleSignIn = false, // Default to false
    this.error,
    this.user,
  });

  SigninState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isGoogleSignIn,
    String? error,
    SignInResponseModel? user,
  }) {
    return SigninState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isGoogleSignIn: isGoogleSignIn ?? this.isGoogleSignIn,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  @override
  String toString() =>
      'SigninState{isLoading: $isLoading, isSuccess: $isSuccess, '
          'isGoogleSignIn: $isGoogleSignIn, error: $error, user: $user}';
}