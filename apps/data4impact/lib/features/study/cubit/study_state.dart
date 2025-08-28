import 'package:equatable/equatable.dart';

abstract class StudyState extends Equatable {
  const StudyState();

  @override
  List<Object> get props => [];
}

class StudyInitial extends StudyState {}

class StudyLoading extends StudyState {}

class StudyLoaded extends StudyState {
  final List<Map<String, dynamic>> studies;

  const StudyLoaded(this.studies);

  @override
  List<Object> get props => [studies];
}

class StudyError extends StudyState {
  final String message;

  const StudyError(this.message);

  @override
  List<Object> get props => [message];
}