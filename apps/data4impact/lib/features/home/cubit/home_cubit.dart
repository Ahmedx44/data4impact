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
import 'package:data4impact/core/service/api_service/home_service.dart';
import 'package:data4impact/core/service/app_logger.dart';
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
    required this.homeService,
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
  final HomeService homeService;
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
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen((result) async {
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
    } catch (e) {}
  }

  Future<int> _getPendingSyncCount() async {
    try {
      int totalCount = 0;
      final offlineAnswersBox = await Hive.openBox('offline_answers_box');
      final keys = offlineAnswersBox.keys.toList();

      for (final key in keys) {
        if (key.toString().startsWith('offline_answers_key_')) {
          final studyId = key.toString().replaceFirst('offline_answers_key_', '');
          final offlineAnswers = await OfflineModeDataRepo().getOfflineAnswers(studyId);
          totalCount += offlineAnswers.length;
        }
      }

      return totalCount;
    } catch (e) {
      AppLogger.logError('Error getting pending sync count: $e');
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
      final keys = offlineAnswersBox.keys.toList();

      // First, count total items to sync
      int totalItems = 0;
      for (final key in keys) {
        if (key.toString().startsWith('offline_answers_key_')) {
          final studyId = key.toString().replaceFirst('offline_answers_key_', '');
          final offlineAnswers = await OfflineModeDataRepo().getOfflineAnswers(studyId);
          totalItems += offlineAnswers.length;
        }
      }

      emit(state.copyWith(totalToSync: totalItems));

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
            message: 'Successfully synced $totalSynced offline responses'
        );
      } else if (totalItems > 0) {
        ToastService.showInfoToast(
            message: 'No responses synced. Please check your connection'
        );
      }
    } catch (e) {
      AppLogger.logError('Sync failed: ${e.toString()}');
      ToastService.showErrorToast(message: 'Sync failed: ${e.toString()}');
    } finally {
      emit(state.copyWith(
        isSyncing: false,
        syncProgress: 1.0,
      ));
    }
  }

  Future<int> _syncStudyOfflineAnswers(String studyId) async {
    int syncedCount = 0;

    try {
      final offlineAnswers = await OfflineModeDataRepo().getOfflineAnswers(studyId);

      if (offlineAnswers.isEmpty) {
        AppLogger.logInfo('No offline answers to sync for study: $studyId');
        return 0;
      }

      AppLogger.logInfo('Syncing ${offlineAnswers.length} offline answers for study: $studyId');

      final List<int> successfulIndices = [];

      for (int i = 0; i < offlineAnswers.length; i++) {
        try {
          // Get the complete response object (not just the data array)
          final responseObject = Map<String, dynamic>.from(offlineAnswers[i]);

          AppLogger.logInfo('Processing offline answer $i: ${jsonEncode(responseObject)}');

          // Handle audio file upload if present
          if (responseObject.containsKey('audioFilePath')) {
            final audioFilePath = responseObject['audioFilePath'] as String;
            final audioUrl = await _uploadAudioFileForSync(audioFilePath, studyId);

            if (audioUrl != null) {
              responseObject['audioUrl'] = audioUrl;
              responseObject.remove('audioFilePath');
            } else {
              AppLogger.logWarning('Audio upload failed for answer $i, skipping audio');
              responseObject.remove('audioFilePath');
            }
          }

          // Validate the response structure
          if (!responseObject.containsKey('data') ||
              responseObject['data'] is! List ||
              (responseObject['data'] as List).isEmpty) {
            AppLogger.logWarning('Invalid response structure for answer $i, skipping');
            continue;
          }

          // Submit the complete response object
          await studyService.submitSurveyResponse(
            studyId: studyId,
            responseData: [responseObject], // Wrap in array as API expects
          );

          successfulIndices.add(i);
          syncedCount++;

          AppLogger.logInfo('Successfully synced offline answer $i');

          // Update progress
          emit(state.copyWith(
            syncedSoFar: state.syncedSoFar + 1,
            syncProgress: state.totalToSync > 0
                ? state.syncedSoFar / state.totalToSync
                : 0.0,
          ));

        } catch (e) {
          AppLogger.logError('Failed to sync offline answer $i: $e');
          // Continue with next answer instead of stopping
          continue;
        }
      }

      // Remove successfully synced answers
      if (successfulIndices.isNotEmpty) {
        await _removeSyncedAnswers(studyId, successfulIndices);
        AppLogger.logInfo('Removed ${successfulIndices.length} synced answers for study: $studyId');
      }

    } catch (e) {
      AppLogger.logError('Error in _syncStudyOfflineAnswers for study $studyId: $e');
    }

    return syncedCount;
  }

  Future<String?> _uploadAudioFileForSync(String audioFilePath, String studyId) async {
    try {
      if (!await File(audioFilePath).exists()) {
        AppLogger.logWarning('Audio file not found: $audioFilePath');
        return null;
      }

      final result = await fileUploadService.uploadAudioFile(studyId, audioFilePath);
      final audioUrl = result['filename'] as String?;

      if (audioUrl != null) {
        // Delete the local file after successful upload
        try {
          await File(audioFilePath).delete();
          AppLogger.logInfo('Deleted local audio file after successful upload: $audioFilePath');
        } catch (e) {
          AppLogger.logWarning('Failed to delete local audio file: $e');
        }
      }

      return audioUrl;
    } catch (e) {
      AppLogger.logError('Audio upload failed for file $audioFilePath: $e');
      return null;
    }
  }

  Future<void> _removeSyncedAnswers(String studyId, List<int> indicesToRemove) async {
    try {
      final offlineAnswers = await OfflineModeDataRepo().getOfflineAnswers(studyId);

      // Sort indices in descending order to avoid index shifting issues
      indicesToRemove.sort((a, b) => b.compareTo(a));

      for (final index in indicesToRemove) {
        if (index >= 0 && index < offlineAnswers.length) {
          await OfflineModeDataRepo().removeOfflineAnswer(studyId, index);
        }
      }

      AppLogger.logInfo('Removed ${indicesToRemove.length} synced answers');
    } catch (e) {
      AppLogger.logError('Error removing synced answers: $e');
      throw e;
    }
  }

  Future<void> manualSync() async {
    final isConnected = await _isConnected;

    if (!isConnected) {
      ToastService.showWarningToast(
          message: 'No internet connection available');
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
    emit(state.copyWith(fetchingProjects:true,isLoading: true));

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    if (isConnected) {
      try {
        final response = await projectService.getAllProjects();

        if (response.isEmpty) {
          emit(
            state.copyWith(
              isLoading: false,
              fetchingProjects:false,
              projects: [],
              selectedProject: null,
              isOffline: false,
            ),
          );
          return;
        }

        final projects = response.map((json) {
          return Project.fromMap(json);
        }).toList();

        if (projects.isNotEmpty) {
          await switchProject(projects[0]);
          await OfflineModeDataRepo().saveAllProjects(projects);
        }

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
            fetchingProjects:false,
            projects: projects,
            selectedProject: selectedProject,
            isOffline: false,
          ),
        );

        await _checkAndSyncOfflineData();
      } catch (e) {
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
            fetchingProjects:false,
            projects: projects,
            selectedProject: selectedProject,
            isOffline: false,
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
          fetchingProjects:false,
          projects: projects,
          selectedProject: selectedProject,
          isOffline: true,
        ),
      );
    }
  }

  Future<void> fetchMyCollectors() async {
    if (state.selectedProject == null) {
      return;
    }

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    emit(state.copyWith(fetchingCollectors: true));

    try {
      if (isConnected) {
        // Online mode - fetch from API and save to local storage
        final collectors = await homeService.getMyCollectors(
          project: state.selectedProject!.id,
        );

        // Save to offline storage
        await OfflineModeDataRepo().saveCollectors(
          state.selectedProject!.id,
          collectors,
        );

        emit(state.copyWith(
          collectors: collectors,
          fetchingCollectors: false,
        ));
      } else {
        // Offline mode - load from local storage
        final savedCollectors = await OfflineModeDataRepo().getSavedCollectors(
          state.selectedProject!.id,
        );

        emit(state.copyWith(
          collectors: savedCollectors as List<Map<String,dynamic>>,
          fetchingCollectors: false,
          isOffline: true,
        ));

        if (savedCollectors.isEmpty) {
          ToastService.showWarningToast(
            message: 'No cached collectors data available offline',
          );
        } else {
          ToastService.showInfoToast(
            message: 'Showing cached collectors data',
          );
        }
      }
    } catch (e) {
      // If online fetch fails, try to load from cache
      if (isConnected) {
        try {
          final savedCollectors = await OfflineModeDataRepo().getSavedCollectors(
            state.selectedProject!.id,
          );

          emit(state.copyWith(
            collectors: savedCollectors as List<Map<String,dynamic>>,
            fetchingCollectors: false,
          ));

          ToastService.showWarningToast(
            message: 'Using cached data due to network error',
          );
        } catch (cacheError) {
          // Both online and cache failed
          emit(state.copyWith(
            fetchingCollectors: false,
          ));
          ToastService.showErrorToast(message: 'Failed to fetch collectors');
        }
      } else {
        // Offline mode and cache failed
        emit(state.copyWith(
          fetchingCollectors: false,
        ));
        ToastService.showErrorToast(message: 'No cached collectors data available');
      }
    }
  }

  Future<void> switchProject(Project project) async {
    emit(state.copyWith(isLoading: true));
    try {
      await authService.switchProject(project.id);

      emit(
        state.copyWith(
          selectedProject: project,
          isLoading: false,
        ),
      );

      await fetchMyCollectors();
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      ToastService.showErrorToast(message: 'Failed to switch project}');
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

    emit(state.copyWith(isOffline: !isOnline));

    if (isOnline) {
      await fetchAllProjects();
      await fetchMyCollectors();
    } else {
      ToastService.showInfoToast(message: 'No internet connection available');

      // Load projects from cache
      final projects = await OfflineModeDataRepo().getSavedAllProjects();
      final currentProjectId = await authService.getCurrentProjectId();
      Project? selectedProject;

      if (currentProjectId != null && projects.isNotEmpty) {
        selectedProject = projects.firstWhere(
              (p) => p.id == currentProjectId,
        );
      }

      // Load collectors from cache if we have a selected project
      List<dynamic> collectors = [];
      if (selectedProject != null) {
        collectors = await OfflineModeDataRepo().getSavedCollectors(selectedProject.id);
      }

      emit(
        state.copyWith(
          projects: projects,
          selectedProject: selectedProject,
          collectors: collectors as List<Map<String,dynamic>>,
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