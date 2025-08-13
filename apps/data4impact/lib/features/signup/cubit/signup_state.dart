import 'package:equatable/equatable.dart';

class SignupState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const SignupState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  SignupState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, isSuccess];
}