import 'package:aplicativo_capachica/features/admin/presentation/bloc/admin_plans_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ===== EVENTOS =====
import '../../features/home/presentation/pages/evento_list_screen.dart';
import '../../features/home/presentation/pages/evento_detail_screen.dart';
import '../../features/home/presentation/pages/evento_form_screen.dart';
import '../../features/home/data/models/evento_model.dart';

// ===== ADMIN =====
import 'package:aplicativo_capachica/features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_plans_list_page.dart';
import '../../features/admin/presentation/pages/admin_plan_form_page.dart';
import '../../features/admin/data/models/admin_plan_model.dart';
import '../../features/admin/presentation/bloc/admin_plans_bloc.dart';

// ===== ADMIN PLAN INSCRIPCIÓN =====
import '../../features/adminplaninscripcion/presentation/pages/plan_inscripcion_list_page.dart';
import '../../features/adminplaninscripcion/presentation/pages/plan_inscripcion_form_page.dart';
import '../../features/adminplaninscripcion/presentation/bloc/plan_inscripcion_bloc.dart';

// ===== APP CORE =====
import '../../injection_container.dart' as di;
import '../../features/admin/presentation/widgets/admin_guard.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRoutes {
  // =========================================================================
  // RUTAS NOMBRADAS
  // =========================================================================
  static const String inicial = '/';
  static const String login = '/login';

  // Eventos
  static const String eventos = '/eventos';
  static const String eventosActivos = '/eventos-activos';
  static const String proximosEventos = '/proximos-eventos';
  static const String eventosByEmprendedor = '/eventos-emprendedor';
  static const String eventoDetail = '/evento-detail';
  static const String eventoCreate = '/evento-create';
  static const String eventoEdit = '/evento-edit';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminPlans = '/admin/plans';
  static const String adminPlanForm = '/admin/plan-form';
  static const String adminPlanInscripciones = '/admin/plan-inscripciones';
  static const String adminPlanInscripcionForm = '/admin/plan-inscripcion-form';

  // =========================================================================
  // GENERADOR DE RUTAS
  // =========================================================================
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // ==========================================================
    // PANTALLA PRINCIPAL / LOGIN
    // ==========================================================
      case inicial:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

    // ==========================================================
    // EVENTOS
    // ==========================================================
      case eventos:
        return MaterialPageRoute(
          builder: (_) => const EventoListScreen(),
          settings: settings,
        );

      case eventosActivos:
        return MaterialPageRoute(
          builder: (_) => const EventoListScreen(tipoFiltro: 'activos'),
          settings: settings,
        );

      case proximosEventos:
        return MaterialPageRoute(
          builder: (_) => const EventoListScreen(tipoFiltro: 'proximos'),
          settings: settings,
        );

      case eventosByEmprendedor:
        final emprendedorId = settings.arguments as int?;
        if (emprendedorId == null) {
          return _errorRoute('ID de emprendedor requerido');
        }
        return MaterialPageRoute(
          builder: (_) => EventoListScreen(
            tipoFiltro: 'emprendedor',
            emprendedorId: emprendedorId,
          ),
          settings: settings,
        );

      case eventoDetail:
        final eventoId = settings.arguments as int?;
        if (eventoId == null) {
          return _errorRoute('ID de evento requerido');
        }
        return MaterialPageRoute(
          builder: (_) => EventoDetailScreen(eventoId: eventoId),
          settings: settings,
        );

      case eventoCreate:
        return MaterialPageRoute(
          builder: (_) => const EventoFormScreen(),
          settings: settings,
        );

      case eventoEdit:
        final evento = settings.arguments as EventoModel?;
        if (evento == null) {
          return _errorRoute('Datos del evento requeridos');
        }
        return MaterialPageRoute(
          builder: (_) => EventoFormScreen(evento: evento),
          settings: settings,
        );

    // ==========================================================
    // ADMINISTRACIÓN
    // ==========================================================
      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminGuard(
            child: AdminDashboardPage(),
          ),
          settings: settings,
        );

      case adminPlans:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
            di.sl<AdminPlansBloc>()..add(LoadAdminPlans()),
            child: const AdminGuard(
              child: AdminPlansListPage(),
            ),
          ),
          settings: settings,
        );

    // ==========================================================
    // >>>>>>>>>>>> CAMBIO CLAVE REALIZADO AQUÍ <<<<<<<<<<<<<<<
    // ==========================================================
      case adminPlanForm:
        final plan = settings.arguments as AdminPlanModel?;
        return MaterialPageRoute(
          // ✅ Se envuelve la página del formulario con su propio BlocProvider.
          builder: (_) => BlocProvider(
            create: (context) => di.sl<AdminPlansBloc>(),
            child: AdminPlanFormPage(initialPlan: plan),
          ),
          settings: settings,
        );

      case adminPlanInscripciones:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<PlanInscripcionBloc>(),
            child: const AdminGuard(
              child: PlanInscripcionListPage(),
            ),
          ),
          settings: settings,
        );

    // ==========================================================
    // ERROR POR DEFECTO
    // ==========================================================
      default:
        return _errorRoute('Ruta no encontrada: ${settings.name}');
    }
  }

  // =========================================================================
  // RUTA DE ERROR PERSONALIZADA
  // =========================================================================
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error de navegación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}