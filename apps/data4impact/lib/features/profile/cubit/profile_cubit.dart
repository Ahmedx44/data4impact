import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/features/profile/cubit/profile_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthService authService;
  final FlutterSecureStorage secureStorage;

  ProfileCubit({
    required this.authService,
    required this.secureStorage,
  }) : super(const ProfileState(isDarkMode: false, isLoading: false));

  void toggleDarkMode() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  Future<void> fetchCurrentUser() async {
    emit(state.copyWith(isLoading: true));

    try {
      // First try to get from secure storage (offline)
      final storedUser = await authService.getStoredCurrentUser();

      if (storedUser != null) {
        emit(state.copyWith(
          user: storedUser,
          isLoading: false,
        ));
      }

      // Then try to fetch from API (online - will update storage)
      final currentUser = await authService.getCurrentUser();

      emit(state.copyWith(
        user: currentUser,
        isLoading: false,
      ));
    } catch (e) {
      // If API fails, use stored user if available
      final storedUser = await authService.getStoredCurrentUser();

      emit(state.copyWith(
        user: storedUser,
        isLoading: false,
      ));
    }
  }

  Future<void> clearUserData() async {
    await authService.clearStoredCurrentUser();
    emit(ProfileState(
      isDarkMode: state.isDarkMode,
      isLoading: false,
    ));
  }

  Future<void> refreshUserData() async {
    await fetchCurrentUser();
  }
}
