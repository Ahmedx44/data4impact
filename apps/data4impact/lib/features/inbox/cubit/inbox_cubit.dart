import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/invitation_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/inbox/cubit/inbox_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class InboxCubit extends Cubit<InboxState> {
  final InvitationService invitationService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  BuildContext? _context;

  InboxCubit({required this.invitationService}) : super(const InboxState());

  // Set context for navigation
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> getInvitation() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final invitations = await invitationService.getMyInvitation();
      emit(state.copyWith(
        isLoading: false,
        invitations: invitations,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));

      // Handle specific authentication error
      if (e.toString().contains('401') ||
          e.toString().contains('noAccessSession') ||
          e.toString().contains('Unauthorized')) {
        await _handleAuthenticationError();
      } else {
        // Emit error state for other errors
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
        rethrow;
      }
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
        rethrow;
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
        rethrow;
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
