import 'package:data4impact/features/collectors/cubit/collector_state.dart';

class CollectorCubit extends CollectorState {
  CollectorCubit() : super(isLoading: false);

  Future<void> fetchCollectors(String projectSlug) async {
    try {} catch (e) {}
  }
}
