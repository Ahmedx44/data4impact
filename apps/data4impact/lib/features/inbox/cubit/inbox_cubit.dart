import 'package:bloc/bloc.dart';
import 'package:data4impact/core/model/notification_model.dart';
import 'package:data4impact/core/service/api_service/Model/invitation_model.dart';
import 'package:data4impact/core/service/api_service/invitation_service.dart';
import 'package:data4impact/core/service/api_service/notification_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/inbox/cubit/inbox_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class InboxCubit extends Cubit<InboxState> {
  final InvitationService invitationService;
  final NotificationService notificationService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  BuildContext? _context;

  InboxCubit({
    required this.invitationService,
    required this.notificationService,
  }) : super(const InboxState());

  // Set context for navigation
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> loadInbox() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final invitationsFuture = invitationService.getMyInvitation();
      final notificationsFuture = notificationService.getNotifications();

      final results = await Future.wait([
        invitationsFuture,
        notificationsFuture,
      ]);

      emit(state.copyWith(
        isLoading: false,
        invitations: results[0] as List<InvitationModel>,
        notifications: results[1] as List<NotificationModel>,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      _handleError(e);
    }
  }

  Future<void> getInvitation() async {
    try {
      final invitations = await invitationService.getMyInvitation();
      emit(state.copyWith(
        invitations: invitations,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> getNotifications() async {
    try {
      final notifications = await notificationService.getNotifications();
      emit(state.copyWith(
        notifications: notifications,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await notificationService.markAsRead(notificationId);

      // Update local state
      final currentNotifications = state.notifications ?? [];
      final updatedNotifications = currentNotifications.map((n) {
        if (n.id == notificationId) {
          // Create a new NotificationModel with updated status
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            type: n.type,
            status: 'read', // Update status to 'read'
            title: n.title,
            message: n.message,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      emit(state.copyWith(notifications: updatedNotifications));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await notificationService.markAllAsRead();
      // Refresh notifications to update status
      await getNotifications();
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) async {
    // Handle specific authentication error
    if (e.toString().contains('401') ||
        e.toString().contains('noAccessSession') ||
        e.toString().contains('Unauthorized')) {
      await _handleAuthenticationError();
    } else {
      // Emit error state for other errors
      emit(state.copyWith(
        error: e.toString(),
      ));
      // Don't rethrow here to avoid crashing UI, just show error
    }
  }

  Future<void> _handleAuthenticationError() async {
    try {
      // Clear stored credentials
      await _secureStorage.delete(key: 'session_cookie');
      await _secureStorage.delete(key: 'current_project_id');

      // Show error message
      ToastService.showErrorToast(
        message: 'Session expired. Please log in again.',
      );

      // Navigate to login if context is available
      if (_context != null && _context!.mounted) {
        // You'll need to access HomeCubit through context
        // This might require passing HomeCubit to this cubit or using a service
        _navigateToLogin();
      }
    } catch (e) {
      // If navigation fails, at least clear storage
      print('Error during authentication cleanup: $e');
    }
  }

  void _navigateToLogin() {
    // This method depends on your app's navigation structure
    // You might need to use a navigation service or pass a callback
    if (_context != null && _context!.mounted) {
      // Example using Navigator - adjust based on your app structure
      Navigator.of(_context!)
          .pushNamedAndRemoveUntil('/login', (route) => false);

      // Alternatively, if you have a global navigation key:
      // navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> acceptInvitation({required String invitationId}) async {
    emit(state.copyWith(isAccepting: true, error: null));
    try {
      await invitationService.acceptInvitation(invitationId);

      ToastService.showSuccessToast(
        message: 'Successfully accepted the invitation',
      );
      emit(state.copyWith(isAccepting: false));

      // Refresh the invitations list
      await getInvitation();
    } catch (e) {
      final errorMessage = e.toString();
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(
        isAccepting: false,
        error: errorMessage,
      ));

      // Handle authentication errors in accept action too
      if (errorMessage.contains('401') ||
          errorMessage.contains('noAccessSession') ||
          errorMessage.contains('Unauthorized')) {
        await _handleAuthenticationError();
      } else {
        // rethrow; // Don't rethrow
      }
    }
  }

  Future<void> declineInvitation({required String invitationId}) async {
    emit(state.copyWith(isAccepting: true, error: null));
    try {
      // Fixed: call declineInvitation instead of acceptInvitation
      await invitationService.declineInvitation(invitationId);

      ToastService.showSuccessToast(
        message: 'Successfully declined the invitation',
      );
      emit(state.copyWith(isAccepting: false));

      // Refresh the invitations list
      await getInvitation();
    } catch (e) {
      final errorMessage = e.toString();
      ToastService.showErrorToast(message: errorMessage);
      emit(state.copyWith(
        isAccepting: false,
        error: errorMessage,
      ));

      // Handle authentication errors in decline action too
      if (errorMessage.contains('401') ||
          errorMessage.contains('noAccessSession') ||
          errorMessage.contains('Unauthorized')) {
        await _handleAuthenticationError();
      } else {
        // rethrow;
      }
    }
  }

  // Clear any errors
  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(error: null));
    }
  }

  // Refresh invitations
  Future<void> refreshInvitations() async {
    await getInvitation();
  }

  @override
  Future<void> close() {
    _context = null;
    return super.close();
  }
}
