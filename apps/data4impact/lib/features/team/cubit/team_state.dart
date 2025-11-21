import 'package:data4impact/core/service/api_service/Model/team_model.dart';
import 'package:data4impact/core/service/api_service/Model/member_model.dart';
import 'package:equatable/equatable.dart';

class TeamState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<TeamModel> teams;
  final int totalTeams;
  final int totalCollectors;
  final int totalSupervisors;
  final int totalFields;

  // Team Detail State
  final List<MemberModel> currentTeamMembers;
  final String? currentTeamId;
  final Map<String, List<dynamic>> currentTeamMemberStudies;
  final Map<String, bool> expandedMembers;
  final Map<String, List<bool>> selectedStudies;

  const TeamState({
    this.isLoading = false,
    this.error,
    this.teams = const [],
    this.totalTeams = 0,
    this.totalCollectors = 0,
    this.totalSupervisors = 0,
    this.totalFields = 0,
    this.currentTeamMembers = const [],
    this.currentTeamId,
    this.currentTeamMemberStudies = const {},
    this.expandedMembers = const {},
    this.selectedStudies = const {},
  });

  TeamState copyWith({
    bool? isLoading,
    String? error,
    List<TeamModel>? teams,
    int? totalTeams,
    int? totalCollectors,
    int? totalSupervisors,
    int? totalFields,
    List<MemberModel>? currentTeamMembers,
    String? currentTeamId,
    Map<String, List<dynamic>>? currentTeamMemberStudies,
    Map<String, bool>? expandedMembers,
    Map<String, List<bool>>? selectedStudies,
  }) {
    return TeamState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      teams: teams ?? this.teams,
      totalTeams: totalTeams ?? this.totalTeams,
      totalCollectors: totalCollectors ?? this.totalCollectors,
      totalSupervisors: totalSupervisors ?? this.totalSupervisors,
      totalFields: totalFields ?? this.totalFields,
      currentTeamMembers: currentTeamMembers ?? this.currentTeamMembers,
      currentTeamId: currentTeamId ?? this.currentTeamId,
      currentTeamMemberStudies: currentTeamMemberStudies ?? this.currentTeamMemberStudies,
      expandedMembers: expandedMembers ?? this.expandedMembers,
      selectedStudies: selectedStudies ?? this.selectedStudies,
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
    currentTeamMembers,
    currentTeamId,
    currentTeamMemberStudies,
    expandedMembers,
    selectedStudies,
  ];
}