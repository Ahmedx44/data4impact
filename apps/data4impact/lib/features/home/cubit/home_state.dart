// lib/features/home/cubit/home_state.dart

import 'package:data4impact/core/service/api_service/Model/project.dart';

class HomeState {
  final bool isLoading;
  final bool fetchingProjects;
  final bool fetchingCollectors;
  final bool isOffline;
  final bool isSyncing;
  final double syncProgress;
  final int totalToSync;
  final int syncedSoFar;
  final int pendingSyncCount;
  final bool invitationLoading;
  final List<Project> projects;
  final Project? selectedProject;
  final List<Map<String, dynamic>> collectors;

  const HomeState({
    this.isLoading = false,
    this.fetchingProjects = false,
    this.fetchingCollectors = true,
    this.isOffline = false,
    this.isSyncing = false,
    this.syncProgress = 0.0,
    this.totalToSync = 0,
    this.syncedSoFar = 0,
    this.pendingSyncCount = 0,
    this.invitationLoading = false,
    this.projects = const [],
    this.selectedProject,
    this.collectors = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    bool? fetchingProjects,
    bool? fetchingCollectors,
    bool? isOffline,
    bool? isSyncing,
    double? syncProgress,
    int? totalToSync,
    int? syncedSoFar,
    int? pendingSyncCount,
    bool? invitationLoading,
    List<Project>? projects,
    Project? selectedProject,
    List<Map<String, dynamic>>? collectors,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      fetchingProjects: fetchingProjects ?? this.fetchingProjects,
      fetchingCollectors: fetchingCollectors ?? this.fetchingCollectors,
      isOffline: isOffline ?? this.isOffline,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
      totalToSync: totalToSync ?? this.totalToSync,
      syncedSoFar: syncedSoFar ?? this.syncedSoFar,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      invitationLoading: invitationLoading ?? this.invitationLoading,
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      collectors: collectors ?? this.collectors,
    );
  }
}