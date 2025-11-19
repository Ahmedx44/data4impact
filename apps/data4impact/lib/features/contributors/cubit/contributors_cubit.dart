import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/contributor_service.dart';
import 'package:data4impact/features/contributors/cubit/contributors_state.dart';

class ContributorsCubit extends Cubit<ContributorsState> {
  final ContributorService contributorService;

  ContributorsCubit({required this.contributorService})
      : super(const ContributorsState());

  Future<void> fetchContributors() async {
    emit(state.copyWith(status: ContributorsStatus.loading));

    try {
      final contributors = await contributorService.getContributors();
      emit(
        state.copyWith(
          status: ContributorsStatus.success,
          contributors: contributors,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContributorsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
