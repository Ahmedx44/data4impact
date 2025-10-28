import 'package:data4impact/core/widget/api_error_widget.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:data4impact/features/study/cubit/study_state.dart';
import 'package:data4impact/features/study/widget/study_card.dart';
import 'package:data4impact/features/study/widget/study_sekeleton.dart';
import 'package:data4impact/features/study_detail/pages/study_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudyView extends StatefulWidget {
  const StudyView({super.key});

  @override
  _StudyViewState createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentProjectSlug;

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
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, homeState) {
        // When project changes, fetch studies
        final projectSlug = homeState.selectedProject?.slug ?? '';
        if (projectSlug.isNotEmpty && projectSlug != _currentProjectSlug) {
          _currentProjectSlug = projectSlug;
          print('🔄 Project changed, fetching studies for: $projectSlug');
          context.read<StudyCubit>().fetchStudies(projectSlug);
        }
      },
      builder: (context, homeState) {
        return BlocConsumer<StudyCubit, StudyState>(
          listener: (context, studyState) {
            // Listen for state changes
            print('🎯 StudyState changed:');
            print('   - studies count: ${studyState.studies.length}');
            print('   - isLoading: ${studyState.isLoading}');
            print('   - hasError: ${studyState.hasError}');
          },
          builder: (context, studyState) {
            print('🎯 Active Studies Tab - Current State:');
            print('   - studies count: ${studyState.studies.length}');
            print('   - isLoading: ${studyState.isLoading}');
            print('   - hasError: ${studyState.hasError}');

            if (studyState.isLoading) {
              print('⏳ Loading state - showing skeleton');
              return _buildSkeletonStudyList();
            } else if (studyState.hasError) {
              print('❌ Error state: ${studyState.errorMessage}');
              return ApiErrorWidget(
                errorMessage: _getUserFriendlyErrorMessage(studyState.errorMessage!),
                errorDetails: studyState.errorDetails!,
                onRetry: () {
                  final projectSlug = homeState.selectedProject?.slug ?? '';
                  if (projectSlug.isNotEmpty) {
                    context.read<StudyCubit>().fetchStudies(projectSlug);
                  }
                },
              );
            } else {
              final activeStudies = studyState.studies.where((study) {
                final status = study['status'] as String?;
                final isActive = status == 'inProgress' || status == 'draft';
                print('🔍 Study "${study['name']}" - status: $status, isActive: $isActive');
                return isActive;
              }).toList();

              print('🔍 Filtered active studies: ${activeStudies.length}');

              if (activeStudies.isEmpty) {
                print('📭 No active studies found');
                return _buildEmptyState('No active studies found');
              }

              print('🎉 Building list with ${activeStudies.length} active studies');
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeStudies.length,
                itemBuilder: (context, index) {
                  final study = activeStudies[index];

                  // Safe progress calculation
                  double progress = 0.0;
                  try {
                    final responses = study['responseCount'] as int? ?? 0;
                    final sample = study['sampleSize'] as int? ?? 0;
                    progress = sample > 0 ? responses / sample : 0.0;
                  } catch (e) {
                    print('❌ Error calculating progress: $e');
                  }

                  return GestureDetector(
                    onTap: () {
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
                    child: StudyCard(
                      title: study['name'] as String? ?? 'Untitled Study',
                      description: study['description'] as String? ?? 'No description available',
                      progress: progress,
                      status: study['status'] as String? ?? 'unknown',
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
          },
        );
      },
    );
  }

  Widget _buildOldStudiesTab() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        return BlocBuilder<StudyCubit, StudyState>(
          builder: (context, studyState) {
            // Debug prints
            print('🎯 Old Studies Tab State:');
            print('   - isInitial: ${studyState.isInitial}');
            print('   - isLoading: ${studyState.isLoading}');
            print('   - hasError: ${studyState.hasError}');
            print('   - studies count: ${studyState.studies.length}');

            // Handle initial state - fetch studies if we have a project
            if (studyState.isInitial) {
              final projectSlug = homeState.selectedProject?.slug ?? '';
              if (projectSlug.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<StudyCubit>().fetchStudies(projectSlug);
                });
              }
            }

            if (studyState.isLoading) {
              return _buildSkeletonStudyList();
            } else if (studyState.hasError) {
              return ApiErrorWidget(
                errorMessage:
                _getUserFriendlyErrorMessage(studyState.errorMessage!),
                errorDetails: studyState.errorDetails!,
                onRetry: () {
                  final projectSlug = homeState.selectedProject?.slug ?? '';
                  if (projectSlug.isNotEmpty) {
                    context.read<StudyCubit>().fetchStudies(projectSlug);
                  }
                },
              );
            } else {
              final oldStudies = studyState.studies.where((study) {
                final status = study['status'] as String?;
                final isOld = status != 'inProgress' && status != 'draft';
                print('🔍 Study "${study['name']}" - status: $status, isOld: $isOld');
                return isOld;
              }).toList();

              print('🔍 Filtered old studies: ${oldStudies.length}');

              if (oldStudies.isEmpty) {
                return _buildEmptyState('No completed studies found');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: oldStudies.length,
                itemBuilder: (context, index) {
                  final study = oldStudies[index];

                  // Safe progress calculation
                  double progress = 0.0;
                  try {
                    final responses = study['responseCount'] as int? ?? 0;
                    final sample = study['sampleSize'] as int? ?? 0;
                    progress = sample > 0 ? responses / sample : 0.0;
                  } catch (e) {
                    print('❌ Error calculating progress: $e');
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (context) => StudyDetailPage(
                            studyId: study['_id'] as String,
                            studyData: study,
                          ),
                        ),
                      );
                    },
                    child: StudyCard(
                      title: study['name'] as String? ?? 'Untitled Study',
                      description: study['description'] as String? ?? 'No description available',
                      progress: progress,
                      status: study['status'] as String? ?? 'unknown',
                      callback: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<Widget>(
                            builder: (context) => StudyDetailPage(
                              studyId: study['_id'] as String,
                              studyData: study,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildSkeletonStudyList() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildSkeletonStudyCard();
        },
      ),
    );
  }

  Widget _buildSkeletonStudyCard() {
    return const SkeletonStudyCard();
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