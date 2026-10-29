import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final String email;

  const Authenticated({required this.email});

  @override
  List<Object?> get props => [email];
}

class Unauthenticated extends AuthState {
  final String? lastEmail;

  const Unauthenticated({this.lastEmail});

  @override
  List<Object?> get props => [lastEmail];
}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}
