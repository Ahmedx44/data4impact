import 'package:data4impact/features/home/widget/actitity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Dashboard',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
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
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Grid Cards Section
                    SliverGrid(
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 5,
                        childAspectRatio: 1.4,
                      ),
                    ),

                    // Tab Bar Section
                    SliverToBoxAdapter(
                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Column(
                          children: [
                            // Minimal Tab Bar
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                ),
                              ),
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

                                dividerHeight: 0.1,
                                tabs: const [
                                  Tab(text: 'Assignment'),
                                  Tab(text: 'Performance'),
                                  Tab(text: 'Earning'),
                                ],
                              ),
                            ),

                            // Tab Content
                            SizedBox(
                              height: 200,
                              child: TabBarView(
                                children: [
                                  _buildTabContent(context, 'Assignments content'),
                                  _buildTabContent(context, 'Performance content'),
                                  _buildTabContent(context, 'Earnings content'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: GoogleFonts.lexendDeca(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
