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
  }) : super(StudyInitial()) {
    fetchStudies();
  }

  Future<void> fetchStudies() async {
    emit(StudyLoading());

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    if (isConnected) {
      try {
        final studies =
            await studyService.getStudies(projectSlug ?? 'majlis-starategy');

        final studiesJson = jsonEncode(studies);

        await OfflineModeDataRepo().saveAllStudys(studiesJson);

        emit(StudyLoaded(studies));
      } catch (e) {
        emit(
          StudyError(
            errorMessage: e.toString(),
            errorDetails: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    } else {
      try {
        final studys = await OfflineModeDataRepo().getSavedAllStudys();

        emit(StudyLoaded(studys));
      } catch (e) {}
    }
  }
}
