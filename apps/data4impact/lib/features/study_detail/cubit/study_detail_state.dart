import 'package:equatable/equatable.dart';

abstract class StudyDetailState extends Equatable {
  const StudyDetailState();

  @override
  List<Object> get props => [];
}

class StudyDetailInitial extends StudyDetailState {}

class StudyDetailLoading extends StudyDetailState {}

class StudyDetailLoaded extends StudyDetailState {
  final Map<String, dynamic> studyDetails;

  const StudyDetailLoaded({required this.studyDetails});

  @override
  List<Object> get props => [studyDetails];
}

class StudyDetailError extends StudyDetailState {
  final String message;

  const StudyDetailError(this.message);

  @override
  List<Object> get props => [message];
}