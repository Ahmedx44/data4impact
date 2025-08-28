

import 'package:data4impact/core/service/api_service/Model/current_user.dart';

class ProfileState {
  final CurrentUser? user;
  final bool isDarkMode;
  final bool isLoading;

  const ProfileState({
    this.user,
    required this.isDarkMode,
    required this.isLoading,
  });

  ProfileState copyWith({
    CurrentUser? user,
    bool? isDarkMode,
    bool? isLoading,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}