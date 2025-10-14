// lib/injection_container.dart
import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:aplicativo_capachica/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aplicativo_capachica/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aplicativo_capachica/features/auth/domain/usecases/get_profile.dart';
import 'package:aplicativo_capachica/features/auth/domain/usecases/get_profile.dart';
import 'package:aplicativo_capachica/features/categoria/data/datasources/categoria_remote_data_source.dart';
import 'package:aplicativo_capachica/features/categoria/data/repository/categoria_repository_impl.dart';
import 'package:aplicativo_capachica/features/categoria/domain/repository/categoria_repository.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/create_category.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/delete_category.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/getCategories.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/getCategory.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/toggle_category_status.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/update_category.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_bloc.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/usecases/create-emprendedor.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/usecases/delete-emprendedor.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/usecases/search-emprendedores.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/usecases/update-emprendedor.dart';
import 'package:aplicativo_capachica/features/home/presentation/bloc/evento_bloc.dart';
import 'package:aplicativo_capachica/features/municipalidades/data/repositories/municipalidad_repository_impl.dart';
import 'package:aplicativo_capachica/features/municipalidades/domain/repositories/municipalidad_repository.dart';
import 'package:aplicativo_capachica/features/municipalidades/domain/usecases/create-municipalidad.dart';
import 'package:aplicativo_capachica/features/municipalidades/domain/usecases/delete-municipalidad.dart';
import 'package:aplicativo_capachica/features/municipalidades/domain/usecases/get_public_municipalidades.dart';
import 'package:aplicativo_capachica/features/municipalidades/domain/usecases/search-municipalidades.dart';
import 'package:aplicativo_capachica/features/municipalidades/domain/usecases/update-municipalidad.dart';
import 'package:aplicativo_capachica/features/municipalidades/presentation/bloc/municipalidad_bloc.dart';

// lib/injection_container.dart
import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:aplicativo_capachica/features/admin/domain/usecases/admin_plan_usecases.dart';
import 'package:aplicativo_capachica/features/auth/domain/usecases/get_profile.dart';
import 'package:aplicativo_capachica/features/servicio/data/datasources/servicio_local_data_source.dart';
import 'package:aplicativo_capachica/features/servicio/data/datasources/servicio_remote_data_source.dart';
import 'package:aplicativo_capachica/features/servicio/data/repositories/servicio_repository_impl.dart';
import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/create_servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/delete_servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/get_services_usecase.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/toggle_servicio_estado.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/update_servicio.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_bloc.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicios_relacionados_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// Carrito
import 'features/carrito/data/datasources/carrito_local_data_source.dart';
import 'features/carrito/data/repositories/carrito_repository_impl.dart';
import 'features/carrito/domain/repositories/carrito_repository.dart';
import 'features/carrito/domain/usecases/get_carrito.dart';
import 'features/carrito/domain/usecases/add_item_to_carrito.dart';
import 'features/carrito/domain/usecases/remove_item_from_carrito.dart';
import 'features/carrito/domain/usecases/clear_carrito.dart';
import 'features/carrito/presentation/cubit/carrito_cubit.dart';

import 'core/network/network_info.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';

// -------- Features: Planes --------
import 'features/plans/data/datasources/plan_remote_data_source.dart';
import 'features/plans/data/datasources/plan_local_data_source.dart';
import 'features/plans/data/repositories/plan_repository_impl.dart';
import 'features/plans/domain/repositories/plan_repository.dart';
import 'features/plans/domain/usecases/get_public_plans.dart';
import 'features/plans/presentation/bloc/plan_bloc.dart';

// -------- Features: Asociaciones --------
import 'features/asociaciones/data/datasources/asociacion_local_data_source.dart';
import 'features/asociaciones/data/datasources/asociacion_remote_data_source.dart';
// Note: Assuming AsociacionRemoteDataSourceImpl exists and is used in the factory method
import 'features/asociaciones/data/repositories/asociacion_repository_impl.dart';
import 'features/asociaciones/domain/repositories/asociacion_repository.dart';
import 'features/asociaciones/domain/usecases/get_asociaciones.dart';
import 'features/asociaciones/domain/usecases/get_asociacion_by_id.dart';
import 'features/asociaciones/domain/usecases/get_emprendedores_by_asociacion.dart';
import 'features/asociaciones/domain/usecases/get_asociaciones_by_municipalidad.dart';
import 'features/asociaciones/domain/usecases/buscar_asociaciones_por_ubicacion.dart';
import 'features/asociaciones/domain/usecases/create_asociacion.dart';
import 'features/asociaciones/domain/usecases/update_asociacion.dart';
import 'features/asociaciones/domain/usecases/delete_asociacion.dart';
import 'features/asociaciones/domain/usecases/get_municipalidades.dart';
import 'features/asociaciones/presentation/bloc/asociacion_bloc.dart';

