enum ContributorsStatus { initial, loading, success, failure }

class ContributorsState {
  final ContributorsStatus status;
  final List<dynamic> contributors;
  final String? errorMessage;

  const ContributorsState({
    this.status = ContributorsStatus.initial,
    this.contributors = const [],
    this.errorMessage,
  });

  ContributorsState copyWith({
    ContributorsStatus? status,
    List<dynamic>? contributors,
    String? errorMessage,
  }) {
    return ContributorsState(
      status: status ?? this.status,
      contributors: contributors ?? this.contributors,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
