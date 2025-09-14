import 'package:data4impact/core/widget/api_error_widget.dart';
import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:data4impact/features/study/cubit/study_state.dart';
import 'package:data4impact/features/study/widget/study_card.dart';
import 'package:data4impact/features/study_detail/pages/study_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudyView extends StatefulWidget {
  final String projectSlug;

  const StudyView({super.key, required this.projectSlug});

  @override
  _StudyViewState createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildStudyViewContent();
  }

  Widget _buildStudyViewContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Material(
                color: colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                  splashFactory: NoSplash.splashFactory,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurface.withAlpha(255),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  tabs: const [
                    Tab(text: 'Active Study'),
                    Tab(text: 'Old Study'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveStudiesTab(),
                    _buildOldStudiesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveStudiesTab() {
    return BlocBuilder<StudyCubit, StudyState>(
      builder: (context, state) {
        if (state is StudyInitial || state is StudyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StudyError) {
          return ApiErrorWidget(
            errorMessage: _getUserFriendlyErrorMessage(state.errorMessage),
            errorDetails: state.errorDetails,
            onRetry: () => context.read<StudyCubit>().fetchStudies(),
          );
        } else if (state is StudyLoaded) {
          final activeStudies = state.studies.where((study) =>
              study['status'] == 'inProgress' || study['status'] == 'draft');

          if (activeStudies.isEmpty) {
            return _buildEmptyState('No active studies found');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeStudies.length,
            itemBuilder: (context, index) {
              final study = activeStudies.elementAt(index);
              return GestureDetector(
                child: StudyCard(
                  title: study['name'] as String,
                  description: study['description'] as String,
                  progress:
                      (study['responseCount']! / study['sampleSize']) as double,
                  status: study['status'] as String,
                  callback: () {
                    final studyCubit = context.read<StudyCubit>();
                    final studyData = studyCubit.getStudyById(study['_id'] as String);

                    if (studyData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (context) => StudyDetailPage(
                            studyId: study['_id'] as String,
                            studyData: studyData,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildOldStudiesTab() {
    return BlocBuilder<StudyCubit, StudyState>(
      builder: (context, state) {
        if (state is StudyInitial || state is StudyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StudyError) {
          return ApiErrorWidget(
            errorMessage: _getUserFriendlyErrorMessage(state.errorMessage),
            errorDetails: state.errorDetails,
            onRetry: () => context.read<StudyCubit>().fetchStudies(),
          );
        } else if (state is StudyLoaded) {
          final oldStudies = state.studies.where((study) =>
              study['status'] != 'inProgress' && study['status'] != 'draft');

          if (oldStudies.isEmpty) {
            return _buildEmptyState('No completed studies found');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: oldStudies.length,
            itemBuilder: (context, index) {
              final study = oldStudies.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) =>
                          StudyDetailPage(studyId: study['_id'] as String,studyData: study,),
                    ),
                  );
                },
                child: StudyCard(
                  title: study['name'] as String,
                  description: study['description'] as String,
                  progress:
                      (study['responseCount']! / study['sampleSize']) as double,
                  status: study['status'] as String,

                  callback: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (context) =>
                            StudyDetailPage(studyId: study['_id'] as String,studyData: study,),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getUserFriendlyErrorMessage(String technicalError) {
    // Convert technical error messages to user-friendly ones
    if (technicalError.contains('DioException') ||
        technicalError.contains('SocketException') ||
        technicalError.contains('Network is unreachable')) {
      return 'Unable to connect to the server.';
    } else if (technicalError.contains('404') ||
        technicalError.contains('not found')) {
      return 'The requested resource was not found.';
    } else if (technicalError.contains('401') ||
        technicalError.contains('403')) {
      return 'You don\'t have permission to access this content.';
    } else if (technicalError.contains('500') ||
        technicalError.contains('server error')) {
      return 'Server is temporarily unavailable. Please try again later.';
    } else if (technicalError.contains('timeout')) {
      return 'The request timed out. Please check your connection and try again.';
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
