import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final bool isSyncing;
  final double syncProgress; // Add sync progress (0.0 to 1.0)
  final List<Project> projects;
  final Project? selectedProject;
  final bool invitationLoading;
  final bool isOffline;
  final String? errorMessage;
  final int pendingSyncCount;
  final int totalToSync; // Add total items to sync
  final int syncedSoFar; // Add count of synced items

  const HomeState({
    this.isLoading = false,
    this.isSyncing = false,
    this.syncProgress = 0.0,
    this.projects = const [],
    this.selectedProject,
    this.invitationLoading = false,
    this.isOffline = false,
    this.errorMessage,
    this.pendingSyncCount = 0,
    this.totalToSync = 0,
    this.syncedSoFar = 0,
  });

  @override
  List<Object?> get props => [
    isLoading,
    isSyncing,
    syncProgress,
    projects,
    selectedProject,
    invitationLoading,
    isOffline,
    errorMessage,
    pendingSyncCount,
    totalToSync,
    syncedSoFar,
  ];

  HomeState copyWith({
    bool? isLoading,
    bool? isSyncing,
    double? syncProgress,
    List<Project>? projects,
    Project? selectedProject,
    bool? invitationLoading,
    bool? isOffline,
    String? errorMessage,
    int? pendingSyncCount,
    int? totalToSync,
    int? syncedSoFar,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      invitationLoading: invitationLoading ?? this.invitationLoading,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      totalToSync: totalToSync ?? this.totalToSync,
      syncedSoFar: syncedSoFar ?? this.syncedSoFar,
    );
  }
}