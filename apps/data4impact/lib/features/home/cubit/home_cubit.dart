import 'package:data4impact/core/service/api_service/Model/project.dart';
import 'package:data4impact/core/service/api_service/project_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/home/cubit/home_state.dart';
import 'package:data4impact/features/login/page/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.secureStorage, required this.projectService})
      : super(HomeState());

  final FlutterSecureStorage secureStorage;
  final ProjectService projectService;

  Future<void> logout(BuildContext context) async {
    await secureStorage.delete(key: 'session_cookie');
    ToastService.showSuccessToast(message: 'Logout successful');
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<Widget>(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  Future<void> fetchAllProjects() async {
    emit(state.copyWith(isLoading: true,));
    try {
      final response = await projectService.getAllProjects();

      final projects = response
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();

      emit(state.copyWith(isLoading: false, projects: projects));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}

