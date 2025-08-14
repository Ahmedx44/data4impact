
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final FlutterSecureStorage secureStorage;

  SplashCubit({required this.secureStorage}) : super(SplashInitial()) {
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    emit(SplashLoading());

    try {
      final sessionCookie = await secureStorage.read(key: 'session_cookie');
      await Future.delayed(const Duration(seconds: 2));

      if (sessionCookie != null && sessionCookie.isNotEmpty) {
        emit(SplashAuthenticated());
      } else {
        emit(SplashUnauthenticated());
      }
    } catch (e) {
      emit(SplashUnauthenticated());
    }
  }
}