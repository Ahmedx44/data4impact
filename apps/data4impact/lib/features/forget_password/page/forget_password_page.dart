import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/features/forget_password/cubit/forget_password_cubit.dart';
import 'package:data4impact/features/forget_password/page/forget_password_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgetPasswordCubit>(
      create: (context) => ForgetPasswordCubit(
        authService: context.read<AuthService>(),
      ),
      child: const ForgetPasswordView(),
    );
  }
}
