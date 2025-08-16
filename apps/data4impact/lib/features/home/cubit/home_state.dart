import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool invitationLoading;
  final String? message;
  final List<Project> projects;
  final Project? selectedProject;

  const HomeState({
    this.isLoading = false,
    this.invitationLoading=false,
    this.message,
    this.projects = const [],
    this.selectedProject,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? invitationLoading,
    String? message,
    List<Project>? projects,
    Project? selectedProject,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      invitationLoading:invitationLoading??this.invitationLoading,
      message: message ?? this.message,
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
    );
  }

  @override
  List<Object?> get props => [isLoading,invitationLoading, message, projects];
}
