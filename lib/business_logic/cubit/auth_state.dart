part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthLoaded extends AuthState {
  final UserCredential userCredential;
  AuthLoaded(this.userCredential);
}

final class AuthError extends AuthState {
  final String errorMessage;
  AuthError(this.errorMessage);
}
