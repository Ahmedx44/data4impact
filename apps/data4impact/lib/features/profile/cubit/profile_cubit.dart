import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/api_service/profile_service.dart';
import 'package:data4impact/core/service/internt_connection_monitor.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/profile/cubit/profile_state.dart';
import 'package:data4impact/repository/offline_mode_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthService authService;
  final ProfileService profileService;
  final FlutterSecureStorage secureStorage;

  ProfileCubit({
    required this.authService,
    required this.profileService,
    required this.secureStorage,
  }) : super(const ProfileState(isDarkMode: false, isLoading: false));

  void toggleDarkMode() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  Future<void> fetchCurrentUser() async {
    emit(state.copyWith(
      isLoading: true,
    ));

    // Load auto sync preference
    final isAutoSyncEnabled =
        await OfflineModeDataRepo().getAutoSyncPreference();
    emit(state.copyWith(isAutoSyncEnabled: isAutoSyncEnabled));

    final connected = InternetConnectionMonitor(checkOnInterval: false);

    final isConnected = await connected.hasInternetConnection();

    if (isConnected) {
      try {
        final currentUser = await authService.getCurrentUser();

        await OfflineModeDataRepo().saveCurrentUser(currentUser);

        await fetchUserOrganizations();

        emit(
          state.copyWith(
            user: currentUser,
            isLoading: false,
          ),
        );
      } catch (e) {
        final currentUser = await OfflineModeDataRepo().getSavedCurrentUser();

        emit(
          state.copyWith(
            user: currentUser,
            isLoading: false,
          ),
        );
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

  Future<void> fetchUserOrganizations() async {
    try {
      emit(state.copyWith(loadingOrganizations: true));

      final connected = InternetConnectionMonitor(checkOnInterval: false);
      final isConnected = await connected.hasInternetConnection();

      if (isConnected) {
        final organizations = await profileService.getUserOrganizations();
        emit(
          state.copyWith(
            organizations: organizations,
            loadingOrganizations: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            organizations: [],
            loadingOrganizations: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          organizations: [],
          loadingOrganizations: false,
        ),
      );
    }
  }

  Future<void> refreshUserData() async {
    await fetchCurrentUser();
  }

  void startEditing() {
    emit(state.copyWith(isEditing: true));
  }

  void cancelEditing() {
    emit(state.copyWith(
      isEditing: false,
      tempProfileImage: null,
      editedFields: {},
    ));
  }

  void setTempProfileImage(File image) {
    emit(state.copyWith(tempProfileImage: image));
  }

  void updateField(String field, String value) {
    final updatedFields = Map<String, String>.from(state.editedFields);
    updatedFields[field] = value;

    emit(state.copyWith(editedFields: updatedFields));
  }

  // New method to handle image upload separately
  Future<void> uploadProfileImage(File imageFile) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Upload the profile image
      final imageUrl = await profileService.uploadProfileImage(imageFile);

      // Update profile with the new image URL
      final updatedUser = await profileService.updateProfile(
        firstName: state.user?.firstName,
        middleName: state.user?.middleName,
        lastName: state.user?.lastName,
        phone: state.user?.phone,
        imageUrl: imageUrl,
      );

      emit(state.copyWith(
        user: updatedUser,
        isLoading: false,
        tempProfileImage: imageFile,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    emit(state.copyWith(isLoading: true));

    try {
      final updatedUser = await profileService.updateProfile(
        firstName: state.editedFields['firstName'] ?? state.user?.firstName,
        middleName: state.editedFields['middleName'] ?? state.user?.middleName,
        lastName: state.editedFields['lastName'] ?? state.user?.lastName,
        phone: state.editedFields['phone'] ?? state.user?.phone,
        imageUrl: null,
      );

      emit(state.copyWith(
        user: updatedUser,
        isEditing: false,
        isLoading: false,
        editedFields: {},
      ));

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }

  Future<void> clearStoredResponses(BuildContext context) async {
    emit(state.copyWith(isLoading: true));
    try {
      await OfflineModeDataRepo().clearAllOfflineAnswers();
      emit(state.copyWith(isLoading: false));
      if (context.mounted) {
        ToastService.showSuccessToast(
            message: 'All stored responses cleared successfully');
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear responses: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> toggleAutoSync(bool value) async {
    await OfflineModeDataRepo().saveAutoSyncPreference(value);
    emit(state.copyWith(isAutoSyncEnabled: value));
  }
}
