import 'package:data4impact/features/study_detail/pages/study_detail_view.dart';
import 'package:flutter/material.dart';

class StudyDetailPage extends StatelessWidget {
  final String studyId;
  final Map<String, dynamic> studyData;
  final int? collectorResponseCount;
  final int? collectorMaxLimit;

  const StudyDetailPage({
    super.key,
    required this.studyId,
    required this.studyData,
    this.collectorResponseCount,
    this.collectorMaxLimit,
  });

  @override
  Widget build(BuildContext context) {
    return StudyDetailView(
      studyId: studyId,
      studyData: studyData,
      collectorResponseCount: collectorResponseCount,
      collectorMaxLimit: collectorMaxLimit,
    );
  }
}
