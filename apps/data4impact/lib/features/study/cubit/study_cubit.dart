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

    print('🔄 fetchStudies called for project: $projectSlug');

    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
      checkInterval: const Duration(seconds: 5),
    );

    final isConnected = await connected.hasInternetConnection();

    if (isConnected) {
      try {
        print('🌐 Fetching studies online...');
        final studies = await studyService.getStudies(projectSlug);
        print('✅ Studies fetched successfully: ${studies.length} studies');
        print('📝 Studies data: ${studies.take(1).toList()}');

        final studiesJson = jsonEncode(studies);
        await OfflineModeDataRepo().saveAllStudys(studiesJson);

        print('🚀 Emitting loaded state with ${studies.length} studies');
        // FIX: Use loaded() method instead of copyWith()
        emit(state.loaded(studies));
        print('✅ State emitted successfully');
      } catch (e) {
        print('❌ Online fetch failed: $e');
        // Fallback to offline data on error
        try {
          print('📴 Trying offline fallback...');
          final savedStudies = await OfflineModeDataRepo().getSavedAllStudys();
          print('📱 Offline studies found: ${savedStudies.length}');
          emit(state.loaded(savedStudies));
        } catch (offlineError) {
          print('❌ Offline fallback also failed: $offlineError');
          emit(state.error(
            errorMessage: 'Failed to load studies: ${e.toString()}',
            errorDetails: Exception(e.toString()),
          ));
        }
      }
    } else {
      // Offline mode
      print('📴 Offline mode - loading from storage');
      try {
        final savedStudies = await OfflineModeDataRepo().getSavedAllStudys();
        print('📱 Offline studies loaded: ${savedStudies.length}');
        emit(state.loaded(savedStudies));
      } catch (e) {
        print('❌ Failed to load offline data: $e');
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
