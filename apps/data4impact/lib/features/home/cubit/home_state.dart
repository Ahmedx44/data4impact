import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final List<Project> projects;
  final Project? selectedProject;
  final bool invitationLoading;
  final bool isOffline;
  final String? errorMessage;

  const HomeState({
    this.isLoading = false,
    this.projects = const [],
    this.selectedProject,
    this.invitationLoading = false,
    this.isOffline = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    isLoading,
    projects,
    selectedProject,
    invitationLoading,
    isOffline,
    errorMessage,
  ];

  HomeState copyWith({
    bool? isLoading,
    List<Project>? projects,
    Project? selectedProject,
    bool? invitationLoading,
    bool? isOffline,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      invitationLoading: invitationLoading ?? this.invitationLoading,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}