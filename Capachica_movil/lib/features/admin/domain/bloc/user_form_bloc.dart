import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/repositories/admin_user_repository.dart';

part 'user_form_event.dart';
part 'user_form_state.dart';

class UserFormBloc extends Bloc<UserFormEvent, UserFormState> {
  final AdminUserRepository repo;
  UserFormBloc(this.repo) : super(UserFormInitial()) {
    on<UserCreateRequested>(_onCreate);
    on<UserUpdateRequested>(_onUpdate);
  }

  Future<void> _onCreate(UserCreateRequested e, Emitter<UserFormState> emit) async {
    emit(UserFormLoading());
    final res = await repo.create(e.fields, fotoPerfilPath: e.fotoPerfilPath);
    res.fold(
          (err) => emit(UserFormError(err)),
          (user) => emit(UserFormSuccess(user)),
    );
  }

  Future<void> _onUpdate(UserUpdateRequested e, Emitter<UserFormState> emit) async {
    emit(UserFormLoading());
    final res = await repo.update(e.id, e.fields, fotoPerfilPath: e.fotoPerfilPath);
    res.fold(
          (err) => emit(UserFormError(err)),
          (user) => emit(UserFormSuccess(user)),
    );
  }
}
