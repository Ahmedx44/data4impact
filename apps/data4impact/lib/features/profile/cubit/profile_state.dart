import 'dart:io';

import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/service/api_service/Model/organization_model.dart';

class ProfileState {
  final bool isDarkMode;
  final bool isLoading;
  final CurrentUser? user;
  final bool isEditing;
  final File? tempProfileImage;
  final Map<String, String> editedFields;
  final List<UserOrganization> organizations; // Add this
  final bool isAutoSyncEnabled;
  final bool loadingOrganizations;

  const ProfileState({
    required this.isDarkMode,
    required this.isLoading,
    this.user,
    this.isEditing = false,
    this.tempProfileImage,
    this.editedFields = const {},
    this.organizations = const [],
    this.loadingOrganizations = false,
    this.isAutoSyncEnabled = true,
  });

  ProfileState copyWith({
    bool? isDarkMode,
    bool? isLoading,
    CurrentUser? user,
    bool? isEditing,
    File? tempProfileImage,
    Map<String, String>? editedFields,
    List<UserOrganization>? organizations,
    bool? loadingOrganizations,
    bool? isAutoSyncEnabled,
  }) {
    return ProfileState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isEditing: isEditing ?? this.isEditing,
      tempProfileImage: tempProfileImage ?? this.tempProfileImage,
      editedFields: editedFields ?? this.editedFields,
      organizations: organizations ?? this.organizations,
      loadingOrganizations: loadingOrganizations ?? this.loadingOrganizations,
      isAutoSyncEnabled: isAutoSyncEnabled ?? this.isAutoSyncEnabled,
    );
  }
}
