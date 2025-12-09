// DataCollectionPage.dart
import 'package:data4impact/core/service/api_service/file_upload_service.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/features/data_collect/cubit/data_collect_cubit.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/data_collect/page/data_collection_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataCollectionPage extends StatelessWidget {
  const DataCollectionPage({
    super.key,
    required this.studyId,
    required this.studyType,
    required this.approach,
    required this.designType,
  });
  final String studyId;
  final String studyType;
  final String approach;
  final String designType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DataCollectCubit>(
      create: (context) => DataCollectCubit(
        studyService: context.read<StudyService>(),
        fileUploadService: context.read<FileUploadService>(),
        homeCubit: context.read<HomeCubit>(),
      ),
      child: DataCollectionView(
        studyId: studyId,
        studyType: studyType,
        approach: approach,
        designType: designType,
      ),
    );
  }
}
