import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/home/widget/actitity_card.dart';
import 'package:data4impact/features/home/widget/assignment_view.dart';
import 'package:data4impact/features/home/widget/project_drawer.dart';
import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<HomeCubit>().fetchAllProjects();
      final state = context.read<HomeCubit>().state;
      /* if (state.selectedProject != null) {
        await context.read<HomeCubit>().fetchMyCollectors();
      }*/
    });
  }

  Future<void> _onRefresh() async {
    try {
      await context.read<HomeCubit>().fetchAllProjects();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  // Helper methods to calculate collector statistics
  int _getTotalCollectors(List<Map<String, dynamic>> collectors) {
    return collectors.length;
  }

  int _getInProgressCollectors(List<Map<String, dynamic>> collectors) {
    return collectors
        .where((collector) => collector['status'] == 'inProgress')
        .length;
  }

  int _getCompletedCollectors(List<Map<String, dynamic>> collectors) {
    return collectors
        .where((collector) => collector['status'] == 'completed')
        .length;
  }

  int _getTotalResponses(List<Map<String, dynamic>> collectors) {
    return collectors.fold(
        0, (sum, collector) => sum + (collector['responseCount'] as int? ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) {
        return previous.selectedProject != current.selectedProject;
      },
      listener: (context, state) {
        if (state.selectedProject != null) {
          context.read<StudyCubit>().fetchStudies(state.selectedProject!.slug);
        }
      },
      child: Scaffold(
        backgroundColor: theme.surface,
        drawer: const ProjectDrawer(),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: theme.primary,
          backgroundColor: theme.surface,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: false,
                centerTitle: false,
                backgroundColor: theme.surface,
                surfaceTintColor: theme.surface,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                      ),
                    ),
                    Text(
                      'Your assignments & progress',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 12,
                        color: theme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                actions: [
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state.isSyncing) {
                        return Container(
                          margin: const EdgeInsets.only(right: 16),
                          width: 40,
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 3,
                                value: state.syncProgress,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primary,
                                ),
                                backgroundColor: theme.primary.withOpacity(0.2),
                              ),
                              Text(
                                '${(state.syncProgress * 100).toInt()}%',
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state.pendingSyncCount > 0) {
                        return IconButton(
                          icon: Badge(
                            label: Text(state.pendingSyncCount.toString()),
                            child: Icon(HugeIcons.strokeRoundedCloudUpload,
                                color: theme.primary),
                          ),
                          onPressed: () =>
                              _showSyncStatusDialog(context, state),
                          tooltip: '${state.pendingSyncCount} pending sync',
                        );
                      }
                      return IconButton(
                        icon: Icon(HugeIcons.strokeRoundedCloudUpload,
                            color: theme.onSurfaceVariant),
                        onPressed: () => context.read<HomeCubit>().manualSync(),
                        tooltip: 'Sync Now',
                      );
                    },
                  ),
                ],
              ),

              // Offline Banner
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.isOffline) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(HugeIcons.strokeRoundedWifi01,
                                size: 20, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'You are offline',
                                    style: GoogleFonts.lexendDeca(
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Responses will be synced automatically when you are back online.',
                                    style: GoogleFonts.lexendDeca(
                                      color: Colors.orange[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Main Content
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  // Calculate collector statistics
                  final totalCollectors = _getTotalCollectors(state.collectors);
                  final inProgressCollectors =
                      _getInProgressCollectors(state.collectors);
                  final completedCollectors =
                      _getCompletedCollectors(state.collectors);
                  final totalResponses = _getTotalResponses(state.collectors);

                  final cardTitles = [
                    'Total Collectors',
                    'In Progress',
                    'Completed',
                    'Total Responses',
                  ];

                  final cardValues = [
                    totalCollectors,
                    inProgressCollectors,
                    completedCollectors,
                    totalResponses,
                  ];

                  final cardSubtitles = [
                    'All assignments',
                    'Active assignments',
                    'Finished assignments',
                    'All responses collected',
                  ];

                  final cardIcons = [
                    HugeIcons.strokeRoundedTask01,
                    HugeIcons.strokeRoundedTime01,
                    HugeIcons.strokeRoundedCheckmarkCircle02,
                    HugeIcons.strokeRoundedNote01,
                  ];

                  final cardColors = [
                    Colors.blue,
                    Colors.orange,
                    Colors.green,
                    Colors.purple,
                  ];

                  return SliverPadding(
                    padding: const EdgeInsets.all(5),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Skeletonizer(
                          enabled: state.fetchingCollectors,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overview',
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.onSurface,
                                ),
                              ),
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(0),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.1,
                                ),
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  final title = cardTitles[index];
                                  final value = (state.fetchingCollectors ||
                                          state.fetchingProjects)
                                      ? 0
                                      : cardValues[index];
                                  final subtitle = cardSubtitles[index];

                                  print(
                                      'card valuee ${title}:${cardValues[index]}');

                                  return AnimationConfiguration.staggeredGrid(
                                    position: index,
                                    duration: const Duration(milliseconds: 300),
                                    columnCount: 2,
                                    child: FadeInAnimation(
                                      child: ActivityCard(
                                        title: title,
                                        value: value,
                                        subtitle: subtitle,
                                        icon: cardIcons[index],
                                        color: cardColors[index],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Always show the assignments section, but conditionally show skeleton or content
                              const SizedBox(height: 32),
                              Text(
                                'Recent Assignments',
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AssignmentView(collectors: state.collectors),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSyncStatusDialog(BuildContext context, HomeState state) async {
    final theme = Theme.of(context).colorScheme;
    await showDialog<Widget>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        surfaceTintColor: theme.surface,
        title: Text(
          'Sync Status',
          style: GoogleFonts.lexendDeca(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(HugeIcons.strokeRoundedCloudUpload,
                    color: theme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${state.pendingSyncCount} response(s) pending upload',
                    style: GoogleFonts.lexendDeca(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (state.pendingSyncCount > 0)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<HomeCubit>().manualSync();
                  },
                  icon: const Icon(HugeIcons.strokeRoundedRefresh),
                  label: Text(
                    'Sync Now',
                    style: GoogleFonts.lexendDeca(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.lexendDeca(
                  color: theme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class RefreshController {
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  void refreshCompleted() {
    _isRefreshing = false;
  }

  void refreshFailed() {
    _isRefreshing = false;
  }
}
