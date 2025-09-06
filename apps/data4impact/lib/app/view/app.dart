import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/api_service/file_upload_service.dart';
import 'package:data4impact/core/service/api_service/project_service.dart';
import 'package:data4impact/core/service/api_service/segment_service.dart';
import 'package:data4impact/core/service/api_service/study_service.dart';
import 'package:data4impact/core/service/app_global_context.dart';
import 'package:data4impact/core/theme/cubit/theme_cubit.dart';
import 'package:data4impact/core/theme/theme.dart';
import 'package:data4impact/features/splash/page/splash_page.dart';
import 'package:data4impact/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toastification/toastification.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize your API client and auth service
    final apiClient = ApiClient(baseUrl: 'https://api.data4impact.et/');
    final secureStorage = FlutterSecureStorage();
    final authService = AuthService(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );
    final segmentService =
    SegmentService(apiClient: apiClient, secureStorage: secureStorage);
    final studyService =
    StudyService(apiClient: apiClient, secureStorage: secureStorage);
    final projectService =
    ProjectService(apiClient: apiClient, secureStorage: secureStorage);
    final fileUploadService = FileUploadService(
      dio: apiClient.dio,
      secureStorage: secureStorage,
    );

    AppGlobalContext.setContext(context);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: authService),
        RepositoryProvider.value(value: secureStorage),
        RepositoryProvider.value(value: projectService),
        RepositoryProvider.value(value: segmentService),
        RepositoryProvider.value(value: studyService),
        RepositoryProvider.value(value: fileUploadService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ThemeCubit(),
          ),
          // Add other BLoCs here as needed
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return ToastificationWrapper(
              child: MaterialApp(
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: context.watch<ThemeCubit>().state,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                debugShowCheckedModeBanner: false,
                home: const SplashPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}