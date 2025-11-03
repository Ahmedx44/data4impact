import 'package:data4impact/features/data_collect/widget/cross-sectional.dart';
import 'package:flutter/material.dart';
import 'interview.dart';
import 'group_discussion.dart';
import 'longitudinal.dart';

class StudyTypeFactory {
  static Widget getStudyCollectionWidget({
    required String studyType,
    required String studyId,
  }) {
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

  static String getStudyTypeDisplayName(String studyType) {
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