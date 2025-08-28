import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/Model/api_question.dart';
import 'package:data4impact/core/service/api_service/Model/study.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:meta/meta.dart';



class DataCollectCubit extends Cubit<DataCollectState> {
  final StudyService studyService;

  DataCollectCubit({required this.studyService}) : super(const DataCollectState());

  Future<void> getStudyQuestions(String studyId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final data = await studyService.getStudyQuestions(studyId);
      final study = Study.fromJson(data);
      emit(state.copyWith(
        study: study,
        isLoading: false,
        currentQuestionIndex: 0,
        answers: {},
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load study: $e',
      ));
    }
  }

  void updateAnswer(String questionId, dynamic value) {
    final newAnswers = Map<String, dynamic>.from(state.answers);
    newAnswers[questionId] = value;
    emit(state.copyWith(answers: newAnswers));
  }

  void nextQuestion() {
    final nextIndex = state.currentQuestionIndex + 1;
    if (nextIndex < (state.study?.questions.length ?? 0)) {
      emit(state.copyWith(currentQuestionIndex: nextIndex));
    } else {
      // Submit survey
      submitSurvey();
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  void submitSurvey() {
    // Handle survey submission
    print('Survey answers: ${state.answers}');
    // Here you would typically send the answers to your API
  }

  bool canProceed(ApiQuestion question) {
    final answer = state.answers[question.id];
    if (!question.required) return true;

    switch (question.type) {
      case ApiQuestionType.multipleChoiceSingle:
      case ApiQuestionType.rating:
      case ApiQuestionType.date:
        return answer != null;
      case ApiQuestionType.multipleChoiceMulti:
        return answer != null && (answer as List).isNotEmpty;
      case ApiQuestionType.openText:
        return answer != null && (answer as String).trim().isNotEmpty;
      case ApiQuestionType.ranking:
        return answer != null && (answer as List).length == (question.choices?.length ?? 0);
      case ApiQuestionType.matrix:
      // For matrix questions, we need all rows to have an answer
        if (answer == null || answer is! Map) return false;
        final rowIds = question.rows?.map((row) => row['id']).toList() ?? [];
        for (var rowId in rowIds) {
          if (answer[rowId] == null) return false;
        }
        return true;
      case ApiQuestionType.cascade:
      // For cascade questions, we need to have selected each level
        if (answer == null || answer is! List) return false;
        return answer.isNotEmpty;
      default:
        return true;
    }
  }
}