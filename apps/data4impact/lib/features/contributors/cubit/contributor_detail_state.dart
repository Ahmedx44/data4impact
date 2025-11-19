import 'package:equatable/equatable.dart';

enum ContributorDetailStatus { initial, loading, success, failure }

class ContributorDetailState extends Equatable {
  final ContributorDetailStatus status;
  final Map<String, dynamic>? contributor;
  final String? errorMessage;

  const ContributorDetailState({
    this.status = ContributorDetailStatus.initial,
    this.contributor,
    this.errorMessage,
  });

  ContributorDetailState copyWith({
    ContributorDetailStatus? status,
    Map<String, dynamic>? contributor,
    String? errorMessage,
  }) {
    return ContributorDetailState(
      status: status ?? this.status,
      contributor: contributor ?? this.contributor,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, contributor, errorMessage];
}
