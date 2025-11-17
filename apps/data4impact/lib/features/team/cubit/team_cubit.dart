// team_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/Model/team_model.dart';
import 'package:data4impact/core/service/api_service/team_service.dart';
import 'package:data4impact/features/team/cubit/team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final TeamService teamService;

  TeamCubit({required this.teamService}) : super(const TeamState());

  Future<void> getTeams() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final response = await teamService.getTeams();

      print('API Response: ${response}');

      List<TeamModel> teams = [];

      if (response is List) {
        teams = response.map((teamData) {
          if (teamData is Map<String, dynamic>) {
            return TeamModel.fromJson(teamData);
          } else if (teamData is TeamModel) {
            return teamData;
          } else {
            return const TeamModel(
              id: '',
              name: 'Unknown Team',
              description: '',
              memberCount: 0,
            );
          }
        }).toList();
      }

      // Calculate statistics
      final totalTeams = teams.length;
      final totalCollectors = teams.fold(0, (sum, team) => sum + team.memberCount);
      final totalSupervisors = teams.fold(0, (sum, team) {
        // You might need to adjust this logic based on your actual data structure
        return sum + (team.memberCount > 0 ? 1 : 0); // Example logic
      });
      final totalFields = teams.fold(0, (sum, team) => sum + team.fields.length);

      emit(state.copyWith(
        isLoading: false,
        teams: teams,
        totalTeams: totalTeams,
        totalCollectors: totalCollectors,
        totalSupervisors: totalSupervisors,
        totalFields: totalFields,
      ));

    } catch (e) {
      print('Error fetching teams: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}