// -------- NUEVOS Features: Auth (Perfil) --------
import 'features/auth/data/datasources/profile_remote_datasource.dart';
import 'features/auth/data/repositories/profile_repository_impl.dart';
import 'features/auth/domain/repositories/profile_repository.dart';

import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/presentation/cubit/profile_cubit.dart';


// Emprendedores
// ========================
import 'package:aplicativo_capachica/features/emprendedores/data/datasources/emprendedor_remote_data_source.dart';
import 'package:aplicativo_capachica/features/emprendedores/data/repositories/emprendedor_repository_impl.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/repositories/emprendedor_repository.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/usecases/get_public_emprendedores.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/bloc/emprendedor_bloc.dart';

import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart'; // <--- ¡Importación Añadida!
import 'features/auth/domain/repositories/auth_repository.dart'; // <--- ¡Añadido! (Para Logout)
// -------- Features: Admin Plans --------
import 'features/admin/data/repositories/admin_plan_repository_impl.dart';
import 'features/admin/domain/repositories/admin_plan_repository.dart';
import 'features/admin/data/services/admin_plan_service.dart';
import 'features/admin/presentation/bloc/admin_plans_bloc.dart';

// =========================================================================
// >>>>>>>>>>>> NUEVAS IMPORTACIONES PARA PLAN INSCRIPCIÓN <<<<<<<<<<<<<<<
// =========================================================================
import 'features/adminplaninscripcion/presentation/bloc/plan_inscripcion_bloc.dart';
import 'features/adminplaninscripcion/domain/usecases/plan_inscripcion_usecases.dart';
import 'features/adminplaninscripcion/domain/repositories/plan_inscripcion_repository.dart';
import 'features/adminplaninscripcion/data/repositories/plan_inscripcion_repository_impl.dart';
import 'features/adminplaninscripcion/data/services/plan_inscripcion_service.dart';
import 'features/home/data/repositories/evento_repository.dart' as ev_repo;
import 'features/home/presentation/bloc/evento_bloc.dart'; // o usa el path donde realmente está tu bloc

final sl = GetIt.instance;

