// team_state.dart
import 'package:data4impact/core/service/api_service/Model/team_model.dart';
import 'package:equatable/equatable.dart';

class TeamState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<TeamModel> teams;
  final int totalTeams;
  final int totalCollectors;
  final int totalSupervisors;
  final int totalFields;

  const TeamState({
    this.isLoading = false,
    this.error,
    this.teams = const [],
    this.totalTeams = 0,
    this.totalCollectors = 0,
    this.totalSupervisors = 0,
    this.totalFields = 0,
  });

  TeamState copyWith({
    bool? isLoading,
    String? error,
    List<TeamModel>? teams,
    int? totalTeams,
    int? totalCollectors,
    int? totalSupervisors,
    int? totalFields,
  }) {
    return TeamState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      teams: teams ?? this.teams,
      totalTeams: totalTeams ?? this.totalTeams,
      totalCollectors: totalCollectors ?? this.totalCollectors,
      totalSupervisors: totalSupervisors ?? this.totalSupervisors,
      totalFields: totalFields ?? this.totalFields,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    teams,
    totalTeams,
    totalCollectors,
    totalSupervisors,
    totalFields,
  ];
}