import 'package:bloc/bloc.dart';
import 'package:data4impact/core/service/api_service/contributor_service.dart';
import 'package:data4impact/features/contributors/cubit/contributor_detail_state.dart';

class ContributorDetailCubit extends Cubit<ContributorDetailState> {
  final ContributorService contributorService;

  ContributorDetailCubit({required this.contributorService})
      : super(const ContributorDetailState());

  Future<void> fetchContributorDetails(String contributorId) async {
    emit(state.copyWith(status: ContributorDetailStatus.loading));

    try {
      final contributor =
          await contributorService.getContributorDetails(contributorId);
      emit(
        state.copyWith(
          status: ContributorDetailStatus.success,
          contributor: contributor,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContributorDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
