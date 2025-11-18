import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:data4impact/core/model/signup/signin/signin_Request_model.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/login/cubit/login_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService authService;
  final String flavor;
  final FlutterSecureStorage secureStorage;

  LoginCubit({
    required this.authService,
    required this.flavor,
    required this.secureStorage,
  }) : super(const LoginState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Check if cubit is closed before emitting
    if (isClosed) {
      return;
    }

    emit(state.copyWith(isLoading: true, isSuccess: false));

    try {
      final response = await authService.signIn(
        SignInRequestModel(email: email, password: password),
      );

      await _storeSessionCookie(response.headers);

      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            user: response.user,
          ),
        );
      }

      final currentUser = await authService.getCurrentUser();

      if (!isClosed) {
        ToastService.showSuccessToast(message: 'Login successful');
      }
    } on DioException catch (e) {
      if (!isClosed) {
        final errorMessage = _extractErrorMessage(e);
        ToastService.showErrorToast(message: errorMessage);
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
        ));
      }
    } catch (e, stack) {
      if (!isClosed) {
        const errorMessage = 'An unexpected error occurred. Please try again.';
        ToastService.showErrorToast(message: errorMessage);
        emit(state.copyWith(
          isLoading: false,
          isSuccess: false,
        ));
      }
    }
  }

  Future<void> _storeSessionCookie(Headers? headers) async {
    if (headers == null) return;

    final cookies = headers['set-cookie'];
    if (cookies == null || cookies.isEmpty) return;

    for (final cookie in cookies) {
      if (cookie.contains('sessionId=')) {
        final endIndex = cookie.indexOf(';');
        final sessionPair = cookie.substring(0, endIndex);

        await secureStorage.write(
          key: 'session_cookie',
          value: sessionPair,
        );
        break;
      }
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(
      isLoading: true,
      isSuccess: false,
      isGoogleSignIn: true,
    ));

    try {
      final authUrl = await authService.getOAuthUrl('google');

      final csrfToken = _generateRandomString(32);

      final callbackUrlScheme = _getCallbackUrlScheme();

      final uri = Uri.parse(authUrl);
      final queryParams = Map<String, String>.from(uri.queryParameters)
        ..['state'] = csrfToken;

      final finalAuthUrl = uri.replace(queryParameters: queryParams).toString();

      final result = await FlutterWebAuth2.authenticate(
        url: finalAuthUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      final callbackUri = Uri.parse(result);

      if (callbackUri.queryParameters.containsKey('error')) {
        final errorFromProvider = callbackUri.queryParameters['error'];
        throw Exception('OAuth failed: $errorFromProvider');
      }

      final code = callbackUri.queryParameters['code']!;
      final returnedCsrfToken = callbackUri.queryParameters['state']!;

      if (returnedCsrfToken != csrfToken) {
        throw Exception('Invalid CSRF token - possible security issue');
      }

      await authService.handleOAuthRedirect(
        provider: 'google',
        code: code,
        state: csrfToken,
        flavor: flavor,
      );

      ToastService.showSuccessToast(message: 'Google Sign-In successful');
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isGoogleSignIn: true,
      ));
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        isGoogleSignIn: false,
      ));
    } catch (e) {
      const errorMessage = 'Google Sign-In failed. Please try again.';
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        isGoogleSignIn: false,
      ));
    }
  }

  String _getCallbackUrlScheme() {
    return switch (flavor) {
      'production' => 'data4impact',
      'staging' => 'data4impact.stg',
      'development' => 'data4impact.dev',
      _ => 'data4impact',
    };
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  String _extractErrorMessage(DioException e) {
    try {
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] is String) {
          return data['message'] as String;
        }
      }
      return e.message ?? 'Authentication failed. Please try again.';
    } catch (_) {
      return 'Authentication failed. Please try again.';
    }
  }
}
