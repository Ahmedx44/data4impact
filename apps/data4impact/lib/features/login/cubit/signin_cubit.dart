import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:data4impact/core/model/signup/signin/signin_Request_model.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/login/cubit/signin_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class SigninCubit extends Cubit<SigninState> {
  final AuthService authService;
  final String flavor; // Add flavor parameter

  SigninCubit({
    required this.authService,
    required this.flavor, // Initialize with flavor
  }) : super(const SigninState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, error: null, isSuccess: false));

    try {
      final response = await authService.signIn(
        SignInRequestModel(email: email, password: password),
      );

      ToastService.showSuccessToast(message: 'Login successful');
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        user: response,
      ));
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: errorMessage,
      ));
    } catch (e, stack) {
      const errorMessage = 'An unexpected error occurred. Please try again.';
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: errorMessage,
      ));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      isSuccess: false,
      isGoogleSignIn: true,
    ));

    try {
      // 1. Get OAuth URL from backend
      final authUrl = await authService.getOAuthUrl('google');

      // Generate random CSRF token (renamed from 'state')
      final csrfToken = _generateRandomString(32);
      final callbackUrlScheme = _getCallbackUrlScheme();

      // Parse URL and ensure only one CSRF token
      final uri = Uri.parse(authUrl);
      final queryParams = Map<String, String>.from(uri.queryParameters)
        ..['state'] = csrfToken; // Override any existing state

      final finalAuthUrl = uri.replace(queryParameters: queryParams).toString();

      // 2. Open browser for authentication
      final result = await FlutterWebAuth2.authenticate(
        url: finalAuthUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      // 3. Parse callback URL
      final callbackUri = Uri.parse(result);
      final code = callbackUri.queryParameters['code']!;
      final returnedCsrfToken = callbackUri.queryParameters['state']!;

      if (returnedCsrfToken != csrfToken) {
        throw Exception('Invalid CSRF token - possible security issue');
      }

      // 4. Handle the redirect with backend
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
        error: errorMessage,
        isGoogleSignIn: false,
      ));
    } catch (e) {
      const errorMessage = 'Google Sign-In failed. Please try again.';
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: errorMessage,
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
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
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