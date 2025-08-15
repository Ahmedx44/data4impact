import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/home/widget/actitity_card.dart';
import 'package:data4impact/features/home/widget/assignment_view.dart';
import 'package:data4impact/features/home/widget/earning_view.dart';
import 'package:data4impact/features/home/widget/performance_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                context.read<HomeCubit>().logout(context);
              },
              child: Text(
                'Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your assignments, progress, and upcoming deadlines',
              style: GoogleFonts.lexendDeca(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Grid Cards Section
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
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
                            childCount: 6,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 5,
                            childAspectRatio: 1.3,
                          ),
                        ),
                      ),

                      // Tab Bar Section
                      SliverToBoxAdapter(
                        child: Container(
                          child: Column(
                            children: [
                              // Minimal Tab Bar
                              Container(
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
                                  labelColor:
                                      Theme.of(context).colorScheme.primary,
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
                              Container(
                                constraints:const  BoxConstraints(
                                  maxHeight: 510,
                                ),
                                child: const Padding(
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
