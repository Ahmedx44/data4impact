import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/invitation_service.dart';
import 'package:data4impact/core/service/toast_service.dart';
import 'package:data4impact/features/inbox/cubit/inbox_state.dart';

class InboxCubit extends Cubit<InboxState> {
  final InvitationService invitationService;

  InboxCubit({required this.invitationService}) : super(const InboxState());

  Future<void> getInvitation() async {
    emit(state.copyWith(isLoading: true));
    try {
      final invitations = await invitationService.getMyInvitation();
      emit(state.copyWith(isLoading: false, invitations: invitations));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  Future<void> acceptInviatation({required String invitationId}) async {
    emit(state.copyWith(isAccepting: true));
    try {
      final acceptInivation =
          await invitationService.acceptInvitation(invitationId);

      ToastService.showSuccessToast(
          message: 'Successfully accepted the invitation');
      emit(state.copyWith(isAccepting: false));
      await getInvitation();
    } catch (e) {
      ToastService.showErrorToast(message: e.toString());
      emit(state.copyWith(isAccepting: false));
      rethrow;
    }
  }

  Future<void> declineInvitation({required String invitationId}) async {
    emit(state.copyWith(isAccepting: true));
    try {
      await invitationService.acceptInvitation(invitationId);

      ToastService.showSuccessToast(
          message: 'Successfully declined the invitation');
      emit(state.copyWith(isAccepting: false));
      await getInvitation();
    } catch (e) {
      ToastService.showErrorToast(message: e.toString());
      emit(state.copyWith(isAccepting: false));
      rethrow;
    }
  }
}
