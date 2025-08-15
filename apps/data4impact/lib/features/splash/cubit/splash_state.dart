part of 'splash_cubit.dart';

enum SplashStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class SplashState {
  final SplashStatus status;

  const SplashState({required this.status});

  SplashState copyWith({SplashStatus? status}) {
    return SplashState(
      status: status ?? this.status,
    );
  }
}
