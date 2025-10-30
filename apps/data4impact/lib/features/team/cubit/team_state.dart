// team_state.dart
import 'package:equatable/equatable.dart';

class TeamState extends Equatable {
  final bool isLoading;
  final List<dynamic> teams;
  final String? error;

  const TeamState({
    this.isLoading = false,
    this.teams = const [],
    this.error,
  });

  TeamState copyWith({
    bool? isLoading,
    List<dynamic>? teams,
    String? error,
  }) {
    return TeamState(
      isLoading: isLoading ?? this.isLoading,
      teams: teams ?? this.teams,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, teams, error];
}