import 'package:connect/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copywith({
    AuthStatus? status,
    UserModel? user,
    String? error,
}) {
    return AuthState(
      status: status ?? this.status,
      user: user??this.user,
      error: error ?? this.error,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [status, user, error];
}
