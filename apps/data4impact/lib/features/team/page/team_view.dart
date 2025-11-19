import 'package:data4impact/core/service/api_service/Model/team_model.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/team/cubit/team_cubit.dart';
import 'package:data4impact/features/team/cubit/team_state.dart';
import 'package:data4impact/features/team/page/team_detail_view.dart';
import 'package:data4impact/features/team/widget/teams_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamView extends StatefulWidget {
  const TeamView({super.key});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView> {
  @override
  void initState() {
    super.initState();
    context.read<TeamCubit>().getTeams();
    // Ensure collectors data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeCubit>().fetchMyCollectors();
    });
  }

  // Helper methods to calculate statistics from collector data
  int _getTotalCollectors(List<Map<String, dynamic>> collectors) {
    return collectors.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: BlocBuilder<TeamCubit, TeamState>(
          builder: (context, teamState) {
            return BlocBuilder<HomeCubit, HomeState>(
              builder: (context, homeState) {
                // Calculate collector statistics from HomeCubit data
                final totalCollectors = _getTotalCollectors(homeState.collectors);

                if (teamState.isLoading && teamState.teams.isEmpty) {
                  return _buildLoadingState(context);
                }

                if (teamState.error != null && teamState.teams.isEmpty) {
                  return _buildErrorState(context, teamState.error!);
                }

                return _buildContent(context, teamState, homeState, totalCollectors);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Teams...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Teams',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.read<TeamCubit>().getTeams(),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TeamState teamState, HomeState homeState, int totalCollectors) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<TeamCubit>().getTeams();
        await context.read<HomeCubit>().fetchMyCollectors();
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.background,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Section with only 4 cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  TeamStatsCard(
                    title: 'Total Teams',
                    value: teamState.totalTeams,
                    subtitle: 'Active teams',
                    icon: Icons.group_work_rounded,
                  ),
                  TeamStatsCard(
                    title: 'Total Collectors',
                    value: totalCollectors,
                    subtitle: 'All assignments',
                    icon: Icons.assignment_rounded,
                  ),
                ],
              ),
            ),
          ),

          // Teams Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Row(
                children: [
                  Text(
                    'Your Teams',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      teamState.teams.length.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (homeState.isOffline)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Teams List
          if (teamState.teams.isEmpty)
            _buildEmptyState(context)
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final team = teamState.teams[index];
                    return _buildTeamCard(context, team);
                  },
                  childCount: teamState.teams.length,
                ),
              ),
            ),

          // Sync Status
          if (homeState.pendingSyncCount > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sync,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sync Pending',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${homeState.pendingSyncCount} response(s) waiting to sync',
                              style: TextStyle(
                                color: Colors.blue.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!homeState.isSyncing)
                        TextButton(
                          onPressed: () => context.read<HomeCubit>().manualSync(),
                          child: Text(
                            'Sync Now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (homeState.isSyncing)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Teams Found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first team to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                // TODO: Add create team functionality
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Create Team'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, dynamic team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
            width: 1,
          ),
        ),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailView(team: team as TeamModel),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Team Avatar
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.group_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Team Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              team.name as String,
                              style: GoogleFonts.lexendDeca(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${team.memberCount} members',
                              style: GoogleFonts.lexendDeca(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        team.description as String ?? 'No description',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTeamStat(
                            context,
                            Icons.list_alt_rounded,
                            '${team.fields.length} fields',
                          ),
                          const SizedBox(width: 16),
                          _buildTeamStat(
                            context,
                            Icons.people_outline_rounded,
                            '${team.memberCount} members',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamStat(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.lexendDeca(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}