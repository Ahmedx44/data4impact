import 'package:data4impact/core/widget/AfiyaButton.dart';
import 'package:data4impact/features/study_detail/widget/milestone_tracker.dart';
import 'package:data4impact/features/study_detail/widget/response_time_distrubtion.dart';
import 'package:data4impact/features/study_detail/widget/study_detail_actitity_card.dart';
import 'package:data4impact/features/study_detail/widget/top_perfomer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyDetailView extends StatefulWidget {
  const StudyDetailView({super.key});

  @override
  State<StudyDetailView> createState() => _StudyDetailViewState();
}

class _StudyDetailViewState extends State<StudyDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Analytics Dashboard',
              style: GoogleFonts.lexendDeca(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              width: 200,
              child: Text(
                'Comprehensive study performance and data quality insights',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexendDeca(fontSize: 10),
              ),
            )
          ],
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: ProgressTimelineWidget(
              currentResponses: 385,
              totalResponses: 500,
              daysRemaining: 10,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final titles = [
                    'Total Response',
                    'Response Rate',
                    'Data Collectors',
                    'Cost Per Response',
                  ];
                  final values = [50, 72.5, 20, 12];
                  final subtitles = [
                    '500 Remaining',
                    '+3.2% from last week',
                    'All active',
                    "- \$1.20 from target",
                  ];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 300),
                    columnCount: 2,
                    child: FadeInAnimation(
                      child: StudyDetailActitityCard(
                        title: titles[index],
                        value: values[index].toString(),
                        subtitle: subtitles[index],
                      ),
                    ),
                  );
                },
                childCount: 4,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 5,
                childAspectRatio: 1.4,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Material(
              color: colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.primary.withOpacity(0.2),
                ),
                splashFactory: NoSplash.splashFactory,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurface.withAlpha(255),
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
                  Tab(text: 'Progress'),
                  Tab(text: 'Collectors'),
                  Tab(text: 'Timeline'),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: const [
                   ResponseTimeDistributionChart(),
                  TopPerformersWidget(),
                  MilestoneTrackingWidget()
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CustomButton(
                width: double.infinity,
                height: 50,
                child: Text(
                  'Continue Collecting',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onTap: () {},
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
            ),
          )
        ],
      ),
    );
  }
}

class ProgressTimelineWidget extends StatelessWidget {
  final int currentResponses;
  final int totalResponses;
  final int daysRemaining;

  const ProgressTimelineWidget({
    super.key,
    required this.currentResponses,
    required this.totalResponses,
    required this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double progress = currentResponses / totalResponses;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Progress section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary),
                            backgroundColor: theme.colorScheme.surfaceVariant,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: GoogleFonts.lexendDeca(
                              fontSize: 12, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$currentResponses/$totalResponses Responses",
                      style: GoogleFonts.lexendDeca(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),

                // Divider
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),

                // Timeline section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Timeline",
                      style: GoogleFonts.lexendDeca(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    Text(
                      "- $daysRemaining days",
                      style: GoogleFonts.lexendDeca(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface),
                    ),
                    Text(
                      "remaining",
                      style: GoogleFonts.lexendDeca(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
