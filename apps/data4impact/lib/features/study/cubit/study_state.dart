import 'package:equatable/equatable.dart';

class StudyState extends Equatable {
  final List<Map<String, dynamic>> studies;
  final bool isLoading;
  final String? errorMessage;
  final Exception? errorDetails;

  const StudyState({
    this.studies = const [],
    this.isLoading = false,
    this.errorMessage,
    this.errorDetails,
  });

  StudyState copyWith({
    List<Map<String, dynamic>>? studies,
    bool? isLoading,
    String? errorMessage,
    Exception? errorDetails,
  }) {
    return StudyState(
      studies: studies ?? this.studies,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      errorDetails: errorDetails ?? this.errorDetails,
    );
  }

  StudyState loading() {
    return copyWith(
      isLoading: true,
      errorMessage: null,
      errorDetails: null,
    );
  }

  StudyState loaded(List<Map<String, dynamic>> studies) {
    print('🎯 StudyState.loaded() called with ${studies.length} studies');
    return copyWith(
      studies: studies,
      isLoading: false,
      errorMessage: null,
      errorDetails: null,
    );
  }

  StudyState error({
    required String errorMessage,
    required Exception errorDetails,
  }) {
    return copyWith(
      isLoading: false,
      errorMessage: errorMessage,
      errorDetails: errorDetails,
    );
  }

  @override
  List<Object?> get props => [
    studies,
    isLoading,
    errorMessage,
    errorDetails?.toString(),
  ];

  bool get hasError => errorMessage != null;
  bool get isInitial => !isLoading && studies.isEmpty && !hasError;
}