Future<void> init() async {

  // -------------------------
  // Feature: Auth Data Sources
  // -------------------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
          () => AuthRemoteDataSource(sl()));

  // -------------------------
  // Feature: Auth Repository (Principal)
  // -------------------------
  sl.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(
        remote: sl(), // Resuelve AuthRemoteDataSource
        storage: sl(), // Resuelve AppSecureStorage
      ));

  // -------------------------
  // Feature: Auth (Perfil)
  // -------------------------

  // Cubit (Presentation)
  sl.registerFactory(() => ProfileCubit(
    getProfileUse: sl(),
    updateProfileUseCase: sl(),
    logoutUseCase: sl(),
  ));

  // Use Cases (Domain)
  // **CORREGIDO:** Usa GetProfileUse (tu nombre de clase real) y ProfileRepository (la interfaz).
  sl.registerLazySingleton(() => GetProfileUse(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

  // Repository (Domain) - ProfileRepository (Interfaz y su implementación)

  sl.registerLazySingleton<ProfileRepository>(
          () => ProfileRepositoryImpl(sl()));

  // Data Sources (Data)
  sl.registerLazySingleton<ProfileRemoteDataSource>(
          () => ProfileRemoteDataSource(sl()));
  // -------------------------
  // Feature: Planes
  // -------------------------
  sl.registerFactory(() => PlanBloc(getPublicPlans: sl()));
  sl.registerLazySingleton(() => GetPublicPlans(sl()));
  sl.registerLazySingleton<PlanRepository>(() => PlanRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<PlanRemoteDataSource>(
          () => PlanRemoteDataSourceImpl(client: sl()));
  sl.registerLazySingleton<PlanLocalDataSource>(
          () => PlanLocalDataSourceImpl(sharedPreferences: sl()));


  // ========================
// EVENTOS
// ========================
  sl.registerLazySingleton<ev_repo.EventoRepository>(
        () => ev_repo.EventoRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerFactory<EventoBloc>(
        () => EventoBloc(sl<ev_repo.EventoRepository>()),
  );

  // -------------------------
  // Feature: Asociaciones <--- REINTEGRADO
  // -------------------------

  // Bloc (Presentation)
  sl.registerFactory(
    () => AsociacionBloc(
      getAsociaciones: sl(),
      getAsociacionById: sl(),
      getEmprendedoresByAsociacion: sl(),
      getAsociacionesByMunicipalidad: sl(),
      buscarAsociacionesPorUbicacion: sl(),
      createAsociacion: sl(),
      updateAsociacion: sl(),
      deleteAsociacion: sl(),
      getMunicipalidades: sl(),
    ),
  );

  // Use Cases (Domain)
  sl.registerLazySingleton(() => GetAsociaciones(sl()));
  sl.registerLazySingleton(() => GetAsociacionById(sl()));
  sl.registerLazySingleton(() => GetEmprendedoresByAsociacion(sl()));
  sl.registerLazySingleton(() => GetAsociacionesByMunicipalidad(sl()));
  sl.registerLazySingleton(() => BuscarAsociacionesPorUbicacion(sl()));
  sl.registerLazySingleton(() => CreateAsociacionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAsociacionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAsociacionUseCase(sl()));
  sl.registerLazySingleton(() => GetMunicipalidades(sl()));

  // Repository (Data)
  sl.registerLazySingleton<AsociacionRepository>(
        () => AsociacionRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources (Data)
  sl.registerLazySingleton<AsociacionRemoteDataSource>(
          () => AsociacionRemoteDataSourceImpl(client: sl(), secureStorage: sl()));
  sl.registerLazySingleton<AsociacionLocalDataSource>(
          () => AsociacionLocalDataSourceImpl(sharedPreferences: sl()));



// ========================
// Emprendedores
// ========================
// Remote Data Source (instanciamos la implementación concreta)
  sl.registerLazySingleton<EmprendedorRemoteDataSource>(
        () => EmprendedorRemoteDataSourceImpl(
      baseUrl: BackendConfig.baseUrl, // <-- ahora apunta a 10.0.2.2
      client: sl(),
    ),
  );

// Repository
  sl.registerLazySingleton<EmprendedorRepository>(
        () => EmprendedorRepositoryImpl(remoteDataSource: sl(), baseUrl: BackendConfig.baseUrl),
  );

// Use Case
  sl.registerLazySingleton(() => GetPublicEmprendedores(repository: sl()));
  sl.registerLazySingleton(() => CreateEmprendedor(repository: sl()));
  sl.registerLazySingleton(() => UpdateEmprendedor(repository: sl()));
  sl.registerLazySingleton(() => DeleteEmprendedor(repository: sl()));
  sl.registerLazySingleton(() => SearchEmprendedores(repository: sl()));

// Bloc
  sl.registerFactory(() => EmprendedorBloc(
    getPublicEmprendedores: sl(),
    createEmprendedor: sl(),
    updateEmprendedor: sl(),
    deleteEmprendedor: sl(),
    searchEmprendedores: sl(),

  ));

  // ========================
  // SERVICIOS
  // ========================

  // Remote Data Source
  sl.registerLazySingleton<ServicioRemoteDataSource>(
        () => ServicioRemoteDataSource(
      baseUrl: BackendConfig.baseUrl,
      secureStorage: sl(),
    ),
  );
  // Local Data Source
  sl.registerLazySingleton<ServicioLocalDataSource>(
        () => ServicioLocalDataSource(),
  );

  // Repository
  sl.registerLazySingleton<ServiceRepository>(
        () => ServiceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Case
  sl.registerLazySingleton(() => GetServicesUseCase(repository: sl()));
  sl.registerLazySingleton(() => ToggleServicioEstado(repository: sl()));
  sl.registerLazySingleton(() => CreateServicio(repository: sl()));
  sl.registerLazySingleton(() => UpdateServicio(repository: sl()));
  sl.registerLazySingleton(() => DeleteServicio(repository: sl()));

  // Blocs & Cubits
  sl.registerFactory(() => ServicioBloc(
    repository: sl(),
    getServicesUseCase: sl(),
    toggleServicioEstadoUseCase: sl(),
    createServicioUseCase: sl(),
    updateServicioUseCase: sl(),
    deleteServicioUseCase: sl(),
  ));

  sl.registerFactory(() => ServiciosRelacionadosCubit(
    repository: sl(),
  ));

  // ========================
  // CATEGORIAS
  // ========================

  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
    baseUrl: BackendConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
  )));
  // Remote Data Source
  sl.registerLazySingleton<CategoryRemoteDataSource>(
        () => CategoryRemoteDataSource(secureStorage: sl(), client: sl()),
  );

  // Repository
  sl.registerLazySingleton<CategoryRepository>(
        () => CategoryRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use Case
  sl.registerLazySingleton(() => GetCategories(repository: sl()));
  sl.registerLazySingleton(() => GetCategory(repository: sl()));
  sl.registerLazySingleton(() => CreateCategory(repository: sl()));
  sl.registerLazySingleton(() => UpdateCategory(repository: sl()));
  sl.registerLazySingleton(() => DeleteCategory(repository: sl()));
  sl.registerLazySingleton(() => ToggleCategoryStatus(repository: sl()));

  // Blocs & Cubits
  sl.registerFactory(() => CategoryBloc(
    getCategoriesUseCase: sl(),
    createCategoryUseCase: sl(),
    updateCategoryUseCase: sl(),
    deleteCategoryUseCase: sl(),
  ));


//MUNICIPALIDAD

// Repositorio
  //! BLOCS
  // 1. REGISTRO DEL REPOSITORIO
  sl.registerLazySingleton<MunicipalidadRepository>(
        () => MunicipalidadRepositoryImpl(BackendConfig.baseUrl),
  );

// 2. USE CASES
  sl.registerLazySingleton(() => GetAllMunicipalidades(repository: sl()));
  sl.registerLazySingleton(() => GetMunicipalidadById(repository: sl()));
  sl.registerLazySingleton(() => CreateMunicipalidad(repository: sl()));
  sl.registerLazySingleton(() => UpdateMunicipalidad(repository: sl()));
  sl.registerLazySingleton(() => DeleteMunicipalidad(repository: sl()));

// 3. BLOCS
  sl.registerFactory(() => MunicipalidadBloc(
    getAllMunicipalidades: sl(),
    getMunicipalidadById: sl(),
    createMunicipalidad: sl(),
    updateMunicipalidad: sl(),
    deleteMunicipalidad: sl(),
  ));
  // ========================
// ADMIN PLANS (Nuevo)
// ========================

// Bloc
  sl.registerFactory(() => AdminPlansBloc(
    getPlansUseCase: sl(),
    createPlanUseCase: sl(),
    updatePlanUseCase: sl(),
    deletePlanUseCase: sl(),
  ));

// Use Cases
  sl.registerLazySingleton(() => GetPlansUseCase(sl()));
  sl.registerLazySingleton(() => CreatePlanUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlanUseCase(sl()));
  sl.registerLazySingleton(() => DeletePlanUseCase(sl()));

// Repository
  sl.registerLazySingleton<AdminPlanRepository>(
          () => AdminPlanRepositoryImpl(service: sl()));

// Service
  sl.registerLazySingleton(() => AdminPlanService(
    client: sl(),
    storage: sl(),
  ));

// =========================================================================
  // >>>>>>>>>>>> SECCIÓN AÑADIDA PARA PLAN INSCRIPCIÓN <<<<<<<<<<<<<<<
  // =========================================================================

  // --- BLoC ---
  sl.registerFactory(() => PlanInscripcionBloc(
    getInscripcionesUseCase: sl(),
    updateEstadoUseCase: sl(),
  ));
  // --- Use Cases ---
  sl.registerLazySingleton(() => GetInscripcionesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEstadoInscripcionUseCase(sl()));

  // --- Repository ---
  sl.registerLazySingleton<PlanInscripcionRepository>(
        () => PlanInscripcionRepositoryImpl(service: sl()),
  );

  // --- Service ---
  sl.registerLazySingleton<PlanInscripcionService>(
        () => PlanInscripcionServiceImpl(client: sl(), storage: sl()),
  );


  // -------------------------
  // Core & External
  // -------------------------

  // Core (necesario para ProfileRemoteDataSource)

  // 1. AppSecureStorage (no tiene dependencias)
  sl.registerLazySingleton(() => AppSecureStorage());

  // 2. ApiClient (depende de AppSecureStorage)
  sl.registerLazySingleton(() => ApiClient(sl<AppSecureStorage>()));

  // 3. NetworkInfo (depende de Connectivity)
  // DEJA SOLO ESTA LÍNEA (la duplicada debe borrarse)
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());

  // ========================
  // CARRITO
  // ========================
  sl.registerLazySingleton<CarritoLocalDataSource>(
        () => CarritoLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<CarritoRepository>(
        () => CarritoRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetCarrito(sl()));
  sl.registerLazySingleton(() => AddItemToCarrito(sl()));
  sl.registerLazySingleton(() => RemoveItemFromCarrito(sl()));
  sl.registerLazySingleton(() => ClearCarrito(sl()));
  sl.registerFactory(() => CarritoCubit(
    getCarrito: sl(),
    addItemToCarrito: sl(),
    removeItemFromCarrito: sl(),
    clearCarrito: sl(),
  ));
}

