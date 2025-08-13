import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/features/verify_email/cubit/verify_email_cubit.dart';
import 'package:data4impact/features/verify_email/page/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerifyEmailCubit>(
      create: (context) => VerifyEmailCubit(
        authService: AuthService(
          context.read<ApiClient>(),
        ),
      ),
      child: VerifyEmailView(email: email),
    );
  }
}
