import 'package:data4impact/core/model/notification_model.dart';
import 'package:data4impact/core/service/api_service/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  NotificationService({required this.apiClient, required this.secureStorage});

  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      final response = await apiClient.get(
        '/notifications',
        options: Options(
          headers: {
            'Cookie': cookie,
          },
          validateStatus: (status) => status == 200,
        ),
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      final data = response.data;

      // Log the response for debugging
      print('Notification API Response: ${data.runtimeType}');
      print('Notification API Response data: $data');

      List<dynamic> notificationList;

      // Handle different response formats
      if (data is List) {
        notificationList = data;
      } else if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is List) {
          notificationList = data['data'] as List;
        } else if (data.containsKey('notifications') &&
            data['notifications'] is List) {
          notificationList = data['notifications'] as List;
        } else {
          // Try to extract any list from the map
          final possibleList = data.values.firstWhere(
            (value) => value is List,
            orElse: () => throw Exception('No list found in response'),
          );
          notificationList = possibleList as List;
        }
      } else {
        throw Exception('Unexpected response format: ${data.runtimeType}');
      }

      // Parse notifications
      return notificationList.map((item) {
        try {
          return NotificationModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing notification item: $item');
          throw Exception('Failed to parse notification: $e');
        }
      }).toList();
    } on DioException catch (e) {
      print('DioError in getNotifications: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Error in getNotifications: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      await apiClient.put(
        '/notifications/$notificationId/status',
        data: {'status': 'read'},
        options: Options(
          headers: {
            'Cookie': cookie,
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      print('DioError in markAsRead: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Error in markAsRead: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final cookie = await secureStorage.read(key: 'session_cookie');
      if (cookie == null) {
        throw Exception('No authentication cookie found');
      }

      await apiClient.post(
        '/notifications/mark-all-read',
        data: {}, // Empty body if needed
        options: Options(
          headers: {
            'Cookie': cookie,
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      print('DioError in markAllAsRead: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Error in markAllAsRead: $e');
      rethrow;
    }
  }
}
