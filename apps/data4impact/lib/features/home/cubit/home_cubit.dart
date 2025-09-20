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
    required this.connectivity,
  }) : super(const HomeState()) {
    _startPeriodicSync();
    _setupConnectivityListener();
  }

  final FlutterSecureStorage secureStorage;
  final ProjectService projectService;
  final SegmentService segmentService;
  final StudyService studyService;
  final FileUploadService fileUploadService;
  final Connectivity connectivity;
  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        // Internet connection restored, try to sync
        await _checkAndSyncOfflineData();
      }
    });
  }

  // Start periodic sync every 30 seconds
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkAndSyncOfflineData();
    });
  }

  // Check and sync offline data
  Future<void> _checkAndSyncOfflineData() async {
    final isConnected = await _isConnected;

    if (!isConnected) {
      return; // No internet, no sync
    }

    try {
      // Update pending sync count
      final pendingCount = await _getPendingSyncCount();
      emit(state.copyWith(pendingSyncCount: pendingCount));

      if (pendingCount > 0) {
        print('Found $pendingCount offline responses, attempting sync...');
        await _syncAllOfflineAnswers();
      }
    } catch (e) {
      print('Error checking for offline data: $e');
    }
  }

  // Get count of pending sync items
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

  // Sync all offline answers
  Future<void> _syncAllOfflineAnswers() async {
    if (state.isSyncing) return;

    emit(state.copyWith(
      isSyncing: true,
      syncProgress: 0.0,
      totalToSync: 0,
      syncedSoFar: 0,
    ));


    emit(state.copyWith(isSyncing: true));

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

      // Update pending count after sync
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

  // Sync offline answers for a specific study
  Future<int> _syncStudyOfflineAnswers(String studyId) async {
    int syncedCount = 0;

    try {
      final offlineAnswers = await OfflineModeDataRepo().getOfflineAnswers(studyId);

      if (offlineAnswers.isEmpty) {
        return 0;
      }

      // Update total to sync
      emit(state.copyWith(
        totalToSync: state.totalToSync + offlineAnswers.length,
      ));

      final List<int> successfulIndices = [];

      for (int i = 0; i < offlineAnswers.length; i++) {
        final answerData = Map<String, dynamic>.from(offlineAnswers[i]);

        try {
          // Handle audio file upload if present
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

          // Submit the answer
          final response = await studyService.submitSurveyResponse(
            studyId: studyId,
            responseData: answerData,
          );

          successfulIndices.add(i);
          syncedCount++;

          // Update progress
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

      // Remove successfully synced answers
      if (successfulIndices.isNotEmpty) {
        await _removeSyncedAnswers(studyId, successfulIndices);
      }

    } catch (e) {
      print('Error syncing offline answers for study $studyId: $e');
    }

    return syncedCount;
  }

  // Upload audio file during sync using FileUploadService
  Future<String?> _uploadAudioFileForSync(String filePath, String studyId) async {
    try {
      final result = await fileUploadService.uploadAudioFile(studyId, filePath);

      // Assuming the response contains a 'filename' field with the URL
      return result['filename'] as String?;
    } catch (e) {
      print('Failed to upload audio during sync: $e');
      return null;
    }
  }

  // Remove synced answers from offline storage
  Future<void> _removeSyncedAnswers(String studyId, List<int> indices) async {
    try {
      final offlineAnswers = await OfflineModeDataRepo().getOfflineAnswers(studyId);

      // Sort indices in descending order to avoid index issues when removing
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

  // Manual sync trigger (can be called from UI)
  Future<void> manualSync() async {
    final isConnected = await _isConnected;

    if (!isConnected) {
      ToastService.showWarningToast(message: 'No internet connection available');
      return;
    }

    await _checkAndSyncOfflineData();
  }

  // Check if there are pending offline answers
  Future<bool> hasPendingOfflineAnswers() async {
    final count = await _getPendingSyncCount();
    return count > 0;
  }

  Future<void> logout(BuildContext context) async {
    await secureStorage.delete(key: 'session_cookie');
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

    if (isConnected) {
      try {
        final response = await projectService.getAllProjects();

        final projects = response.map((json) => Project.fromMap(json)).toList();

        await OfflineModeDataRepo().saveAllProjects(projects);

        emit(
          state.copyWith(
            isLoading: false,
            projects: projects,
            selectedProject: projects.isNotEmpty ? projects.first : null,
            isOffline: false,
          ),
        );

        // Also check for offline data to sync after fetching projects
        await _checkAndSyncOfflineData();

      } catch (e) {
        final projects = await OfflineModeDataRepo().getSavedAllProjects();
        emit(
          state.copyWith(
            isLoading: false,
            projects: projects,
            selectedProject: projects.isNotEmpty ? projects.first : null,
            isOffline: true,
          ),
        );
      }
    } else {
      final projects = await OfflineModeDataRepo().getSavedAllProjects();
      emit(
        state.copyWith(
          isLoading: false,
          projects: projects,
          selectedProject: projects.isNotEmpty ? projects.first : null,
          isOffline: true,
        ),
      );
    }
  }

  // Check internet connectivity
  Future<bool> get _isConnected async {
    try {
      final result = await connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false; // Assume offline if connectivity check fails
    }
  }

  // Select a project
  void selectProject(Project project) {
    emit(state.copyWith(selectedProject: project));
  }

  // Refresh data (pull-to-refresh)
  Future<void> refreshData() async {
    final bool isOnline = await _isConnected;
    if (isOnline) {
      await fetchAllProjects();
    } else {
      ToastService.showInfoToast(message: 'No internet connection available');
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