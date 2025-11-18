import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/home/widget/actitity_card.dart';
import 'package:data4impact/features/home/widget/assignment_view.dart';
import 'package:data4impact/features/home/widget/project_drawer.dart';
import 'package:data4impact/features/join_with_link/page/join_with_link_page.dart';
import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
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
    await context.read<HomeCubit>().fetchAllProjects();
    // Fetch collectors after projects are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCubit>().fetchMyCollectors();
    });
  }

  Future<void> _onRefresh() async {
    try {
      await context.read<HomeCubit>().fetchAllProjects();
      await context.read<HomeCubit>().fetchMyCollectors();
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
    final theme = Theme.of(context);
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) {
        return previous.selectedProject != current.selectedProject;
      },
      listener: (context, state) {
        if (state.selectedProject != null) {
          context.read<StudyCubit>().fetchStudies(state.selectedProject!.slug);
          // Fetch collectors for the new project
          context.read<HomeCubit>().fetchMyCollectors();
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        drawer: const ProjectDrawer(),
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Your assignments, progress, and upcoming deadlines',
                style: GoogleFonts.lexendDeca(
                  fontSize: 8,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.isSyncing) {
                  return _buildSyncProgressIndicator(context, state);
                }

                if (state.pendingSyncCount > 0) {
                  return Badge(
                    label: Text(state.pendingSyncCount.toString()),
                    child: IconButton(
                      icon: const Icon(Icons.sync_problem),
                      onPressed: () {
                        _showSyncStatusDialog(context, state);
                      },
                      tooltip: '${state.pendingSyncCount} pending sync',
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: () => context.read<HomeCubit>().manualSync(),
                  tooltip: 'Sync Now',
                );
              },
            ),

            // Join Button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(100),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) => const JoinWithLinkPage(),
                    ),
                  );
                },
                child: const Text(
                  'Join',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
        body: BlocConsumer<HomeCubit, HomeState>(
          listener: (context, state) {},
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

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Offline Banner
                      if (state.isOffline)
                        SliverToBoxAdapter(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            color: Colors.orange[100],
                            child: Row(
                              children: [
                                const Icon(Icons.wifi_off,
                                    size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  'Offline Mode',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Responses will be synced when online',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Main Content with Skeletonizer
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Skeletonizer(
                              enabled: state.fetchingCollectors ||
                                  state.fetchingProjects,
                              child: Column(
                                children: [
                                  GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 5,
                                      childAspectRatio: 1.3,
                                    ),
                                    itemCount: 4, // Always 4 cards
                                    itemBuilder: (context, index) {
                                      final title = cardTitles[index];
                                      final value = (state.fetchingCollectors ||
                                              state.fetchingProjects)
                                          ? 0
                                          : cardValues[index];
                                      final subtitle = cardSubtitles[index];

                                      return AnimationConfiguration
                                          .staggeredGrid(
                                        position: index,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        columnCount: 2,
                                        child: FadeInAnimation(
                                          child: ActivityCard(
                                            title: title,
                                            value: value,
                                            subtitle: subtitle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: AssignmentView(
                                        collectors: state.collectors),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sync Progress Overlay
                if (state.isSyncing)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: _buildSyncProgressCard(context, state),
                  ),
              ],
            );
          },
        ),

        // Floating Sync Button for easy access
        floatingActionButton: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.pendingSyncCount > 0 && !state.isSyncing) {
              return FloatingActionButton(
                onPressed: () => context.read<HomeCubit>().manualSync(),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                tooltip: 'Sync ${state.pendingSyncCount} pending responses',
                child: Badge(
                  label: Text(state.pendingSyncCount.toString()),
                  child: const Icon(Icons.sync),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSyncProgressIndicator(BuildContext context, HomeState state) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: state.syncProgress,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Text(
          '${(state.syncProgress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncProgressCard(BuildContext context, HomeState state) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: state.syncProgress,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Syncing...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${(state.syncProgress * 100).toInt()}% complete',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncStatusDialog(BuildContext context, HomeState state) async {
    await showDialog<Widget>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending sync: ${state.pendingSyncCount} response(s)'),
            const SizedBox(height: 16),
            if (state.pendingSyncCount > 0)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<HomeCubit>().manualSync();
                },
                child: const Text('Sync Now'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
