import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/repositories/admin_user_repository.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final AdminUserRepository repo;
  int _page = 1;
  bool _hasMore = true;
  final List<AdminUserModel> _items = [];

  UserListBloc(this.repo) : super(UserListInitial()) {
    on<UserListLoad>(_onLoad);
    on<UserListRefresh>(_onRefresh);
    on<UserActivate>(_onActivate);
    on<UserDeactivate>(_onDeactivate);
    on<UserDelete>(_onDelete);
    on<UserAssignRoles>(_onAssignRoles);
  }

  Future<void> _onLoad(UserListLoad e, Emitter<UserListState> emit) async {
    if (state is UserListLoading) return;
    if (e.reset) {
      _page = 1;
      _hasMore = true;
      _items.clear();
      emit(UserListLoading());
    }

    if (!_hasMore) {
      emit(UserListLoaded(items: List.of(_items), hasMore: false));
      return;
    }

    final res = await repo.list(
      search: e.search,
      estado: e.estado,
      rol: e.rol,
      page: _page,
    );
    res.fold(
          (err) => emit(UserListError(err)),
          (list) {
        if (e.reset) _items.clear();
        _items.addAll(list);
        _hasMore = list.isNotEmpty && list.length >= 10; // si tu paginado es de 10
        _page++;
        emit(UserListLoaded(items: List.of(_items), hasMore: _hasMore));
      },
    );
  }

  Future<void> _onRefresh(UserListRefresh e, Emitter<UserListState> emit) async {
    add(UserListLoad(search: e.search, estado: e.estado, rol: e.rol, reset: true));
  }

  Future<void> _onActivate(UserActivate e, Emitter<UserListState> emit) async {
    final res = await repo.activate(e.id);
    res.fold(
          (err) => emit(UserListActionError(err)),
          (_) => add(UserListRefresh(search: e.search, estado: e.estado, rol: e.rol)),
    );
  }

  Future<void> _onDeactivate(UserDeactivate e, Emitter<UserListState> emit) async {
    final res = await repo.deactivate(e.id);
    res.fold(
          (err) => emit(UserListActionError(err)),
          (_) => add(UserListRefresh(search: e.search, estado: e.estado, rol: e.rol)),
    );
  }

  Future<void> _onDelete(UserDelete e, Emitter<UserListState> emit) async {
    final res = await repo.delete(e.id);
    res.fold(
          (err) => emit(UserListActionError(err)),
          (_) => add(UserListRefresh(search: e.search, estado: e.estado, rol: e.rol)),
    );
  }

  Future<void> _onAssignRoles(UserAssignRoles e, Emitter<UserListState> emit) async {
    final res = await repo.assignRoles(e.id, e.roles);
    res.fold(
          (err) => emit(UserListActionError(err)),
          (_) => add(UserListRefresh(search: e.search, estado: e.estado, rol: e.rol)),
    );
  }
}
