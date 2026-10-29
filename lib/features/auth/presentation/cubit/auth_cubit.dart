import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      final email = await authRepository.getCurrentUserEmail();

      if (isLoggedIn && email != null) {
        emit(Authenticated(email: email));
      } else {
        emit(Unauthenticated(lastEmail: email));
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      await authRepository.login(email: email, password: password);
      final userEmail = await authRepository.getCurrentUserEmail() ?? email;
      emit(Authenticated(email: userEmail));
    } on AuthFailure catch (e) {
      emit(AuthFailureState(message: e.message));
    } catch (_) {
      emit(
        const AuthFailureState(
          message: 'Unable to sign in. Please verify your details.',
        ),
      );
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      final lastEmail = await authRepository.getCurrentUserEmail();
      await authRepository.logout();
      emit(Unauthenticated(lastEmail: lastEmail));
    } catch (_) {
      emit(const Unauthenticated());
    }
  }
}
