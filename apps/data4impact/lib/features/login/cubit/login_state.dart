import 'package:data4impact/core/model/signup/signin/signin_response_model.dart';

class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final bool isGoogleSignIn;
  final SignInResponseModel? user;

  const LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isGoogleSignIn = false,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isGoogleSignIn,
    SignInResponseModel? user,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isGoogleSignIn: isGoogleSignIn ?? this.isGoogleSignIn,
      user: user ?? this.user,
    );
  }

  @override
  String toString() =>
      'SigninState{isLoading: $isLoading, isSuccess: $isSuccess, '
          'isGoogleSignIn: $isGoogleSignIn, user: $user}';
}