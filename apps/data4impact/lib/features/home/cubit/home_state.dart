import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final String? message;
  final List<Project> projects;

  const HomeState({
    this.isLoading = false,
    this.message,
    this.projects = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? message,
    List<Project>? projects,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      projects: projects ?? this.projects,
    );
  }

  @override
  List<Object?> get props => [isLoading, message, projects];
}