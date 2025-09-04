import 'package:data4impact/core/service/api_service/file_upload_service.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/features/data_collect/cubit/data_collect_cubit.dart';
import 'package:data4impact/features/data_collect/page/data_collection_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataCollectionPage extends StatelessWidget {
  const DataCollectionPage({super.key, required this.studyId});
  final String studyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DataCollectCubit>(
      create: (context) => DataCollectCubit(
        studyService: context.read<StudyService>(),
        fileUploadService: context.read<FileUploadService>(),
      ),
      child: DataCollectionView(
        studyId: studyId,
      ),
    );
  }
}
