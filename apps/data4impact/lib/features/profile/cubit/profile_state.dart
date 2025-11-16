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
  final bool loadingOrganizations; // Add this


  const ProfileState({
    required this.isDarkMode,
    required this.isLoading,
    this.user,
    this.isEditing = false,
    this.tempProfileImage,
    this.editedFields = const {},
    this.organizations = const [], // Initialize as empty
    this.loadingOrganizations = false, // Initialize as false
  });

  ProfileState copyWith({
    bool? isDarkMode,
    bool? isLoading,
    CurrentUser? user,
    bool? isEditing,
    File? tempProfileImage,
    Map<String, String>? editedFields,
    List<UserOrganization>? organizations, // Add this
    bool? loadingOrganizations, // Add this
  }) {
    return ProfileState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isEditing: isEditing ?? this.isEditing,
      tempProfileImage: tempProfileImage ?? this.tempProfileImage,
      editedFields: editedFields ?? this.editedFields,
      organizations: organizations ?? this.organizations, // Add this
      loadingOrganizations: loadingOrganizations ?? this.loadingOrganizations, // Add this
    );
  }
}