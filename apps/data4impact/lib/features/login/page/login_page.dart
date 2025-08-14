import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/features/login/cubit/signin_cubit.dart';
import 'package:data4impact/features/login/page/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SigninCubit(
        flavor: 'data4impact.dev',
        authService: AuthService(
          context.read<ApiClient>(),
        ),
      ),
      child: const LoginView(),
    );
  }
}
