import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data4impact/core/service/app_logger.dart';
import 'package:dio/dio.dart';

class InternetConnectionMonitor {
  final VoidCallback? onConnected;
  final VoidCallback? onDisconnected;
  final String testUrl;
  final bool? checkOnInterval;
  final Duration checkInterval;
  final Duration timeout;
  final bool broadcastStatusContinuously;

  late Connectivity _connectivity;
  late final Dio _dio;
  bool hasInternet = false;
  bool _isMonitoring = false;

  InternetConnectionMonitor({
    this.onConnected,
    this.onDisconnected,
    this.checkOnInterval = true,
    this.testUrl = 'https://www.google.com',
    this.checkInterval = const Duration(seconds: 5),
    this.timeout = const Duration(seconds: 10),
    this.broadcastStatusContinuously = false,
  }) {
    _connectivity = Connectivity();
    _dio = Dio();
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final response = await _dio.get<dynamic>(
        testUrl,
        options: Options(receiveTimeout: timeout, sendTimeout: timeout),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      /// Handle Dio exceptions
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return false;
      }

      /// Handle other Dio exceptions
      return false;
    } catch (e) {
      /// Handle other exceptions
      return false;
    }
  }

  Future<void> _evaluateConnection({bool forceBroadcast = false}) async {
    /// Check connectivity
    final connectivityResult = await _connectivity.checkConnectivity();

    /// If no internet, call onDisconnected
    if (connectivityResult == ConnectivityResult.none) {
      if (hasInternet || forceBroadcast) {
        hasInternet = false;
        onDisconnected?.call();
        AppLogger.logInfo(
          'InternetConnectionMonitor: Internet connection lost',
        );
      }
      return;
    }

    /// Check internet connection
    final hasNet = await _checkInternetConnection();

    /// If internet is established, call onConnected
    if ((hasNet && !hasInternet) || (hasNet && forceBroadcast)) {
      hasInternet = true;
      onConnected?.call();
      AppLogger.logInfo(
        'InternetConnectionMonitor: Internet connection established',
      );
    } else if ((!hasNet && hasInternet) || (!hasNet && forceBroadcast)) {
      /// If internet is lost, call onDisconnected
      hasInternet = false;
      onDisconnected?.call();
      AppLogger.logInfo('InternetConnectionMonitor: Internet connection lost');
    }
  }

  void startMonitoring() {
    /// If already monitoring, return
    if (_isMonitoring) return;

    _isMonitoring = true;

    /// Initial check
    _evaluateConnection();

    /// Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((_) async {
      await _evaluateConnection();
    });

    /// If checkOnInterval is false, we don't need to set up periodic checks
    if(checkOnInterval == false){
      return;
    }

    /// Periodic checks in case connectivity doesn't detect all changes
    Future.doWhile(() async {
      await Future.delayed(checkInterval);
      if (_isMonitoring) {
        await _evaluateConnection(forceBroadcast: broadcastStatusContinuously);
      }
      return _isMonitoring;
    });
  }

  Future<bool> hasInternetConnection() async {
    /// Check connectivity
    final connectivityResult = await _connectivity.checkConnectivity();

    /// If no internet, return false
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    /// Check internet connection
    bool hasNet = await _checkInternetConnection();

    /// If internet is established, return true
    /// If internet is lost, return false
    if (hasNet) {
      return true;
    } else {
      return false;
    }
  }

  void stopMonitoring() {
    _isMonitoring = false;
  }

  Future<void> checkNow() async {
    await _evaluateConnection(forceBroadcast: broadcastStatusContinuously);
  }
}
