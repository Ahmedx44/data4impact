import 'dart:convert';

import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/core/service/internt_connection_monitor.dart';
import 'package:data4impact/repository/offline_mode_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  final StudyService studyService;
  final String? projectSlug;

  StudyCubit({
    required this.studyService,
    this.projectSlug,
  }) : super(const StudyState());

  List<Map<String, dynamic>> get studies => state.studies;

  Map<String, dynamic>? getStudyById(String studyId) {
    try {
      return state.studies.firstWhere((study) => study['_id'] == studyId);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchStudies(String projectSlug) async {
    emit(state.loading());

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    if (isConnected) {
      try {
        final studies = await studyService.getStudies(projectSlug);

        final studiesJson = jsonEncode(studies);
        await OfflineModeDataRepo().saveAllStudys(studiesJson);

        emit(state.loaded(studies));
      } catch (e) {
        try {
          final savedStudies = await OfflineModeDataRepo().getSavedAllStudys();
          emit(state.loaded(savedStudies));
        } catch (offlineError) {
          emit(state.error(
            errorMessage: 'Failed to load studies: ${e.toString()}',
            errorDetails: Exception(e.toString()),
          ));
        }
      }
    } else {
      // Offline mode
      try {
        final savedStudies = await OfflineModeDataRepo().getSavedAllStudys();
        emit(state.loaded(savedStudies));
      } catch (e) {
        emit(state.error(
          errorMessage: 'Failed to load offline data',
          errorDetails: Exception(e.toString()),
        ));
      }
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null, errorDetails: null));
  }
}
