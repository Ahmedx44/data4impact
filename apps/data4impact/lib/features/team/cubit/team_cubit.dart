import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/Model/team_model.dart';
import 'package:data4impact/core/service/api_service/Model/member_model.dart';
import 'package:data4impact/core/service/api_service/team_service.dart';
import 'package:data4impact/core/service/internt_connection_monitor.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/repository/offline_mode_repo.dart';
import 'package:data4impact/features/team/cubit/team_state.dart';

class TeamCubit extends Cubit<TeamState> {
  final TeamService teamService;

  TeamCubit({required this.teamService}) : super(const TeamState());

  Future<void> getTeams() async {
    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    emit(state.copyWith(isLoading: true, error: null));
    try {
      if (isConnected) {
        final response = await teamService.getTeams();

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
        final totalCollectors =
            teams.fold(0, (sum, team) => sum + team.memberCount);
        final totalSupervisors = teams.fold(0, (sum, team) {
          return sum + (team.memberCount > 0 ? 1 : 0);
        });
        final totalFields =
            teams.fold(0, (sum, team) => sum + team.fields.length);

        await OfflineModeDataRepo().saveTeams(response as List);

        emit(state.copyWith(
          isLoading: false,
          teams: teams,
          totalTeams: totalTeams,
          totalCollectors: totalCollectors,
          totalSupervisors: totalSupervisors,
          totalFields: totalFields,
        ));
      } else {
        final savedTeams = await OfflineModeDataRepo().getSavedTeams();

        List<TeamModel> teams = [];

        if (savedTeams is List) {
          teams = savedTeams.map((teamData) {
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

        // Calculate statistics for offline data
        final totalTeams = teams.length;
        final totalCollectors =
            teams.fold(0, (sum, team) => sum + team.memberCount);
        final totalSupervisors = teams.fold(0, (sum, team) {
          return sum + (team.memberCount > 0 ? 1 : 0);
        });
        final totalFields =
            teams.fold(0, (sum, team) => sum + team.fields.length);

        emit(state.copyWith(
          isLoading: false,
          teams: teams,
          totalTeams: totalTeams,
          totalCollectors: totalCollectors,
          totalSupervisors: totalSupervisors,
          totalFields: totalFields,
        ));

        if (savedTeams.isEmpty) {
          ToastService.showWarningToast(
            message: 'No cached teams data available offline',
          );
        } else {
        }
      }
    } catch (e) {
      if (isConnected) {
        try {
          final savedTeams = await OfflineModeDataRepo().getSavedTeams();

          List<TeamModel> teams = [];

          if (savedTeams is List) {
            teams = savedTeams.map((teamData) {
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

          // Calculate statistics for cached data
          final totalTeams = teams.length;
          final totalCollectors =
              teams.fold(0, (sum, team) => sum + team.memberCount);
          final totalSupervisors = teams.fold(0, (sum, team) {
            return sum + (team.memberCount > 0 ? 1 : 0);
          });
          final totalFields =
              teams.fold(0, (sum, team) => sum + team.fields.length);

          emit(
            state.copyWith(
              isLoading: false,
              teams: teams,
              totalTeams: totalTeams,
              totalCollectors: totalCollectors,
              totalSupervisors: totalSupervisors,
              totalFields: totalFields,
            ),
          );

          ToastService.showWarningToast(
            message: 'Using cached data due to network error',
          );
        } catch (cacheError) {
          emit(state.copyWith(
            isLoading: false,
            teams: [],
            totalTeams: 0,
            totalCollectors: 0,
            totalSupervisors: 0,
            totalFields: 0,
            error: 'Failed to fetch teams',
          ));

          ToastService.showErrorToast(message: 'Failed to fetch teams');
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          teams: [],
          totalTeams: 0,
          totalCollectors: 0,
          totalSupervisors: 0,
          totalFields: 0,
          error: 'No cached teams data available',
        ));
        ToastService.showErrorToast(
          message: 'No cached teams data available',
        );
      }
    }
  }

  // Team Detail Methods
  Future<void> getTeamMembers(String teamId) async {
    emit(state.copyWith(
      isLoading: true
    ));

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    emit(state.copyWith(
      isLoading: true,
      error: null,
      currentTeamMembers: [],
      currentTeamMemberStudies: {},
    ));

    try {
      if (isConnected) {
        final response = await teamService.getTeamMembers(teamId);

        List<MemberModel> members = [];

        if (response is List) {
          members = response.map((memberData) {
            return MemberModel.fromJson(memberData as Map<String, dynamic>);
          }).toList();
        }

        // Save to offline storage
        await OfflineModeDataRepo().saveTeamMembers(teamId, response);

        emit(state.copyWith(
          isLoading: false,
          currentTeamMembers: members,
          currentTeamId: teamId,
        ));
      } else {
        final savedMembers =
            await OfflineModeDataRepo().getSavedTeamMembers(teamId);

        List<MemberModel> members = [];

        if (savedMembers is List) {
          members = savedMembers.map((memberData) {
            if (memberData is Map<String, dynamic>) {
              return MemberModel.fromJson(memberData);
            } else {
              return MemberModel(
                id: '',
                user: User(
                  id: '',
                  email: '',
                  firstName: '',
                  lastName: '',
                  middleName: '',
                  roles: [],
                  phone: '',
                  emailVerified: null,
                  active: null,
                  createdAt: null,
                  updatedAt: null,
                ),
                roles: [],
                attributes: {},
                team: '',
                project: '',
                organization: '',
                userId: '',
                createdAt: null,
                updatedAt: null,
              );
            }
          }).toList();
        }

        emit(state.copyWith(
          isLoading: false,
          currentTeamMembers: members,
          currentTeamId: teamId,
        ));

        if (savedMembers.isEmpty) {
          ToastService.showWarningToast(
            message: 'No cached team members data available offline',
          );
        } else {
        }
      }
    } catch (e) {
      if (isConnected) {
        try {
          final savedMembers =
              await OfflineModeDataRepo().getSavedTeamMembers(teamId);

          List<MemberModel> members = [];

          if (savedMembers is List) {
            members = savedMembers.map((memberData) {
              if (memberData is Map<String, dynamic>) {
                return MemberModel.fromJson(memberData);
              } else {
                return MemberModel(
                  id: '',
                  user: User(
                    id: '',
                    email: '',
                    firstName: '',
                    lastName: '',
                    middleName: '',
                    roles: [],
                    phone: '',
                    emailVerified: null,
                    active: null,
                    createdAt: null,
                    updatedAt: null,
                  ),
                  roles: [],
                  attributes: {},
                  team: '',
                  project: '',
                  organization: '',
                  userId: '',
                  createdAt: null,
                  updatedAt: null,
                );
              }
            }).toList();
          }

          emit(state.copyWith(
            isLoading: false,
            currentTeamMembers: members,
            currentTeamId: teamId,
          ));

          ToastService.showWarningToast(
            message: 'Using cached data due to network error',
          );
        } catch (cacheError) {
          emit(state.copyWith(
            isLoading: false,
            currentTeamMembers: [],
            error: 'Failed to fetch team members',
          ));

          ToastService.showErrorToast(message: 'Failed to fetch team members');
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          currentTeamMembers: [],
          error: 'No cached team members data available',
        ));
        ToastService.showErrorToast(
          message: 'No cached team members data available',
        );
      }
    }
  }

  Future<void> getMemberStudies(
      String memberId, List<Map<String, dynamic>> collectors) async {
    try {
      // Get the member
      final member =
          state.currentTeamMembers.firstWhere((m) => m.id == memberId);

      // Convert collectors to studies format
      final studies = collectors.map((collector) {
        final studyData = collector['study'] as Map<String, dynamic>?;
        final userData = collector['user'] as Map<String, dynamic>?;

        final studyName = studyData?['name'] ?? 'Unnamed Study';
        final studyStatus = collector['status'] ?? 'unknown';
        final isActive = studyStatus.toString().toLowerCase() == 'inprogress';

        return {
          'id': collector['_id'],
          'name': studyName,
          'description': studyData?['description'] ?? '',
          'responseCount': collector['responseCount'] ?? 0,
          'maxLimit': collector['maxLimit'] ?? 0,
          'status': studyStatus,
          'assignedDate': collector['assignedDate'] ?? '',
          'completedDate': collector['completedDate'] ?? '',
          'studyId': studyData?['_id'] ?? '',
          'allowOffline': collector['allowOffline'] ?? false,
          'project': collector['project'] ?? '',
          'cohorts': collector['cohorts'] ?? [],
          'userName': userData != null
              ? '${userData['firstName']} ${userData['lastName']}'
              : 'Unknown User',
          'userEmail': userData?['email'] ?? '',
          'createdAt': collector['createdAt'] ?? '',
          'updatedAt': collector['updatedAt'] ?? '',
          'isActive': isActive,
        };
      }).toList();

      // Update state with member studies
      final updatedStudies =
          Map<String, List<dynamic>>.from(state.currentTeamMemberStudies);
      updatedStudies[memberId] = studies;

      emit(state.copyWith(
        currentTeamMemberStudies: updatedStudies,
      ));
    } catch (e) {
      print('❌ Error loading studies for member $memberId: $e');
      final updatedStudies =
          Map<String, List<dynamic>>.from(state.currentTeamMemberStudies);
      updatedStudies[memberId] = [];
      emit(state.copyWith(
        currentTeamMemberStudies: updatedStudies,
      ));
    }
  }

  void toggleMemberExpansion(String memberId) {
    final updatedExpansions = Map<String, bool>.from(state.expandedMembers);
    updatedExpansions[memberId] = !(state.expandedMembers[memberId] ?? false);

    emit(state.copyWith(
      expandedMembers: updatedExpansions,
    ));
  }

  void toggleStudySelection(String memberId, int studyIndex, bool? value) {
    final updatedSelections =
        Map<String, List<bool>>.from(state.selectedStudies);
    if (!updatedSelections.containsKey(memberId)) {
      updatedSelections[memberId] = [];
    }

    final studies = updatedSelections[memberId]!;
    if (studyIndex < studies.length) {
      studies[studyIndex] = value ?? false;
    }

    emit(state.copyWith(
      selectedStudies: updatedSelections,
    ));
  }

  void toggleSelectAllStudies(String memberId, bool? value) {
    final updatedSelections =
        Map<String, List<bool>>.from(state.selectedStudies);
    final studies = state.currentTeamMemberStudies[memberId] ?? [];

    updatedSelections[memberId] =
        List.generate(studies.length, (index) => value ?? false);

    emit(state.copyWith(
      selectedStudies: updatedSelections,
    ));
  }

  void clearTeamDetail() {
    emit(state.copyWith(
      currentTeamMembers: [],
      currentTeamMemberStudies: {},
      expandedMembers: {},
      selectedStudies: {},
      currentTeamId: null,
    ));
  }

  // Method to manually refresh teams data
  Future<void> refreshTeams() async {
    await getTeams();
  }

  Future<void> refreshTeamMembers(String teamId) async {
    await getTeamMembers(teamId);
  }
}
