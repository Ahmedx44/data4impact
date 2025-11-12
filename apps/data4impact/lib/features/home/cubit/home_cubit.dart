import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:data4impact/core/service/api_service/project_service.dart';
import 'package:data4impact/core/service/api_service/segment_service.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/core/service/api_service/file_upload_service.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/internt_connection_monitor.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/join_with_link/page/accept_invitation_view.dart';
import 'package:data4impact/features/login/page/login_page.dart';
import 'package:data4impact/repository/offline_mode_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.secureStorage,
    required this.projectService,
    required this.segmentService,
    required this.studyService,
    required this.fileUploadService,
    required this.authService,
    required this.connectivity,
  }) : super(const HomeState()) {
    _startPeriodicSync();
    _setupConnectivityListener();
    _initializeCurrentProject();
  }

  final FlutterSecureStorage secureStorage;
  final ProjectService projectService;
  final SegmentService segmentService;
  final StudyService studyService;
  final FileUploadService fileUploadService;
  final AuthService authService;
  final Connectivity connectivity;
  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }

  // Initialize current project from storage
  Future<void> _initializeCurrentProject() async {
    final currentProjectId = await authService.getCurrentProjectId();
    if (currentProjectId != null && state.projects.isNotEmpty) {
      final project = state.projects.firstWhere(
            (p) => p.id == currentProjectId,
        orElse: () => state.projects.first,
      );
      emit(state.copyWith(selectedProject: project));
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await _checkAndSyncOfflineData();
      }
    });
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkAndSyncOfflineData();
    });
  }

  Future<void> _checkAndSyncOfflineData() async {
    final isConnected = await _isConnected;

    // Update offline status based on current connectivity
    if (state.isOffline != !isConnected) {
      emit(state.copyWith(isOffline: !isConnected));
    }

    if (!isConnected) return;

    try {
      final pendingCount = await _getPendingSyncCount();
      emit(state.copyWith(pendingSyncCount: pendingCount));

      if (pendingCount > 0) {
        await _syncAllOfflineAnswers();
      }
    } catch (e) {
    }
  }

  Future<int> _getPendingSyncCount() async {
    try {
      final offlineAnswersBox = await Hive.openBox('offline_answers_box');
      int totalCount = 0;

      final keys = offlineAnswersBox.keys;
      for (final key in keys) {
        if (key.toString().startsWith('offline_answers_key_')) {
          final answersJson = offlineAnswersBox.get(key);
          if (answersJson != null && answersJson.toString().isNotEmpty) {
            final List<dynamic> decoded = jsonDecode(answersJson.toString()) as List;
            totalCount += decoded.length;
          }
        }
      }
      return totalCount;
    } catch (e) {
      print('Error getting pending sync count: $e');
      return 0;
    }
  }

  Future<void> _syncAllOfflineAnswers() async {
    if (state.isSyncing) return;

    emit(state.copyWith(
      isSyncing: true,
      syncProgress: 0.0,
      totalToSync: 0,
      syncedSoFar: 0,
    ));

    try {
      final offlineAnswersBox = await Hive.openBox('offline_answers_box');
      final keys = offlineAnswersBox.keys;

      int totalSynced = 0;

      for (final key in keys) {
        if (key.toString().startsWith('offline_answers_key_')) {
          final studyId = key.toString().replaceFirst('offline_answers_key_', '');
          final syncedCount = await _syncStudyOfflineAnswers(studyId);
          totalSynced += syncedCount;
        }
      }

      final newPendingCount = await _getPendingSyncCount();
      emit(state.copyWith(pendingSyncCount: newPendingCount));

      if (totalSynced > 0) {
        ToastService.showSuccessToast(
            message: 'Synced $totalSynced offline responses'
        );
      }

    } catch (e) {
      print('Error syncing all offline answers: $e');
      ToastService.showErrorToast(message: 'Sync failed: ${e.toString()}');
    } finally {
      emit(state.copyWith(isSyncing: false));
    }
  }

  Future<int> _syncStudyOfflineAnswers(String studyId) async {
    int syncedCount = 0;

    try {
      final offlineAnswers = await OfflineModeDataRepo().getOfflineAnswers(studyId);

      if (offlineAnswers.isEmpty) {
        return 0;
      }

      emit(state.copyWith(
        totalToSync: state.totalToSync + offlineAnswers.length,
      ));

      final List<int> successfulIndices = [];

      for (int i = 0; i < offlineAnswers.length; i++) {
        final answerData = Map<String, dynamic>.from(offlineAnswers[i]);

        try {
          if (answerData.containsKey('audioFilePath')) {
            final audioFilePath = answerData['audioFilePath'] as String;
            final audioUrl = await _uploadAudioFileForSync(audioFilePath, studyId);

            if (audioUrl != null) {
              answerData['audioUrl'] = audioUrl;
              answerData.remove('audioFilePath');
            } else {
              continue;
            }
          }

          final response = await studyService.submitSurveyResponse(
            studyId: studyId,
            responseData: answerData as List,
          );

          successfulIndices.add(i);
          syncedCount++;

          emit(state.copyWith(
            syncedSoFar: state.syncedSoFar + 1,
            syncProgress: state.totalToSync > 0
                ? state.syncedSoFar / state.totalToSync
                : 0.0,
          ));

        } catch (e) {
          print('Failed to sync offline answer $i: $e');
        }
      }

      if (successfulIndices.isNotEmpty) {
        await _removeSyncedAnswers(studyId, successfulIndices);
      }

    } catch (e) {
      print('Error syncing offline answers for study $studyId: $e');
    }

    return syncedCount;
  }

  Future<String?> _uploadAudioFileForSync(String filePath, String studyId) async {
    try {
      final result = await fileUploadService.uploadAudioFile(studyId, filePath);
      return result['filename'] as String?;
    } catch (e) {
      print('Failed to upload audio during sync: $e');
      return null;
    }
  }

  Future<void> _removeSyncedAnswers(String studyId, List<int> indices) async {
    try {
      final offlineAnswers = await OfflineModeDataRepo().getOfflineAnswers(studyId);
      indices.sort((a, b) => b.compareTo(a));

      for (final index in indices) {
        if (index >= 0 && index < offlineAnswers.length) {
          offlineAnswers.removeAt(index);
        }
      }

      final hiveBox = await Hive.openBox('offline_answers_box');
      if (offlineAnswers.isEmpty) {
        await hiveBox.delete('offline_answers_key_$studyId');
      } else {
        await hiveBox.put('offline_answers_key_$studyId', jsonEncode(offlineAnswers));
      }
    } catch (e) {
      print('Error removing synced answers: $e');
    }
  }

  Future<void> manualSync() async {
    final isConnected = await _isConnected;

    if (!isConnected) {
      ToastService.showWarningToast(message: 'No internet connection available');
      return;
    }

    await _checkAndSyncOfflineData();
  }

  Future<bool> hasPendingOfflineAnswers() async {
    final count = await _getPendingSyncCount();
    return count > 0;
  }

  Future<void> logout(BuildContext context) async {
    await secureStorage.delete(key: 'session_cookie');
    await secureStorage.delete(key: 'current_project_id');
    ToastService.showSuccessToast(message: 'Logout successful');
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<Widget>(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  Future<void> fetchAllProjects() async {
    emit(state.copyWith(isLoading: true));

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    // Always update the offline status based on current connectivity
    if (isConnected) {
      try {
        final response = await projectService.getAllProjects();

        final projects = response.map((json) {
          return Project.fromMap(json);
        }).toList();

        await switchProject(projects[0]);

        await OfflineModeDataRepo().saveAllProjects(projects);

        // Get current project ID and set selected project
        final currentProjectId = await authService.getCurrentProjectId();
        Project? selectedProject;

        if (currentProjectId != null && projects.isNotEmpty) {
          selectedProject = projects.firstWhere(
                (p) => p.id == currentProjectId,
            orElse: () => projects.first,
          );
        } else if (projects.isNotEmpty) {
          selectedProject = projects.first;
        }

        emit(
          state.copyWith(
            isLoading: false,
            projects: projects,
            selectedProject: selectedProject,
            isOffline: false, // Explicitly set to false when online
          ),
        );

        await _checkAndSyncOfflineData();

      } catch (e) {
        // Even if API fails, we're technically online
        final projects = await OfflineModeDataRepo().getSavedAllProjects();
        final currentProjectId = await authService.getCurrentProjectId();
        Project? selectedProject;

        if (currentProjectId != null && projects.isNotEmpty) {
          selectedProject = projects.firstWhere(
                (p) => p.id == currentProjectId,
          );
        }

        emit(
          state.copyWith(
            isLoading: false,
            projects: projects,
            selectedProject: selectedProject,
            isOffline: false, // Still set to false because we have connectivity
          ),
        );
      }
    } else {
      final projects = await OfflineModeDataRepo().getSavedAllProjects();
      final currentProjectId = await authService.getCurrentProjectId();
      Project? selectedProject;

      if (currentProjectId != null && projects.isNotEmpty) {
        selectedProject = projects.firstWhere(
              (p) => p.id == currentProjectId,
        );
      }

      emit(
        state.copyWith(
          isLoading: false,
          projects: projects,
          selectedProject: selectedProject,
          isOffline: true, // Only set to true when definitely offline
        ),
      );
    }
  }

  Future<void> switchProject(Project project) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Call API to switch project on server
      await authService.switchProject(project.id);

      // Update selected project in state
      emit(state.copyWith(
        selectedProject: project,
        isLoading: false,
      ));

      ToastService.showSuccessToast(message: 'Switched to ${project.slug}');

    } catch (e) {
      emit(state.copyWith(isLoading: false));
      ToastService.showErrorToast(message: 'Failed to switch project: ${e.toString()}');
      rethrow;
    }
  }

  void selectProject(Project project) {
    emit(state.copyWith(selectedProject: project));
  }

  Future<bool> get _isConnected async {
    try {
      final result = await connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshData() async {
    final bool isOnline = await _isConnected;

    // Update offline status immediately
    emit(state.copyWith(isOffline: !isOnline));

    if (isOnline) {
      await fetchAllProjects();
    } else {
      ToastService.showInfoToast(message: 'No internet connection available');
      // Even when offline, we can refresh from local storage
      final projects = await OfflineModeDataRepo().getSavedAllProjects();
      final currentProjectId = await authService.getCurrentProjectId();
      Project? selectedProject;

      if (currentProjectId != null && projects.isNotEmpty) {
        selectedProject = projects.firstWhere(
              (p) => p.id == currentProjectId,
        );
      }

      emit(
        state.copyWith(
          projects: projects,
          selectedProject: selectedProject,
          isOffline: true,
        ),
      );
    }
  }

  Future<void> joinSegmentViaLink(String url, BuildContext context) async {
    emit(state.copyWith(invitationLoading: true));

    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      final projectSlug = pathSegments[0];
      final segmentId = pathSegments[2];

      final response = await segmentService.getSegmentById(
        segmentId: segmentId,
        projectSlug: projectSlug,
      );

      emit(state.copyWith(invitationLoading: false));

      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AcceptInvitationView(
              segmentData: response,
              homeState: state,
              projectSlug: projectSlug,
            ),
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(invitationLoading: false));
      if (context.mounted) {
        ToastService.showErrorToast(
          context: context,
          message: 'Failed to join segment: ${e.toString()}',
        );
      }
      rethrow;
    }
  }
}