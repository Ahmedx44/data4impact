import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'study_detail_state.dart';

class StudyDetailCubit extends Cubit<StudyDetailState> {
  final StudyService studyService;

  StudyDetailCubit({required this.studyService}) : super(StudyDetailInitial());

  Future<void> fetchStudyDetails(String studyId) async {
    emit(StudyDetailLoading());
    try {
      final studyDetails = await studyService.getStudyDetails(studyId);
      emit(StudyDetailLoaded(studyDetails: studyDetails));
    } catch (e) {
      emit(StudyDetailError('Failed to load study details: ${e.toString()}'));
      rethrow;
    }
  }
}