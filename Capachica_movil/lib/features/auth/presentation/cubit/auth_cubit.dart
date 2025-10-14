import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';


part 'auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUC;
  final RegisterUseCase registerUC;
  final GetProfileUseCase profileUC;
  final LogoutUseCase logoutUC;
  AuthCubit(this.loginUC, this.registerUC, this.profileUC, this.logoutUC) : super(AuthInitial()) {
    // 🚨 LLAMAR AL PERFIL EN EL CONSTRUCTOR
    loadProfile();
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final res = await loginUC(email, password);
      if (!res.emailVerified) {
        emit(AuthEmailNotVerified());
        return;
      }
      emit(AuthAuthenticated(res.user, res.roles));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }


  Future<void> register({required String name, required String email, required String password, String? phone}) async {
    emit(AuthLoading());
    try {
      final res = await registerUC(name: name, email: email, password: password, phone: phone);
// El backend envía correo de verificación; forzamos estado de verificación pendiente si no está verificado
      if (!res.emailVerified) {
        emit(AuthEmailNotVerified());
        return;
      }
      emit(AuthAuthenticated(res.user, res.roles));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }


  Future<void> loadProfile() async {
    // Si esta llamada está en AuthGate, no uses AuthLoading,
    // sino que maneja la transición directamente.

    try {
      final user = await profileUC();

      emit(AuthAuthenticated(user, user.roles)); // Usar user.roles

    } catch (e) {
      // Si loadProfile falla (ej. 401: Token expirado o inválido)
      // DEBE devolver el control a la pantalla de login.

      // La excepción de 401 que tu ApiClient lanza probablemente es una "ApiException"
      if (e.toString().contains('401') || e.toString().contains('no autorizado')) {

        // 🛑 CAMBIO CRÍTICO: SOLO LLAMAMOS A LA FUNCIÓN DE LIMPIEZA LOCAL.
        // Asumiendo que tu LogoutUseCase (o el repo detrás) puede limpiar SIN llamar al servidor.
        await logoutUC.cleanLocalSession();

        emit(AuthInitial()); // Volver a la pantalla de login
      } else {
        // Error de conexión u otro error
        emit(AuthError(e.toString()));
      }
    }
  }
  Future<void> logout() async {
    await logoutUC();
    emit(AuthInitial());
  }
}