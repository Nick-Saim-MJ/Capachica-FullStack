part of 'user_form_bloc.dart';

abstract class UserFormEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserCreateRequested extends UserFormEvent {
  final Map<String, dynamic> fields; // name, email, password, etc
  final String? fotoPerfilPath;
  UserCreateRequested(this.fields, {this.fotoPerfilPath});
}

class UserUpdateRequested extends UserFormEvent {
  final int id;
  final Map<String, dynamic> fields;
  final String? fotoPerfilPath;
  UserUpdateRequested(this.id, this.fields, {this.fotoPerfilPath});
}
