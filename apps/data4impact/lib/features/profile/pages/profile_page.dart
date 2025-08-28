import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/features/profile/cubit/profile_cubit.dart';
import 'package:data4impact/features/profile/pages/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => ProfileCubit(
        authService: context.read<AuthService>(),
        secureStorage: context.read<FlutterSecureStorage>(),
      ),
      child: const ProfileView(),
    );
  }
}
