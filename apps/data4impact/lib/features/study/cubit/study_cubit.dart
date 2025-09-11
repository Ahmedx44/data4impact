import 'package:data4impact/core/service/api_service/study_service.dart';
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
    try {
      final studies = await studyService.getStudies(projectSlug ?? 'majlis-starategy');
      emit(StudyLoaded(studies));
    } catch (e) {
      // Provide more structured error information
      emit(StudyError(
        errorMessage: e.toString(),
        errorDetails: e is Exception ? e : Exception(e.toString()),
      ));
    }
  }
}