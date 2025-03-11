part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSignUp extends AuthState {}

final class AuthLoggedIn extends AuthState {
  final UserModels user;
  AuthLoggedIn(this.user);

  @override
  List<Object?> get props => [user]; // Include user in props
}

final class AuthGuest extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message]; // Include message in props
}
