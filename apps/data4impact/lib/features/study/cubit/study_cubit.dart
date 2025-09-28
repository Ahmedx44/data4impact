import 'dart:convert';

import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/core/service/internt_connection_monitor.dart';
import 'package:data4impact/repository/offline_mode_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  final StudyService studyService;
  final String? projectSlug;
  List<Map<String, dynamic>> _studies = [];

  StudyCubit({
    required this.studyService,
    this.projectSlug,
  }) : super(StudyInitial());

  List<Map<String, dynamic>> get studies => _studies;

  Map<String, dynamic>? getStudyById(String studyId) {
    try {
      return _studies.firstWhere((study) => study['_id'] == studyId);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchStudies(String projectSlug) async {
    emit(StudyLoading());

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    if (isConnected) {
      try {
        _studies = await studyService.getStudies(projectSlug);
        final studiesJson = jsonEncode(_studies);
        await OfflineModeDataRepo().saveAllStudys(studiesJson);
        emit(StudyLoaded(_studies));
      } catch (e) {
        final savedStudies = await OfflineModeDataRepo().getSavedAllStudys();
        _studies = savedStudies;
        emit(StudyLoaded(_studies));
      }
    } else {
      try {
        final savedStudies = await OfflineModeDataRepo().getSavedAllStudys();
        _studies = savedStudies;
        emit(StudyLoaded(_studies));
      } catch (e) {
        emit(StudyError(errorMessage: 'Failed to load offline data', errorDetails: Exception(e.toString())));
      }
    }
  }
}