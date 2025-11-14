// team_state.dart
import 'package:data4impact/core/service/api_service/Model/team_model.dart';
import 'package:equatable/equatable.dart';

class TeamState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<TeamModel> teams;

  const TeamState({
    this.isLoading = false,
    this.error,
    this.teams = const [],
  });

  TeamState copyWith({
    bool? isLoading,
    String? error,
    List<TeamModel>? teams,
  }) {
    return TeamState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      teams: teams ?? this.teams,
    );
  }

  @override
  List<Object?> get props => [isLoading,error,teams];
}