part of 'auth_cubit.dart';


abstract class AuthState extends Equatable { const AuthState(); @override List<Object?> get props => []; }
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState { final UserEntity user; final List<String> roles; const AuthAuthenticated(this.user, this.roles); @override List<Object?> get props => [user, roles]; }
class AuthEmailNotVerified extends AuthState {}
class AuthError extends AuthState { final String message; const AuthError(this.message); @override List<Object?> get props => [message]; }