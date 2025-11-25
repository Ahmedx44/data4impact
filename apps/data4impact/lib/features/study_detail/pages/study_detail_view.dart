import 'package:data4impact/core/widget/custom_button.dart';
import 'package:data4impact/features/data_collect/page/data_collection_page.dart';
import 'package:data4impact/features/home/widget/actitity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data4impact/core/service/toast_service.dart';

class StudyDetailView extends StatefulWidget {
  final String studyId;
  final Map<String, dynamic> studyData;
  final int? collectorResponseCount;
  final int? collectorMaxLimit;

  const StudyDetailView({
    super.key,
    required this.studyId,
    required this.studyData,
    this.collectorResponseCount,
    this.collectorMaxLimit,
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
    final currentResponses =
        widget.collectorResponseCount ?? widget.studyData['responseCount'] ?? 0;
    final totalResponses =
        widget.collectorMaxLimit ?? widget.studyData['sampleSize'] ?? 0;
    final progress =
        totalResponses as int > 0 ? currentResponses / totalResponses : 0;
    final collectorCount = widget.studyData['collectorCount'] ?? 0;
    final questionCount = widget.studyData['questionCount'] ?? 0;

    final isLimitReached = (totalResponses as int) > 0 &&
        (currentResponses as int) >= (totalResponses as int);

    // Calculate days remaining
    final daysRemaining = _calculateDaysRemaining(widget.studyData);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.studyData['name'].toString(),
              style: GoogleFonts.lexendDeca(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: Text(
                widget.studyData['description'].toString(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexendDeca(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          // Progress Overview Card
          SliverToBoxAdapter(
              child: _buildProgressOverviewCard(
            context,
            currentResponses: currentResponses as int,
            totalResponses: totalResponses as int,
            daysRemaining: daysRemaining,
            progress: (progress as num).toDouble(),
            isLimitReached: isLimitReached,
          )),

          // Study Type Badge
          SliverToBoxAdapter(
            child: _buildStudyTypeBadge(context),
          ),

          // Stats Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final List<StatCardData> stats = [
                    StatCardData(
                      title: 'Total Response',
                      value: totalResponses.toString(),
                      subtitle:
                          '${totalResponses - currentResponses} Remaining',
                      icon: Icons.assignment_turned_in_rounded,
                      color: Colors.blue,
                    ),
                    StatCardData(
                      title: 'Response Rate',
                      value: '${(progress * 100).toStringAsFixed(1)}%',
                      subtitle:
                          '${(progress * 100).toStringAsFixed(1)}% completion',
                      icon: Icons.trending_up_rounded,
                      color: Colors.green,
                      isPercentage: true,
                    ),
                    StatCardData(
                      title: 'Data Collectors',
                      value: collectorCount.toString(),
                      subtitle: 'All active',
                      icon: Icons.people_rounded,
                      color: Colors.orange,
                    ),
                    StatCardData(
                      title: 'Questions',
                      value: questionCount.toString(),
                      subtitle: 'Total questions',
                      icon: Icons.question_answer_rounded,
                      color: Colors.purple,
                    ),
                  ];

                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 300),
                    columnCount: 2,
                    child: FadeInAnimation(
                      child: _buildStatCard(stats[index]),
                    ),
                  );
                },
                childCount: 4,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
            ),
          ),

          SliverToBoxAdapter(
              child:
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.05)),
          if (widget.studyData['status'] != 'completed')
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  width: double.infinity,
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!(totalResponses > 0 &&
                          (currentResponses as int) >= (totalResponses as int)))
                        const Icon(Icons.play_arrow_rounded,
                            color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        (totalResponses > 0 &&
                                (currentResponses as int) >=
                                    (totalResponses as int))
                            ? 'Limit Reached'
                            : 'Continue ${_getStudyTypeDisplayName()}',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // if (totalResponses > 0 &&
                    //     (currentResponses as int) >= (totalResponses as int)) {
                    //   ToastService.showErrorToast(
                    //     message:
                    //         'Maximum response limit reached for this study.',
                    //   );
                    //   return;
                    // }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (context) => DataCollectionPage(
                          studyId: widget.studyId,
                          studyType: _getStudyType(),
                          approach: widget.studyData['approach'].toString(),
                          designType:
                              widget.studyData['design']['type'].toString(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudyTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final studyType = _getStudyTypeDisplayName();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStudyTypeIcon(),
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              studyType,
              style: GoogleFonts.lexendDeca(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStudyTypeIcon() {
    final studyType = _getStudyType();
    switch (studyType) {
      case 'survey':
        return Icons.assignment_rounded;
      case 'interview':
        return Icons.record_voice_over_rounded;
      case 'discussion':
        return Icons.group_rounded;
      case 'longitudinal':
        return Icons.timeline_rounded;
      default:
        return Icons.assignment_rounded;
    }
  }

  Widget _buildProgressOverviewCard(
    BuildContext context, {
    required int currentResponses,
    required int totalResponses,
    required int daysRemaining,
    required double progress,
    required bool isLimitReached,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.08),
            width: 1,
          ),
        ),
        color: colorScheme.surface,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface,
                colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLimitReached ? 'Limit Reached' : 'Progress',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isLimitReached
                              ? theme.colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currentResponses/$totalResponses',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isLimitReached
                              ? theme.colorScheme.error
                              : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Responses',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: CircularProgressIndicator(
                          value: progress > 1 ? 1 : progress,
                          strokeWidth: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLimitReached
                                ? theme.colorScheme.error
                                : (progress >= 1
                                    ? Colors.green
                                    : colorScheme.primary),
                          ),
                          backgroundColor:
                              colorScheme.surfaceVariant.withOpacity(0.5),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isLimitReached
                                  ? theme.colorScheme.error
                                  : colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            isLimitReached ? 'Full' : 'Complete',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 10,
                              color: isLimitReached
                                  ? theme.colorScheme.error
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Timeline Row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Timeline',
                          style: GoogleFonts.lexendDeca(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          daysRemaining > 0
                              ? '$daysRemaining days remaining'
                              : 'Completed',
                          style: GoogleFonts.lexendDeca(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: daysRemaining > 0
                                ? colorScheme.onSurface
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: daysRemaining > 0
                            ? colorScheme.primary.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        daysRemaining > 0
                            ? Icons.schedule_rounded
                            : Icons.check_circle_rounded,
                        color: daysRemaining > 0
                            ? colorScheme.primary
                            : Colors.green,
                        size: 20,
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

  Widget _buildStatCard(StatCardData data) {
    return ActivityCard(
      title: data.title,
      value: 0, // We'll use customValue instead
      subtitle: data.subtitle,
      icon: data.icon,
      color: data.color,
      isPercentage: data.isPercentage,
      customValue: data.value,
      onTap: () {}, // Add functionality if needed
    );
  }

  Widget _buildTabSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surface,
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.primary.withOpacity(0.1),
          ),
          splashFactory: NoSplash.splashFactory,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          labelStyle: GoogleFonts.lexendDeca(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.lexendDeca(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Progress'),
            Tab(text: 'Collectors'),
            Tab(text: 'Timeline'),
          ],
        ),
      ),
    );
  }

  int _calculateDaysRemaining(Map<String, dynamic> studyData) {
    if (studyData['closeOnDate'] != null) {
      final closeDate = DateTime.parse(studyData['closeOnDate'] as String);
      final now = DateTime.now();
      final difference = closeDate.difference(now).inDays;
      return difference > 0 ? difference : 0;
    }
    return 10;
  }
}

class StatCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isPercentage;

  StatCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isPercentage = false,
  });
}
