import 'package:data4impact/core/service/api_service/Model/study.dart';

class DataCollectState {
  final Study? study;
  final bool isLoading;
  final String? error;
  final int currentQuestionIndex;
  final Map<String, dynamic> answers;
  final Set<String> requiredQuestions; // Track required questions from logic
  final String? jumpTarget; // Track where to jump next

  const DataCollectState({
    this.study,
    this.isLoading = false,
    this.error,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.requiredQuestions = const {},
    this.jumpTarget,
  });

  DataCollectState copyWith({
    Study? study,
    bool? isLoading,
    String? error,
    int? currentQuestionIndex,
    Map<String, dynamic>? answers,
    Set<String>? requiredQuestions,
    String? jumpTarget,
  }) {
    return DataCollectState(
      study: study ?? this.study,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      requiredQuestions: requiredQuestions ?? this.requiredQuestions,
      jumpTarget: jumpTarget ?? this.jumpTarget,
    );
  }
}