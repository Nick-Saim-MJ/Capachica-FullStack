import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:aplicativo_capachica/features/admin/permissions/admin_permissions_page.dart';
import 'package:aplicativo_capachica/features/admin/presentation/bloc/admin_plans_bloc.dart';
import 'package:aplicativo_capachica/features/admin/presentation/bloc/admin_plans_event.dart';
import 'package:aplicativo_capachica/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:aplicativo_capachica/features/admin/presentation/pages/admin_plans_list_page.dart';
import 'package:aplicativo_capachica/features/admin/presentation/widgets/admin_guard.dart';
import 'package:aplicativo_capachica/features/admin/roles/admin_roles_page.dart';
import 'package:aplicativo_capachica/features/admin/users/users.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_bloc.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_event.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/bloc/emprendedor_bloc.dart';
import 'package:aplicativo_capachica/features/home/presentation/bloc/evento_bloc.dart';
import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_bloc.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_event.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicios_relacionados_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// ===== RUTAS CENTRALES =====
import 'core/routes/app_routes.dart';

// ===== INYECCIÓN DE DEPENDENCIAS =====
import 'injection_container.dart' as di;

// ===== HOME =====
import 'features/home/presentation/pages/home_page.dart';

// ===== AUTH =====
import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';

// ===== ASOCIACIONES =====
import 'features/asociaciones/presentation/bloc/asociacion_bloc.dart';

// ===== EMPRENDEDORES =====
import 'features/emprendedores/presentation/pages/emprendedor_page.dart';
import 'features/emprendedores/data/datasources/emprendedor_remote_data_source.dart';
import 'features/emprendedores/data/repositories/emprendedor_repository_impl.dart';

// ===== EVENTOS (import del repositorio) =====
import 'features/home/data/repositories/evento_repository.dart' as ev_repo;
import 'features/carrito/presentation/cubit/carrito_cubit.dart';

// ===== LOCALIZACIÓN =====
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloqueo de orientación a vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Fin del bloqueo de orientación

  // Inicialización de dependencias
  await di.init();

  // Observador de transiciones Bloc
  Bloc.observer = SimpleBlocObserver();

  // --------- AUTH ----------
  final storage = AppSecureStorage();
  final api = ApiClient(storage);
  final ds = AuthRemoteDataSource(api);
  final repo = AuthRepositoryImpl(remote: ds, storage: storage);
  final loginUC = LoginUseCase(repo);
  final registerUC = RegisterUseCase(repo);
  final profileUC = GetProfileUseCase(repo);
  final logoutUC = LogoutUseCase(repo);
  final authCubit = AuthCubit(loginUC, registerUC, profileUC, logoutUC);

  runApp(MyApp(authCubit: authCubit));
}

// ============================================================================
// OBSERVADOR DE BLOCS
// ============================================================================
class SimpleBlocObserver extends BlocObserver {
  @override
  // Debe recibir 'bloc' y 'transition'
  void onTransition(Bloc bloc, Transition transition) {
    // CORRECCIÓN: Llama a super con 'bloc' y 'transition'
    super.onTransition(bloc, transition);
    debugPrint('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} Error: $error\nStackTrace: $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

// ============================================================================
// APLICACIÓN PRINCIPAL
// ============================================================================
class MyApp extends StatelessWidget {
  final AuthCubit authCubit;
  const MyApp({super.key, required this.authCubit});

  @override
  Widget build(BuildContext context) {
    // Configuración de Emprendedores
    final client = http.Client();
    final emprendedorRemoteDataSource = EmprendedorRemoteDataSourceImpl(
      baseUrl: BackendConfig.baseUrl,
      client: client,
    );
    final emprendedorRepository = EmprendedorRepositoryImpl(
      remoteDataSource: emprendedorRemoteDataSource,
      baseUrl: BackendConfig.baseUrl,
    );
    final emprendedoresFuture = emprendedorRepository.getAllEmprendedores();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ServiceRepository>(
          create: (context) => di.sl<ServiceRepository>(),
        ),
        // 👉 Proveemos el repositorio de eventos para que
        //    context.read<ev_repo.EventoRepository>() funcione en las pantallas
        RepositoryProvider<ev_repo.EventoRepository>(
          create: (_) => di.sl<ev_repo.EventoRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<AsociacionBloc>(create: (_) => di.sl<AsociacionBloc>()),
          BlocProvider<EmprendedorBloc>(create: (_) => di.sl<EmprendedorBloc>()),
          BlocProvider<EventoBloc>(create: (_) => di.sl<EventoBloc>()),
          BlocProvider(create: (context) => di.sl<ServicioBloc>()..add(LoadServicios())),
          BlocProvider(create: (context) => di.sl<CategoryBloc>()..add(LoadCategories())),
          BlocProvider(create: (context) => di.sl<ServiciosRelacionadosCubit>()),
          BlocProvider(create: (context) => di.sl<CarritoCubit>()),
        ],
        child: MaterialApp(
          title: 'Aplicativo Capachica',
          debugShowCheckedModeBanner: false,

          // ===== LOCALIZACIÓN =====
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),

          // ===== CONFIGURACIÓN DE RUTAS =====
          initialRoute: '/',
          onGenerateRoute: AppRoutes.generateRoute, // ✅ Usa el router central corregido
          routes: {
            '/': (context) => AuthGate(emprendedoresFuture: emprendedoresFuture),
            '/login': (context) => const LoginPage(),

            // ===== ADMIN =====
            '/admin/users': (context) => const AdminGuard(child: AdminUsersPage()),
            '/admin/roles': (context) => const AdminGuard(child: AdminRolesPage()),
            '/admin/permissions': (context) =>
            const AdminGuard(child: AdminPermissionsPage()),
            '/admin/dashboard': (context) =>
            const AdminGuard(child: AdminDashboardPage()),
            '/admin/plans': (context) => BlocProvider(
              create: (context) => di.sl<AdminPlansBloc>()..add(LoadAdminPlans()),
              child: const AdminGuard(child: AdminPlansListPage()),
            ),
          },
        ),
      ),
    );
  }
}

// ============================================================================
// CONTROL DE FLUJO (AuthGate) - CORREGIDO
// ============================================================================
class AuthGate extends StatelessWidget {
  final Future<List<dynamic>> emprendedoresFuture;
  const AuthGate({super.key, required this.emprendedoresFuture});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomePage();
        }
        // En cualquier otro caso (no autenticado, error, logout)
        return const LoginPage();
      },
    );
  }
}

// ============================================================================
// VERIFICACIÓN DE CORREO
// ============================================================================
class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de Correo')),
      body: const Center(
        child: Text(
          'Por favor, verifica tu correo electrónico para continuar.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
