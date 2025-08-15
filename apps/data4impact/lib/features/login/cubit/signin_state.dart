import 'package:data4impact/core/model/signup/signin/signin_response_model.dart';

class SigninState {
  final bool isLoading;
  final bool isSuccess;
  final bool isGoogleSignIn;
  final SignInResponseModel? user;

  const SigninState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isGoogleSignIn = false,
    this.user,
  });

  SigninState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isGoogleSignIn,
    SignInResponseModel? user,
  }) {
    return SigninState(
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