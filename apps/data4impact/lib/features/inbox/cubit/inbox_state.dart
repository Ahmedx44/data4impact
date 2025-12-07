import 'package:data4impact/core/model/notification_model.dart';
import 'package:data4impact/core/service/api_service/Model/invitation_model.dart';
import 'package:equatable/equatable.dart';

// In your InboxState class
class InboxState {
  final List<InvitationModel>? invitations;
  final List<NotificationModel>? notifications;
  final bool isLoading;
  final bool isAccepting;
  final String? error;

  const InboxState({
    this.invitations,
    this.notifications,
    this.isLoading = false,
    this.isAccepting = false,
    this.error,
  });

  // Add copyWith method for state management
  InboxState copyWith({
    List<InvitationModel>? invitations,
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? isAccepting,
    String? error,
  }) {
    return InboxState(
      invitations: invitations ?? this.invitations,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isAccepting: isAccepting ?? this.isAccepting,
      error: error ?? this.error,
    );
  }
}
