import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class ProjectDrawer extends StatefulWidget {
  const ProjectDrawer({super.key});

  @override
  State<ProjectDrawer> createState() => _ProjectDrawerState();
}

class _ProjectDrawerState extends State<ProjectDrawer> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<Project> _filterProjects(List<Project> projects, String query) {
    if (query.isEmpty) return projects;

    return projects.where((project) {
      final titleMatch = project.title.toLowerCase().contains(query);
      final descriptionMatch =
          project.description?.toLowerCase().contains(query) ?? false;
      return titleMatch || descriptionMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final cubit = context.read<HomeCubit>();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      elevation: 0,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.outline.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedFolder01,
                    color: theme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Projects',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                        ),
                      ),
                      Text(
                        'Switch workspace',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 12,
                          color: theme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(HugeIcons.strokeRoundedCancel01,
                      color: theme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.fetchingProjects) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                    ),
                  );
                }

                if (state.projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(HugeIcons.strokeRoundedFolderRemove,
                            size: 48, color: theme.onSurface.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'No projects available',
                          style: GoogleFonts.lexendDeca(
                            fontSize: 16,
                            color: theme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: cubit.fetchAllProjects,
                          icon: const Icon(HugeIcons.strokeRoundedRefresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredProjects =
                    _filterProjects(state.projects, _searchQuery);

                if (filteredProjects.isEmpty && _searchQuery.isNotEmpty) {
                  return Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildSearchField(theme),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(HugeIcons.strokeRoundedSearch02,
                                  size: 48,
                                  color: theme.onSurface.withOpacity(0.4)),
                              const SizedBox(height: 16),
                              Text(
                                'No projects found',
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 16,
                                  color: theme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 14,
                                  color: theme.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildSearchField(theme),
                    ),

                    // Project count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            '${filteredProjects.length} ${filteredProjects.length == 1 ? 'project' : 'projects'} found',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Project List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProjects.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final project = filteredProjects[index];
                          final isSelected =
                              state.selectedProject?.id == project.id;

                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primary.withOpacity(0.05)
                                  : theme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.primary.withOpacity(0.2)
                                    : theme.outline.withOpacity(0.1),
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.pop(context);

                                if (!isSelected) {
                                  try {
                                    context
                                        .read<HomeCubit>()
                                        .switchProject(project);

                                    // Refresh studies for the new project
                                    final studyCubit =
                                        context.read<StudyCubit>();
                                    studyCubit.fetchStudies(project.slug);
                                  } catch (e) {
                                    // Handle error (already shown via ToastService)
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.primary
                                            : theme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        HugeIcons.strokeRoundedFolder01,
                                        size: 20,
                                        color: isSelected
                                            ? theme.onPrimary
                                            : theme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            project.title,
                                            style: GoogleFonts.lexendDeca(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: theme.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (project.description != null &&
                                              project.description!.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text(
                                                project.description!,
                                                style: GoogleFonts.lexendDeca(
                                                  fontSize: 12,
                                                  color: theme.onSurfaceVariant,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        HugeIcons
                                            .strokeRoundedCheckmarkCircle02,
                                        size: 20,
                                        color: theme.primary,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ColorScheme theme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search projects...',
        hintStyle: GoogleFonts.lexendDeca(
          color: theme.onSurfaceVariant.withOpacity(0.7),
        ),
        prefixIcon: Icon(HugeIcons.strokeRoundedSearch02,
            color: theme.onSurfaceVariant),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(HugeIcons.strokeRoundedCancel01,
                    size: 20, color: theme.onSurfaceVariant),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.surfaceContainerHighest.withOpacity(0.5),
      ),
      style: GoogleFonts.lexendDeca(
        color: theme.onSurface,
      ),
    );
  }
}
