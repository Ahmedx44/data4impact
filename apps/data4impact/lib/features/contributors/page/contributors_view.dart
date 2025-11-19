import 'package:data4impact/features/contributors/cubit/contributors_cubit.dart';
import 'package:data4impact/features/contributors/cubit/contributors_state.dart';
import 'package:data4impact/features/contributors/page/contributor_card.dart';
import 'package:data4impact/features/contributors/page/contributor_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class ContributorsView extends StatefulWidget {
  const ContributorsView({super.key});

  @override
  State<ContributorsView> createState() => _ContributorsViewState();
}

class _ContributorsViewState extends State<ContributorsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ContributorsCubit>().fetchContributors();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterContributors(List<dynamic> contributors) {
    if (_searchQuery.isEmpty) {
      return contributors;
    }
    return contributors.where((contributor) {
      final user = contributor['user'] as Map<String, dynamic>? ?? {};
      final firstName = (user['firstName'] as String? ?? '').toLowerCase();
      final lastName = (user['lastName'] as String? ?? '').toLowerCase();
      final email = (user['email'] as String? ?? '').toLowerCase();
      return firstName.contains(_searchQuery) ||
          lastName.contains(_searchQuery) ||
          email.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: theme.surface,
      body: RefreshIndicator(
        onRefresh: () => context.read<ContributorsCubit>().fetchContributors(),
        color: theme.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              centerTitle: false,
              backgroundColor: theme.surface,
              surfaceTintColor: theme.surface,
              title: Text(
                'Contributors',
                style: GoogleFonts.lexendDeca(
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.lexendDeca(
                      color: theme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search contributors...',
                      hintStyle: GoogleFonts.lexendDeca(
                        color: theme.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(HugeIcons.strokeRoundedSearch01,
                          color: theme.onSurfaceVariant),
                      filled: true,
                      fillColor: theme.surfaceContainerHighest.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<ContributorsCubit, ContributorsState>(
              builder: (context, state) {
                if (state.status == ContributorsStatus.loading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state.status == ContributorsStatus.failure) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(HugeIcons.strokeRoundedAlert02,
                              size: 48, color: theme.error),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading contributors',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.errorMessage ?? 'Unknown error',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexendDeca(
                                color: theme.onSurface.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () {
                              context
                                  .read<ContributorsCubit>()
                                  .fetchContributors();
                            },
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            icon: const Icon(HugeIcons.strokeRoundedRefresh),
                            label: Text(
                              'Retry',
                              style: GoogleFonts.lexendDeca(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state.status == ContributorsStatus.success) {
                  final filteredContributors =
                      _filterContributors(state.contributors);

                  if (filteredContributors.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(HugeIcons.strokeRoundedUserGroup,
                                size: 64,
                                color: theme.onSurface.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No contributors found'
                                  : 'No matches found',
                              style: GoogleFonts.lexendDeca(
                                fontSize: 16,
                                color: theme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final contributor = filteredContributors[index]
                              as Map<String, dynamic>;
                          final user =
                              contributor['user'] as Map<String, dynamic>? ??
                                  {};
                          final firstName = user['firstName'] as String? ?? '';
                          final lastName = user['lastName'] as String? ?? '';
                          final email = user['email'] as String? ?? '';
                          final roles = user['roles'] as List<dynamic>? ?? [];

                          return GestureDetector(
                            onTap: () {
                              final contributorId =
                                  contributor['_id'] as String?;
                              if (contributorId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<Widget>(
                                    builder: (context) => ContributorDetailPage(
                                      contributorId: contributorId,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: ContributorCard(
                              firstName: firstName,
                              lastName: lastName,
                              email: email,
                              roles: roles,
                            ),
                          );
                        },
                        childCount: filteredContributors.length,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}
