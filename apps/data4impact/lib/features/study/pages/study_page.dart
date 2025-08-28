import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/features/study/cubit/study_cubit.dart';
import 'package:data4impact/features/study/pages/study_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => StudyCubit(
              studyService: StudyService(
                apiClient: context.read<ApiClient>(),
                secureStorage: context.read<FlutterSecureStorage>(),
              ),
            ),
        child: StudyView(
          projectSlug: 'majlis-starategy',
        ));
  }
}
