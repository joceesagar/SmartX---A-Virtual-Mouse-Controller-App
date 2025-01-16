part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSignUp extends AuthState {}

final class AuthLoggedIn extends AuthState {
  final UserModels user;
  AuthLoggedIn(this.user);
}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
