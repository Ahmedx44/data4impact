import 'package:data4impact/features/splash/cubit/splash_cubit.dart';
import 'package:data4impact/features/splash/page/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (context) =>
          SplashCubit(secureStorage: context.read<FlutterSecureStorage>()),
      child: const SplashView(),
    );
  }
}
