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

    // Add a small delay to ensure widgets are built before fetching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStudies();
    });
  }

  void _initializeStudies() {
    final homeCubit = context.read<HomeCubit>();
    final homeState = homeCubit.state;
    final projectSlug = homeState.selectedProject?.slug ?? '';
    print('🚀 Initializing studies with project slug: "$projectSlug"');

    if (projectSlug.isNotEmpty) {
      _currentProjectSlug = projectSlug;
      context.read<StudyCubit>().fetchStudies(projectSlug);
    } else {
      print('⚠️ No project selected on initialization');
      // Try to get project from home cubit if available
      if (homeState.projects.isNotEmpty) {
        final firstProject = homeState.projects.first;
        print('🔄 Using first available project: ${firstProject.slug}');
        _currentProjectSlug = firstProject.slug;
        context.read<StudyCubit>().fetchStudies(firstProject.slug);
      }
    }
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
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, homeState) {
        final projectSlug = homeState.selectedProject?.slug ?? '';

        if (projectSlug.isNotEmpty && projectSlug != _currentProjectSlug) {
          _currentProjectSlug = projectSlug;

          context.read<StudyCubit>().fetchStudies(projectSlug);
        } else if (projectSlug.isEmpty) {

        }
      },
      builder: (context, homeState) {
        final projectSlug = homeState.selectedProject?.slug ?? '';
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Debug info - remove after testing
                  if (projectSlug.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange[800]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No project selected. Available projects: ${homeState.projects.length}',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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
                        _buildActiveStudiesTab(projectSlug),
                        _buildOldStudiesTab(projectSlug),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveStudiesTab(String projectSlug) {


    return BlocConsumer<StudyCubit, StudyState>(
      listener: (context, studyState) {
        if (studyState.studies.isNotEmpty) {
          for (var study in studyState.studies) {
            final status = study['status'] as String? ?? 'unknown';
            final name = study['name'] as String? ?? 'Unnamed';
          }
        }
      },
      builder: (context, studyState) {
        if (studyState.isLoading && studyState.studies.isEmpty) {
          return _buildSkeletonStudyList(projectSlug);
        } else if (studyState.hasError && studyState.studies.isEmpty) {
          return ApiErrorWidget(
            errorMessage:
            _getUserFriendlyErrorMessage(studyState.errorMessage!),
            errorDetails: studyState.errorDetails!,
            onRetry: () {
              if (projectSlug.isNotEmpty) {
                context.read<StudyCubit>().fetchStudies(projectSlug);
              }
            },
          );
        } else {
          final activeStudies = studyState.studies.where((study) {
            final status = study['status'] as String?;
            final isActive = status == 'inProgress' || status == 'draft';
            return isActive;
          }).toList();

          print('✅ Active studies filtered: ${activeStudies.length}');

          if (activeStudies.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                if (projectSlug.isNotEmpty) {
                  context.read<StudyCubit>().fetchStudies(projectSlug);
                }
              },
              color: Theme.of(context).colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: _buildEmptyState('No active studies found'),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (projectSlug.isNotEmpty) {
                context.read<StudyCubit>().fetchStudies(projectSlug);
              }
            },
            color: Theme.of(context).colorScheme.primary,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: activeStudies.length,
              itemBuilder: (context, index) {
                final study = activeStudies[index];


                double progress = 0.0;
                try {
                  final responses = study['responseCount'] as int? ?? 0;
                  final sample = study['sampleSize'] as int? ?? 0;
                  progress = sample > 0 ? responses / sample : 0.0;
                } catch (e) {
                }

                return GestureDetector(
                  onTap: () {
                    final studyCubit = context.read<StudyCubit>();
                    final studyData =
                    studyCubit.getStudyById(study['_id'] as String);

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
                    description: study['description'] as String? ??
                        'No description available',
                    progress: progress,
                    status: study['status'] as String? ?? 'unknown',
                    callback: () {
                      final studyCubit = context.read<StudyCubit>();
                      final studyData =
                      studyCubit.getStudyById(study['_id'] as String);

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
            ),
          );
        }
      },
    );
  }

  Widget _buildOldStudiesTab(String projectSlug) {

    return BlocConsumer<StudyCubit, StudyState>(
      listener: (context, studyState) {
      },
      builder: (context, studyState) {
        if (studyState.isLoading && studyState.studies.isEmpty) {
          return _buildSkeletonStudyList(projectSlug);
        } else if (studyState.hasError && studyState.studies.isEmpty) {
          return ApiErrorWidget(
            errorMessage:
            _getUserFriendlyErrorMessage(studyState.errorMessage!),
            errorDetails: studyState.errorDetails!,
            onRetry: () {
              if (projectSlug.isNotEmpty) {
                context.read<StudyCubit>().fetchStudies(projectSlug);
              }
            },
          );
        } else {
          final oldStudies = studyState.studies.where((study) {
            final status = study['status'] as String?;
            final isOld = status != 'inProgress' && status != 'draft';
            return isOld;
          }).toList();

          if (oldStudies.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                if (projectSlug.isNotEmpty) {
                  context.read<StudyCubit>().fetchStudies(projectSlug);
                }
              },
              color: Theme.of(context).colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: _buildEmptyState('No completed studies found'),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (projectSlug.isNotEmpty) {
                context.read<StudyCubit>().fetchStudies(projectSlug);
              }
            },
            color: Theme.of(context).colorScheme.primary,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    description: study['description'] as String? ??
                        'No description available',
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
            ),
          );
        }
      },
    );
  }

  Widget _buildSkeletonStudyList(String projectSlug) {

    return RefreshIndicator(
      onRefresh: () async {
        if (projectSlug.isNotEmpty) {
          context.read<StudyCubit>().fetchStudies(projectSlug);
        }
      },
      color: Theme.of(context).colorScheme.primary,
      child: Skeletonizer(
        enabled: true,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _buildSkeletonStudyCard();
          },
        ),
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
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
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
      return 'Unable to connect to the server. Please check your internet connection.';
    } else if (technicalError.contains('404') ||
        technicalError.contains('not found')) {
      return 'The requested studies were not found.';
    } else if (technicalError.contains('401') ||
        technicalError.contains('403')) {
      return 'You don\'t have permission to access these studies.';
    } else if (technicalError.contains('500') ||
        technicalError.contains('server error')) {
      return 'Server is temporarily unavailable. Please try again later.';
    } else if (technicalError.contains('timeout')) {
      return 'The request timed out. Please check your connection and try again.';
    } else if (technicalError.contains('No project selected')) {
      return 'Please select a project first.';
    } else if (technicalError.contains('No projects available')) {
      return 'No projects available. Please contact your administrator.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}