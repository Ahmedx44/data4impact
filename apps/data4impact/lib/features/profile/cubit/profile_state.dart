import 'dart:io';

import 'package:data4impact/core/service/api_service/Model/current_user.dart';

class ProfileState {
  final bool isDarkMode;
  final bool isLoading;
  final CurrentUser? user;
  final bool isEditing;
  final File? tempProfileImage;
  final Map<String, String> editedFields;

  const ProfileState({
    required this.isDarkMode,
    required this.isLoading,
    this.user,
    this.isEditing = false,
    this.tempProfileImage,
    this.editedFields = const {},
  });

  ProfileState copyWith({
    bool? isDarkMode,
    bool? isLoading,
    CurrentUser? user,
    bool? isEditing,
    File? tempProfileImage,
    Map<String, String>? editedFields,
  }) {
    return ProfileState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isEditing: isEditing ?? this.isEditing,
      tempProfileImage: tempProfileImage ?? this.tempProfileImage,
      editedFields: editedFields ?? this.editedFields,
    );
  }
}