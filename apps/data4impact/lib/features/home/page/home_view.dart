import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/widget/actitity_card.dart';
import 'package:data4impact/features/home/widget/assignment_view.dart';
import 'package:data4impact/features/home/widget/performance_view.dart';
import 'package:data4impact/features/home/widget/project_drawer.dart';
import 'package:data4impact/features/join_with_link/page/join_with_link_page.dart';
import 'package:data4impact/features/join_with_link/page/join_with_link_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchAllProjects();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const ProjectDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            collapsedHeight: kToolbarHeight,
            backgroundColor: Theme.of(context).colorScheme.surface,
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
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                  child: const Text("Join"),
                ),
              )
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // Grid Cards Section
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 5,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          final titles = [
                            'Active Assignments',
                            'Completed Assignments',
                            'New Assignments',
                            'Overdue Study',
                            'Study Involved',
                            'Pending Reviews',
                          ];
                          final values = [120, 5400, 2800, 4, 35, 89];
                          final subtitles = [
                            '2 Completed',
                            'This month',
                            'Across all projects',
                            'All tracks',
                            'Across all projects',
                            'Needs attention',
                          ];

                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 300),
                            columnCount: 2,
                            child: FadeInAnimation(
                              child: ActivityCard(
                                title: titles[index],
                                value: values[index],
                                subtitle: subtitles[index],
                              ),
                            ),
                          );
                        },
                      ),

                      // Tab Bar Section
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: TabBar(
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                          ),
                          splashFactory: NoSplash.splashFactory,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(255),
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
                            Tab(text: 'Assignment'),
                            Tab(text: 'Performance'),
                          ],
                        ),
                      ),

                      // Tab Content
                      const SizedBox(
                        height: 510,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: TabBarView(
                            children: [
                              AssignmentView(),
                              PerformanceView(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
