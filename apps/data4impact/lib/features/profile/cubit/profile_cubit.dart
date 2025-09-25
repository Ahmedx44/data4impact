import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/auth_service.dart';
import 'package:data4impact/core/service/api_service/profile_service.dart';
import 'package:data4impact/core/service/internt_connection_monitor.dart';
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

  Future<void> saveProfile(BuildContext context) async {
    emit(state.copyWith(isLoading: true));

    try {
      String? imageUrl;

      // Upload new profile image if selected
      if (state.tempProfileImage != null) {
        imageUrl = await profileService.uploadProfileImage(state.tempProfileImage!);
      }

      // Update profile with edited fields
      final updatedUser = await profileService.updateProfile(
        firstName: state.editedFields['firstName'] ?? state.user?.firstName,
        middleName: state.editedFields['middleName'] ?? state.user?.middleName,
        lastName: state.editedFields['lastName'] ?? state.user?.lastName,
        phone: state.editedFields['phone'] ?? state.user?.phone,
        imageUrl: imageUrl,
      );

      emit(state.copyWith(
        user: updatedUser,
        isEditing: false,
        isLoading: false,
        tempProfileImage: null,
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

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }
}