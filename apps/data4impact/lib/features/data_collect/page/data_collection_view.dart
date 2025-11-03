// DataCollectionView.dart
import 'package:data4impact/features/data_collect/cubit/data_collet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widget/study_type_factory.dart';
import '../cubit/data_collect_cubit.dart';

class DataCollectionView extends StatefulWidget {
  final String studyId;
  final String studyType;

  const DataCollectionView({
    super.key,
    required this.studyId,
    required this.studyType,
  });

  @override
  State<DataCollectionView> createState() => _DataCollectionViewState();
}

class _DataCollectionViewState extends State<DataCollectionView> {
  @override
  void initState() {
    super.initState();
    // Initialize the study questions
    context.read<DataCollectCubit>().getStudyQuestions(widget.studyId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataCollectCubit, DataCollectState>(
      builder: (context, state) {
        return StudyTypeFactory.getStudyCollectionWidget(
          studyType: widget.studyType,
          studyId: widget.studyId,
        );
      },
    );
  }
}