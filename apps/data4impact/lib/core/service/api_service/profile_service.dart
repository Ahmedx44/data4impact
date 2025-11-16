import 'dart:convert';
import 'dart:io';

import 'package:data4impact/core/service/api_service/Model/current_user.dart';
import 'package:data4impact/core/service/api_service/Model/organization_model.dart';
import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  ProfileService({required this.apiClient, required this.secureStorage});

  Future<CurrentUser> updateProfile({
    String? firstName,
    String? middleName,
    String? lastName,
    String? phone,
    String? imageUrl,
  }) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final Map<String, dynamic> updateData = {};
      if (firstName != null) updateData['firstName'] = firstName;
      if (middleName != null) updateData['middleName'] = middleName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;

      final response = await apiClient.put(
        '/users/me',
        data: updateData,
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      if (response.data is Map<String, dynamic>) {
        final updatedUser = CurrentUser.fromJson(response.data as Map<String, dynamic>);
        // Update stored user data
        await _storeCurrentUser(updatedUser);
        return updatedUser;
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      print('Profile update error: ${e.response?.data}');
      rethrow;
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await apiClient.post(
        '/files/upload-profile-image',
        data: formData,
        options: Options(
          headers: {
            'Cookie': cookie,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data['url'] as String;
    } on DioException catch (e) {
      print('Image upload error: ${e.response?.data}');
      rethrow;
    }
  }

  Future<void> _storeCurrentUser(CurrentUser user) async {
    try {
      // Convert CurrentUser to JSON string and store it
      final userJson = user.toJson().toString();
      await secureStorage.write(key: 'current_user', value: userJson);
    } catch (e) {
      print('Error storing current user: $e');
      rethrow;
    }
  }

  // Optional: Method to get stored user (useful for offline mode)
  Future<CurrentUser?> getStoredCurrentUser() async {
    try {
      final userJson = await secureStorage.read(key: 'current_user');
      if (userJson != null) {
        // Parse the JSON string back to a Map
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return CurrentUser.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error retrieving stored user: $e');
      return null;
    }
  }

  // Optional: Method to clear stored user
  Future<void> clearStoredCurrentUser() async {
    await secureStorage.delete(key: 'current_user');
  }

  // Optional: Method to update only specific fields without fetching entire user
  Future<CurrentUser> updateProfilePartial(Map<String, dynamic> updates) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.put(
        '/users/me',
        data: updates,
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      if (response.data is Map<String, dynamic>) {
        final updatedUser = CurrentUser.fromJson(response.data as Map<String, dynamic>);
        await _storeCurrentUser(updatedUser);
        return updatedUser;
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      print('Partial profile update error: ${e.response?.data}');
      rethrow;
    }
  }

  // Optional: Method to get user profile by ID (if needed for admin features)
  Future<CurrentUser> getUserProfile(String userId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/users/$userId',
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      if (response.data is Map<String, dynamic>) {
        return CurrentUser.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<List<UserOrganization>> getUserOrganizations() async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/organizations/my',
        options: Options(headers: {
          'Cookie': cookie,
        }),
      );

      print('DEBUG: Organizations raw response: ${response.data}');

      if (response.data is List) {
        final organizations = (response.data as List<dynamic>)
            .map((org) => UserOrganization.fromJson(org as Map<String, dynamic>))
            .toList();
        print('DEBUG: Parsed ${organizations.length} organizations');
        return organizations;
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      print('Get organizations error: ${e.response?.data}');
      rethrow;
    }
  }

// Add this method to build full image URL
  String getOrganizationImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Otherwise, build the full URL
    return 'https://api.data4impact.et/files/$imagePath';
  }
}