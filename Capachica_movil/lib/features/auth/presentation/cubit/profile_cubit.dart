// Archivo: profile_cubit.dart

import 'package:aplicativo_capachica/features/auth/domain/usecases/get_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// 1. Usa la directiva 'part' para incluir las clases de estado
part 'profile_state.dart';

// --- Cubit ---
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUse getProfileUse;
  final UpdateProfileUseCase updateProfileUseCase;
  final LogoutUseCase logoutUseCase;

  ProfileCubit({
    required this.getProfileUse,
    required this.updateProfileUseCase,
    required this.logoutUseCase,
  }) : super(ProfileInitial());

  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());
      final user = await getProfileUse.call();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError('No se pudo cargar el perfil: $e'));
    }
  }

  Future<void> updateProfile(UpdateProfileParams params) async {
    try {
      emit(ProfileLoading());

      final updatedUser = await updateProfileUseCase.call(params);

      // CAMBIO CLAVE: Emite ProfileLoaded en lugar de ProfileUpdated
      emit(ProfileLoaded(updatedUser));

    } catch (e) {
      final currentState = state is ProfileLoaded ? (state as ProfileLoaded).user : null;
      emit(ProfileError('No se pudo actualizar el perfil: $e'));
      if (currentState != null) {
        emit(ProfileLoaded(currentState));
      }
    }
  }

  Future<void> logout() async {
    try {
      // Esta es una buena práctica, emitir un estado que sepa que la sesión terminó.
      // El BlocProvider superior o el Widget Listener pueden reaccionar a esto.
      // Puedes crear un estado específico como ProfileLoggedOut()
      await logoutUseCase.call();

      // OPTIONAL: Depending on your global Auth state management,
      // you might want to explicitly emit a state change here.
      // For this example, we'll keep it simple:
      // emit(ProfileInitial());

    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }
}