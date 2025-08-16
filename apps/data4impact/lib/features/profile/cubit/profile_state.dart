import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileState {
  final bool isDarkMode;

  const ProfileState({required this.isDarkMode});

  ProfileState copyWith({bool? isDarkMode}) {
    return ProfileState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

