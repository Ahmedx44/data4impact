import 'package:data4impact/features/data_collect/widget/cross-sectional.dart';
import 'package:flutter/material.dart';
import 'interview.dart';
import 'group_discussion.dart';
import 'longitudinal.dart';

class StudyTypeFactory {
  static Widget getStudyCollectionWidget({
    required String studyType,
    required String studyId,
    required String designType, // Add design type parameter
    required String approach, // Add approach parameter (quantitative/qualitative)
  }) {
    // First check the design type
    if (designType.toLowerCase() == 'longitudinal') {
      return LongitudinalDataCollection(studyId: studyId);
    }

    // Then check the study type/methodology
    switch (studyType.toLowerCase()) {
      case 'survey':
        return CrossSectionalDataCollection(studyId: studyId);
      case 'interview':
        return InterviewDataCollection(studyId: studyId);
      case 'discussion':
        return GroupDiscussionDataCollection(studyId: studyId);
      case 'longitudinal':
        return LongitudinalDataCollection(studyId: studyId);
      default:
      // Default to survey if type is not recognized
        return CrossSectionalDataCollection(studyId: studyId);
    }
  }

  static String getStudyTypeDisplayName(String studyType, String designType, String approach) {
    // Prioritize design type for display
    if (designType.toLowerCase() == 'longitudinal') {
      return 'Longitudinal Study';
    }

    switch (studyType.toLowerCase()) {
      case 'survey':
        return 'Survey';
      case 'interview':
        return 'Interview';
      case 'discussion':
        return 'Group Discussion';
      case 'longitudinal':
        return 'Longitudinal Study';
      default:
        return studyType;
    }
  }
}