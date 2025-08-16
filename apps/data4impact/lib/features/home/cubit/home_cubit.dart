import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:data4impact/core/service/api_service/project_service.dart';
import 'package:data4impact/core/service/api_service/segment_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/join_with_link/page/accept_invitation_view.dart';
import 'package:data4impact/features/login/page/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.secureStorage,
    required this.projectService,
    required this.segmentService,
  }) : super(HomeState());

  final FlutterSecureStorage secureStorage;
  final ProjectService projectService;
  final SegmentService segmentService;

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

    try {
      final response = await projectService.getAllProjects();

      final projects = response.map((json) => Project.fromMap(json)).toList();

      emit(
        state.copyWith(
          isLoading: false,
          projects: projects,
          selectedProject: projects.isNotEmpty ? projects.first : null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
      ));
      ToastService.showErrorToast(message: 'Failed to fetch projects');
    }
  }

  Future<void> joinSegmentViaLink(String url, BuildContext context) async {
    emit(state.copyWith(invitationLoading: true));

    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length < 4 || pathSegments[0] != 'imf') {
        throw Exception('Invalid invitation link format');
      }

      final projectSlug = pathSegments[1];
      final segmentId = pathSegments[3];

      final response = await segmentService.getSegmentById(
        segmentId: segmentId,
        projectSlug: projectSlug,
      );

      emit(state.copyWith(invitationLoading: false));

      // Use Navigator.push after ensuring the context is still valid
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AcceptInvitationView(segmentData: response),
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
