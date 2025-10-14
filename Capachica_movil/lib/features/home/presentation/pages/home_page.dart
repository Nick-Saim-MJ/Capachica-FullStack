// lib/features/home/presentation/pages/home_page.dart
import 'package:aplicativo_capachica/features/emprendedores/presentation/bloc/emprendedor_bloc.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/bloc/emprendedor_event.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/pages/emprendedor_page.dart';
import 'package:aplicativo_capachica/core/widgets/role_visibility.dart';
import 'package:aplicativo_capachica/features/municipalidades/presentation/bloc/municipalidad_bloc.dart';
import 'package:aplicativo_capachica/features/municipalidades/presentation/bloc/municipalidad_event.dart' as muni_events;
import 'package:aplicativo_capachica/features/municipalidades/presentation/pages/municipalidad_page.dart';
import 'package:aplicativo_capachica/core/routes/app_routes.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/pages/servicio_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../plans/presentation/pages/plans_feed_page.dart';
import 'evento_list_screen.dart';

// Eventos
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/evento_repository.dart' as ev_repo;
import '../../presentation/bloc/evento_bloc.dart';

// Asociaciones
import '../../../asociaciones/presentation/pages/asociaciones_page.dart';
import '../../../asociaciones/presentation/bloc/asociacion_bloc.dart';
import '../../../asociaciones/presentation/bloc/asociacion_event.dart' as aso_events; // Usar alias para evitar colisiones

// Perfil
import '../../../auth/presentation/cubit/profile_cubit.dart';
import '../../../auth/presentation/pages/profile_page.dart';

// Inyección de dependencias
import '../../../../injection_container.dart' as di;
// Carrito
import '../../../carrito/presentation/widgets/carrito_icon_with_badge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final storage = di.sl<AppSecureStorage>();
    final roles = await storage.getRoles();
    if (!mounted) return;
    setState(() => _isAdmin = roles.any((rol) => rol.toLowerCase() == 'admin'));
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      if (_selectedIndex != 0) {
        setState(() => _selectedIndex = 0);
      }
    } else {
      _navigateToIndex(index);
    }
  }

  void _navigateToIndex(int index) {
    Widget? page;
    switch (index) {
      case 1:
        page = BlocProvider(
          create: (_) => di.sl<EmprendedorBloc>()..add(LoadEmprendedores()),
          child: const EmprendedorPage(),
        );
        break;
      case 2:
        page = BlocProvider<AsociacionBloc>(
          create: (_) => di.sl<AsociacionBloc>()..add(aso_events.LoadAsociaciones()),
          child: const AsociacionesPage(),
        );
        break;
      case 3:
        page = BlocProvider<EventoBloc>(
          create: (_) => di.sl<EventoBloc>()..add(LoadEventos(refresh: true)),
          child: const EventoListScreen(),
        );
        break;
      case 4:
        page = BlocProvider<ProfileCubit>(
          create: (_) => di.sl<ProfileCubit>(),
          child: const ProfilePage(),
        );
        break;
    }
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: _isAdmin
          ? _AdminEndDrawer(onNavigate: (routeName) {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
      })
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isAdmin
            ? Builder(
                builder: (ctx) => IconButton(
                  tooltip: 'Panel de Administración',
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : const CarritoIconWithBadge(
                iconColor: Colors.white,
              ),
        actions: _isAdmin
            ? const [
                // Si es admin, mostramos el carrito a la derecha para no reemplazar el menú
                CarritoIconWithBadge(),
              ]
            : const [],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/1fff4d1dd5f2d790e9cd3f62ad74549e.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          const _HomePageContent(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Emprendimientos'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_2_outlined), label: 'Asociaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Eventos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
      ),
    );
  }
}

// Contenido de la Home Page
class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const Text(
              'Turismo Capachica',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 10.0, color: Colors.black54, offset: Offset(2.0, 2.0))
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Descubre la magia del lago Titicaca',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400),
            ),
            const Spacer(flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PlansFeedPage()));
                    },
                    icon: const Icon(Icons.collections_bookmark_outlined, color: Colors.white),
                    label: const Text('Ver Planes', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: Colors.white54, width: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceScreen(
                            emprendedoresFuture: di.sl<EmprendedorBloc>().getPublicEmprendedores(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.explore_outlined, color: Colors.orange),
                    label: const Text('Servicios', style: TextStyle(color: Colors.orange)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: Colors.orange, width: 1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RoleVisibility(
              anyOf: const ['admin'],
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => di.sl<MunicipalidadBloc>()..add(muni_events.LoadMunicipalidades()),
                          child: const MunicipalidadPage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.location_city_outlined, color: Colors.orange),
                  label: const Text('Municipalidad', style: TextStyle(color: Colors.orange)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(color: Colors.orange, width: 1),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

// >>>>> CAMBIO 2: SE AÑADEN ENLACES AL DRAWER EXISTENTE <<<<<
class _AdminEndDrawer extends StatelessWidget {
  final void Function(String routeName) onNavigate;
  const _AdminEndDrawer({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

    return Drawer(
      child: Container(
        color: const Color(0xFF111318),
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                title: Text('Panel de Administración', style: headerStyle),
                subtitle: const Text('Solo administradores', style: TextStyle(color: Colors.white70)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Divider(color: Colors.white24),

              // --- ENLACES NUEVOS ---
              _AdminTile(
                icon: Icons.article_outlined,
                label: 'Gestionar Planes',
                onTap: () => onNavigate(AppRoutes.adminPlans),
              ),
              _AdminTile(
                icon: Icons.assignment_ind_outlined,
                label: 'Gestionar Inscripciones',
                onTap: () => onNavigate(AppRoutes.adminPlanInscripciones),
              ),
              const Divider(color: Colors.white24),

              // --- Tus enlaces existentes ---
              _AdminTile(
                icon: Icons.people_alt_outlined,
                label: 'Usuarios',
                onTap: () => onNavigate('/admin/users'),
              ),
              _AdminTile(
                icon: Icons.badge_outlined,
                label: 'Roles',
                onTap: () => onNavigate('/admin/roles'),
              ),
              _AdminTile(
                icon: Icons.vpn_key_outlined,
                label: 'Permisos',
                onTap: () => onNavigate('/admin/permissions'),
              ),

              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('v1.0.0', style: TextStyle(color: Colors.white30, fontSize: 12)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// El widget _AdminTile no necesita cambios
class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AdminTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.orangeAccent),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }
}