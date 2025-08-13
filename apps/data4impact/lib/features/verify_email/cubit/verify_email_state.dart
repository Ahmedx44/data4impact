import 'package:equatable/equatable.dart';

class VerifyEmailState extends Equatable {
  final bool isLoading;

  const VerifyEmailState({
    this.isLoading = false,
  });

  VerifyEmailState copyWith({
    bool? isLoading,
  }) {
    return VerifyEmailState(
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
      ];
}
