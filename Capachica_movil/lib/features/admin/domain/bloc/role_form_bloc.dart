import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/role_model.dart';
import '../../data/repositories/role_repository.dart';

part 'role_form_event.dart';
part 'role_form_state.dart';

class RoleFormBloc extends Bloc<RoleFormEvent, RoleFormState> {
  final RoleRepository repo;
  RoleFormBloc(this.repo) : super(RoleFormInitial()) {
    on<RoleCreateRequested>(_onCreate);
    on<RoleUpdateRequested>(_onUpdate);
  }

  Future<void> _onCreate(RoleCreateRequested e, Emitter<RoleFormState> emit) async {
    emit(RoleFormLoading());
    final res = await repo.create(e.name, e.permissions);
    res.fold((err)=>emit(RoleFormError(err)), (role)=>emit(RoleFormSuccess(role)));
  }

  Future<void> _onUpdate(RoleUpdateRequested e, Emitter<RoleFormState> emit) async {
    emit(RoleFormLoading());
    final res = await repo.update(e.id, e.name, e.permissions);
    res.fold((err)=>emit(RoleFormError(err)), (role)=>emit(RoleFormSuccess(role)));
  }
}
