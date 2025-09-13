import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:data4impact/core/service/api_service/project_service.dart';
import 'package:data4impact/core/service/api_service/segment_service.dart';
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

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.secureStorage,
    required this.projectService,
    required this.segmentService,
    required this.connectivity,
  }) : super(const HomeState());

  final FlutterSecureStorage secureStorage;
  final ProjectService projectService;
  final SegmentService segmentService;
  final Connectivity connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
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
      } catch (e) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to fetch projects: $e',
          ),
        );
        ToastService.showErrorToast(message: 'Failed to fetch projects');
      }
    } else {
      print('reached here');
      final projects = await OfflineModeDataRepo().getSavedAllProjects();
      print('projectss: ${projects.first.title}');
      emit(
        state.copyWith(
          isLoading: false,
          projects: projects,
          selectedProject: projects.isNotEmpty ? projects.first : null,
          isOffline: true,
        ),
      );

      ToastService.showWarningToast(
          message: 'No internet connection available');
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
