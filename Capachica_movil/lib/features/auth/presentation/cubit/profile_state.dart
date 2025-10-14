// Archivo: profile_state.dart

part of 'profile_cubit.dart';


abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {}

// Define el estado de éxito con el UserEntity
class ProfileLoaded extends ProfileState {
  final UserEntity user;
  ProfileLoaded(this.user);
}

// Define el estado de éxito después de la actualización con el UserEntity
class ProfileUpdated extends ProfileState {
  final UserEntity user;
  ProfileUpdated(this.user);
}

// Define el estado de error
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}