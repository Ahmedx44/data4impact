import 'package:data4impact/core/widget/AfiyaButton.dart';
import 'package:data4impact/features/data_collect/page/data_collection_page.dart';
import 'package:data4impact/features/study_detail/widget/milestone_tracker.dart';
import 'package:data4impact/features/study_detail/widget/response_time_distrubtion.dart';
import 'package:data4impact/features/study_detail/widget/study_detail_actitity_card.dart';
import 'package:data4impact/features/study_detail/widget/top_perfomer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyDetailView extends StatefulWidget {
  final String studyId;
  final Map<String, dynamic> studyData;

  const StudyDetailView({
    super.key,
    required this.studyId,
    required this.studyData,
  });

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

  // Helper method to extract study type from methodology
  String _getStudyType() {
    return widget.studyData['methodology'] as String? ?? 'survey';
  }

  // Helper method to get display name for study type
  String _getStudyTypeDisplayName() {
    final studyType = _getStudyType();
    switch (studyType) {
      case 'survey':
        return 'Survey';
      case 'interview':
        return 'Interview';
      case 'discussion':
        return 'Group Discussion';
      case 'longitudinal':
        return 'Longitudinal Study';
      default:
        return 'Survey';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use actual study data instead of static values
    final currentResponses = widget.studyData['responseCount'] ?? 0;
    final totalResponses = widget.studyData['sampleSize'] ?? 0;
    final progress = totalResponses as int > 0 ? currentResponses / totalResponses : 0;
    final collectorCount = widget.studyData['collectorCount'] ?? 0;
    final questionCount = widget.studyData['questionCount'] ?? 0;

    // Calculate days remaining (you might need to adjust this based on your actual data structure)
    final daysRemaining = _calculateDaysRemaining(widget.studyData);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.studyData['name'].toString() ??'',
              style: GoogleFonts.lexendDeca(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              width: 200,
              child: Text(
                widget.studyData['description'].toString() ?? '',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexendDeca(fontSize: 10),
              ),
            )
          ],
        ),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProgressTimelineWidget(
              currentResponses: currentResponses as int,
              totalResponses: totalResponses,
              daysRemaining: daysRemaining,
              progress: progress as int,
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
                    'Questions',
                  ];
                  final values = [
                    totalResponses,
                    (progress * 100).toStringAsFixed(1),
                    collectorCount,
                    questionCount,
                  ];
                  final subtitles = [
                    '${totalResponses - currentResponses} Remaining',
                    '${(progress * 100).toStringAsFixed(1)}% completion',
                    'All active',
                    "Total questions",
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
              height: 410,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ResponseTimeDistributionChart(studyData: widget.studyData),
                  TopPerformersWidget(studyData: widget.studyData),
                  MilestoneTrackingWidget(studyData: widget.studyData),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CustomButton(
                width: double.infinity,
                height: 100,
                child: Text(
                  'Continue ${_getStudyTypeDisplayName()}',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) => DataCollectionPage(
                        studyId: widget.studyId,
                        studyType: _getStudyType(),
                        approach: widget.studyData['approach'].toString(),
                        designType: widget.studyData['design']['type'].toString(),
                      ),
                    ),
                  );
                },
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

  int _calculateDaysRemaining(Map<String, dynamic> studyData) {
    // Implement your logic to calculate days remaining
    // For example, if you have a closeOnDate field:
    if (studyData['closeOnDate'] != null) {
      final closeDate = DateTime.parse(studyData['closeOnDate'] as String);
      final now = DateTime.now();
      final difference = closeDate.difference(now).inDays;
      return difference > 0 ? difference : 0;
    }
    return 10; // Default value if no close date
  }
}

class ProgressTimelineWidget extends StatelessWidget {
  final int currentResponses;
  final int totalResponses;
  final int daysRemaining;
  final int progress;

  const ProgressTimelineWidget({
    super.key,
    required this.currentResponses,
    required this.totalResponses,
    required this.daysRemaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                            value: double.tryParse(progress.toString()),
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
                      daysRemaining > 0 ? "- $daysRemaining days" : "Completed",
                      style: GoogleFonts.lexendDeca(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: daysRemaining > 0
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.primary),
                    ),
                    Text(
                      daysRemaining > 0 ? "remaining" : "on time",
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