import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/features/signup/cubit/signup_cubit.dart';
import 'package:data4impact/features/signup/page/sigup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit(
        authService: AuthService(
          context.read<ApiClient>(),
        ),
      ),
      child: const SignUpView(),
    );
  }
}
