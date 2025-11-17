import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
      final descriptionMatch = project.description?.toLowerCase().contains(query) ?? false;
      return titleMatch || descriptionMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cubit = context.read<HomeCubit>();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface.withOpacity(0.95)
              : theme.colorScheme.surface,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'My Projects',
                    style: GoogleFonts.lexendDeca(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.fetchingProjects) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (state.projects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_off,
                              size: 48,
                              color: theme.colorScheme.onSurface.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          Text(
                            'No projects available',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: cubit.fetchAllProjects,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredProjects = _filterProjects(state.projects, _searchQuery);

                  if (filteredProjects.isEmpty && _searchQuery.isNotEmpty) {
                    return Column(
                      children: [
                        // Search bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: _buildSearchField(theme),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 48,
                                  color: theme.colorScheme.onSurface.withOpacity(0.4)),
                              const SizedBox(height: 16),
                              Text(
                                'No projects found',
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: _buildSearchField(theme),
                      ),

                      // Project count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              '${filteredProjects.length} ${filteredProjects.length == 1 ? 'project' : 'projects'} found',
                              style: GoogleFonts.lexendDeca(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Project List
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filteredProjects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final project = filteredProjects[index];
                            final isSelected =
                                state.selectedProject?.id == project.id;

                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isSelected
                                    ? BorderSide(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                    width: 1)
                                    : BorderSide.none,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.pop(context);

                                  if (!isSelected) {
                                    try {
                                      context.read<HomeCubit>().switchProject(project);

                                      // Refresh studies for the new project
                                      final studyCubit = context.read<StudyCubit>();
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
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.folder_rounded,
                                          size: 24,
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface
                                              .withOpacity(0.6),
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
                                                fontWeight: FontWeight.w500,
                                                color: theme.colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (project.description != null &&
                                                project.description!.isNotEmpty)
                                              const SizedBox(height: 4),
                                            if (project.description != null &&
                                                project.description!.isNotEmpty)
                                              Text(
                                                project.description!,
                                                style: GoogleFonts.lexendDeca(
                                                  fontSize: 13,
                                                  color: theme.colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 24,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.4),
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
      ),
    );
  }

  TextField _buildSearchField(ThemeData theme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search projects...',
        prefixIcon: Icon(Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.4)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.4)),
          onPressed: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
            });
          },
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant
            .withOpacity(0.4),
      ),
      style: GoogleFonts.lexendDeca(),
    );
  }
}