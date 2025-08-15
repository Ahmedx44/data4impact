import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final FlutterSecureStorage secureStorage;

  SplashCubit({required this.secureStorage})
      : super(SplashState(status: SplashStatus.initial));

  Future<void> checkAuthentication() async {
    emit(state.copyWith(status: SplashStatus.loading));

    try {
      final sessionCookie = await secureStorage.read(key: 'session_cookie');

      if (sessionCookie != null && sessionCookie.isNotEmpty) {
        emit(state.copyWith(status: SplashStatus.authenticated));
      } else {
        emit(state.copyWith(status: SplashStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(status: SplashStatus.unauthenticated));
    }
  }
}
