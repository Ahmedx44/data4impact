import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data4impact/core/service/api_service/file_upload_service.dart';
import 'package:data4impact/core/service/api_service/project_service.dart';
import 'package:data4impact/core/service/api_service/segment_service.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/features/home/cubit/home_cubit.dart';
import 'package:data4impact/features/join_with_link/page/join_with_link_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JoinWithLinkPage extends StatelessWidget {
  const JoinWithLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        segmentService: context.read<SegmentService>(),
        secureStorage: context.read<FlutterSecureStorage>(),
        projectService: context.read<ProjectService>(),
        connectivity: context.read<Connectivity>(),
        fileUploadService: context.read<FileUploadService>(),
        studyService: context.read<StudyService>(),
      ),
      child: const JoinWithLinkView(),
    );
  }
}
