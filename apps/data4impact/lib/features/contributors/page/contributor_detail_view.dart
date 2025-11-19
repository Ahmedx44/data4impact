import 'package:data4impact/core/service/api_service/contributor_service.dart';
import 'package:data4impact/features/contributors/cubit/contributor_detail_cubit.dart';
import 'package:data4impact/features/contributors/cubit/contributor_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class ContributorDetailPage extends StatelessWidget {
  final String contributorId;

  const ContributorDetailPage({super.key, required this.contributorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContributorDetailCubit(
        contributorService: context.read<ContributorService>(),
      )..fetchContributorDetails(contributorId),
      child: const ContributorDetailView(),
    );
  }
}

class ContributorDetailView extends StatelessWidget {
  const ContributorDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      body: BlocBuilder<ContributorDetailCubit, ContributorDetailState>(
        builder: (context, state) {
          if (state.status == ContributorDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == ContributorDetailStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(HugeIcons.strokeRoundedAlert02,
                      size: 48, color: theme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading details',
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
                ],
              ),
            );
          } else if (state.status == ContributorDetailStatus.success &&
              state.contributor != null) {
            final contributor = state.contributor!;
            final user = contributor['user'] as Map<String, dynamic>? ?? {};
            final firstName = user['firstName'] as String? ?? '';
            final lastName = user['lastName'] as String? ?? '';
            final email = user['email'] as String? ?? '';
            final phone = user['phone'] as String? ?? 'N/A';
            final organization =
                contributor['organization'] as String? ?? 'N/A';
            final roles = user['roles'] as List<dynamic>? ?? [];
            final active = user['active'] as bool? ?? false;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: theme.surface,
                  surfaceTintColor: theme.surface,
                  leading: IconButton(
                    icon: Icon(HugeIcons.strokeRoundedArrowLeft01,
                        color: theme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.primary.withOpacity(0.1),
                            theme.surface,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: theme.primaryContainer,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.surface,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadow.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  firstName.isNotEmpty
                                      ? firstName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.lexendDeca(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: theme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$firstName $lastName',
                              style: GoogleFonts.lexendDeca(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(theme, 'Contact Information'),
                        const SizedBox(height: 16),
                        _buildInfoTile(
                          theme,
                          HugeIcons.strokeRoundedMail01,
                          'Email',
                          email,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoTile(
                          theme,
                          HugeIcons.strokeRoundedCall02,
                          'Phone',
                          phone,
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader(theme, 'Organization & Roles'),
                        const SizedBox(height: 16),
                        _buildInfoTile(
                          theme,
                          HugeIcons.strokeRoundedBuilding03,
                          'Organization',
                          organization,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: roles.map((r) {
                            final roleName =
                                (r as Map<String, dynamic>)['name'] as String;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                roleName,
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader(theme, 'Status'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.green.withOpacity(0.1)
                                : theme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active
                                  ? Colors.green.withOpacity(0.3)
                                  : theme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                active
                                    ? HugeIcons.strokeRoundedCheckmarkCircle02
                                    : HugeIcons.strokeRoundedCancel01,
                                size: 20,
                                color: active ? Colors.green : theme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                active ? 'Active Account' : 'Inactive Account',
                                style: GoogleFonts.lexendDeca(
                                  fontWeight: FontWeight.w600,
                                  color: active ? Colors.green : theme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(ColorScheme theme, String title) {
    return Text(
      title,
      style: GoogleFonts.lexendDeca(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.onSurfaceVariant,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildInfoTile(
      ColorScheme theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: theme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lexendDeca(
                  fontSize: 12,
                  color: theme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lexendDeca(
                  fontSize: 16,
                  color: theme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
