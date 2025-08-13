import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/app_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.logInfo('BLoC Change: ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.logError(
      'BLoC Error in ${bloc.runtimeType}',
      error,
      stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Initialize logger
  AppLogger.initialize();

  // Set up Flutter error handling
  FlutterError.onError = (details) {
    AppLogger.logError(
      'Flutter Error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
  };

  // Initialize BLoC observer
  Bloc.observer = const AppBlocObserver();

  // Initialize widget bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Set up HydratedBloc storage
  try {
    final storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );
    HydratedBloc.storage = storage;
    AppLogger.logInfo('HydratedStorage initialized successfully');
  } catch (e, stack) {
    AppLogger.logError('Failed to initialize HydratedStorage', e, stack);
    rethrow;
  }

  // Run the app
  runApp(await builder());
}