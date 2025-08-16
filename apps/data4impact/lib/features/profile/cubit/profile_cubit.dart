import 'package:bloc/bloc.dart';
import 'package:data4impact/features/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState(isDarkMode: false));

  void toggleDarkMode() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }
}