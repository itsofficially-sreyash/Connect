import 'dart:async';

import 'package:connect/data/repositories/auth_repository.dart';
import 'package:connect/logic/cubits/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState()) {
    _init();
  }

  void _init() {
    emit(state.copywith(status: AuthStatus.initial));

    _authStateSubscription =
        _authRepository.authStateChanges.listen((user,) async {
          if (user != null) {
            try {
              final userData = await _authRepository.getUserData(user.uid);
              emit(state.copywith(
                  status: AuthStatus.authenticated, user: userData));
            } catch (e) {
              emit(state.copywith(
                  status: AuthStatus.error, error: e.toString()));
            }
          } else {
            emit(state.copywith(status: AuthStatus.unauthenticated));
          }
        });
  }

  Future<void> signIn({
    required String email,
    required String password
  }) async {
    try {
      emit(state.copywith(status: AuthStatus.loading));

      final user = await _authRepository.signIn(
          email: email, password: password);

      emit(state.copywith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copywith(status: AuthStatus.error, error: e.toString()));
    }
  }

  Future<void> signUp({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password
  }) async {
    try {
      emit(state.copywith(status: AuthStatus.loading));

      final user = await _authRepository.signUp(fullName: fullName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          username: username);
      emit(state.copywith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copywith(status: AuthStatus.error, error: e.toString()));
    }
  }
  
  Future<void> signOut() async{
    try {
      await _authRepository.signOut();
      emit(state.copywith(
        status: AuthStatus.unauthenticated, user: null
      ));
    } catch (e) {
      emit(state.copywith(status: AuthStatus.error, error: e.toString()));
    }
  }
}
