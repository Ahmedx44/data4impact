import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/features/login/cubit/login_cubit.dart';
import 'package:data4impact/features/login/page/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        flavor: 'data4impact.dev',
        secureStorage: context.read<FlutterSecureStorage>(),
        authService: AuthService(
          apiClient: context.read<ApiClient>(),
          secureStorage: context.read<FlutterSecureStorage>(),
        ),
      ),
      child: const LoginView(),
    );
  }
}
