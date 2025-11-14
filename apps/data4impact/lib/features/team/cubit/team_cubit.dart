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
            // Fallback for unexpected data types
            return TeamModel(
              id: '',
              name: 'Unknown Team',
              description: '',
              memberCount: 0,
            );
          }
        }).toList();
      }

      emit(state.copyWith(
        isLoading: false,
        teams: teams,
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