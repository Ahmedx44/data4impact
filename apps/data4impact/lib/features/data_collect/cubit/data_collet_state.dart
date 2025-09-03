import 'package:data4impact/core/service/api_service/Model/study.dart';

class DataCollectState {
  final Study? study;
  final bool isLoading;
  final String? error;
  final int currentQuestionIndex;
  final Map<String, dynamic> answers;
  final Set<String> requiredQuestions;
  final Set<String> skipQuestions; // New field for skipped questions
  final String? jumpTarget;
  final List<int> navigationHistory;
  final Map<int, int> logicJumps;

  const DataCollectState({
    this.study,
    this.isLoading = false,
    this.error,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.requiredQuestions = const {},
    this.skipQuestions = const {}, // Initialize the new field
    this.jumpTarget,
    this.navigationHistory = const [],
    this.logicJumps = const {},
  });

  DataCollectState copyWith({
    Study? study,
    bool? isLoading,
    String? error,
    int? currentQuestionIndex,
    Map<String, dynamic>? answers,
    Set<String>? requiredQuestions,
    Set<String>? skipQuestions, // Add skipQuestions to copyWith
    String? jumpTarget,
    List<int>? navigationHistory,
    Map<int, int>? logicJumps,
  }) {
    return DataCollectState(
      study: study ?? this.study,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      requiredQuestions: requiredQuestions ?? this.requiredQuestions,
      skipQuestions: skipQuestions ?? this.skipQuestions, // Handle skipQuestions
      jumpTarget: jumpTarget ?? this.jumpTarget,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      logicJumps: logicJumps ?? this.logicJumps,
    );
  }
}