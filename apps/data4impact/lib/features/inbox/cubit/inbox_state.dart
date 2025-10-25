import 'package:data4impact/core/service/api_service/Model/invitation_model.dart';
import 'package:equatable/equatable.dart';

// In your InboxState class
class InboxState {
  final List<InvitationModel>? invitations;
  final bool isLoading;
  final bool isAccepting;
  final String? error;

  const InboxState({
    this.invitations,
    this.isLoading = false,
    this.isAccepting=false,
    this.error,
  });

  // Add copyWith method for state management
  InboxState copyWith({
    List<InvitationModel>? invitations,
    bool? isLoading,
    bool? isAccepting,
    String? error,
  }) {
    return InboxState(
      invitations: invitations ?? this.invitations,
      isLoading: isLoading ?? this.isLoading,
      isAccepting: isAccepting??this.isAccepting,
      error: error ?? this.error,
    );
  }
}
