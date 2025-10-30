// team_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/team_service.dart';
import 'package:data4impact/features/team/cubit/team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final TeamService teamService;

  TeamCubit({required this.teamService}) : super(const TeamState());

  Future<void> getTeams() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final response = await teamService.getTeams();

      print('responseeee: ${response}');

      // Assuming response is a List
      List<dynamic> teams = response is List ? response : [];

      emit(state.copyWith(
        isLoading: false,
        teams: teams,
      ));

    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}