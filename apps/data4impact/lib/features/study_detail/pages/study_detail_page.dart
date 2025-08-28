import 'package:data4impact/features/study_detail/pages/study_detail_view.dart';
import 'package:flutter/material.dart';

class StudyDetailPage extends StatelessWidget {
  final String studyId;

  const StudyDetailPage({super.key, required this.studyId});

  @override
  Widget build(BuildContext context) {
    return StudyDetailView(studyId: studyId);
  }
}