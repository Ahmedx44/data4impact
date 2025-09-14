import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/internt_connection_monitor.dart';
import 'package:data4impact/features/profile/cubit/profile_state.dart';
import 'package:data4impact/repository/offline_mode_repo.dart';
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
    final connected = InternetConnectionMonitor(
      checkOnInterval: false,
    );

    final isConnected = await connected.hasInternetConnection();
    if (isConnected) {
      try {
        final currentUser = await authService.getCurrentUser();

        await OfflineModeDataRepo().saveCurrentUser(currentUser);

        emit(
          state.copyWith(
            user: currentUser,
            isLoading: false,
          ),
        );
      } catch (e) {
        final currentUser = await OfflineModeDataRepo().getSavedCurrentUser();

        emit(state.copyWith(
          user: currentUser,
          isLoading: false,
        ));
      }
    } else {
      final currentUser = await OfflineModeDataRepo().getSavedCurrentUser();

      emit(
        state.copyWith(
          user: currentUser,
          isLoading: false,
        ),
      );
    }
  }

  Future<void> refreshUserData() async {
    await fetchCurrentUser();
  }
}
