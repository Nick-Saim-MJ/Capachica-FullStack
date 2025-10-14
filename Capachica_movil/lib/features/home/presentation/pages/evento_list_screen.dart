// lib/features/home/presentation/pages/evento_list_screen.dart
import 'package:aplicativo_capachica/core/widgets/shimmer_loading.dart';
import 'package:aplicativo_capachica/features/home/presentation/bloc/evento_bloc.dart';
import 'package:aplicativo_capachica/features/home/presentation/pages/evento_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/evento_model.dart';
import '../widgets/evento_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/repositories/evento_repository.dart' as ev_repo;
import 'evento_form_screen.dart';

// 👇 importa tu storage para leer los roles guardados tras login
import 'package:aplicativo_capachica/core/storage/secure_storage.dart';

class EventoListScreen extends StatefulWidget {
  final String? tipoFiltro; // 'activos', 'proximos', 'emprendedor'
  final int? emprendedorId;

  const EventoListScreen({Key? key, this.tipoFiltro, this.emprendedorId}) : super(key: key);

  @override
  State<EventoListScreen> createState() => _EventoListScreenState();
}

class _EventoListScreenState extends State<EventoListScreen> {
  final ScrollController _scrollController = ScrollController();

  // 👇 flag local para controlar permisos en UI
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _resolveAdminFlag();   // <-- lee roles del storage
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _resolveAdminFlag() async {
    try {
      final storage = AppSecureStorage();
      // asume que tienes un getter que devuelve List<String>
      final roles = await storage.getRoles(); // e.g. ["admin", "user"]
      final normalized = roles.map((r) => r.toLowerCase()).toList();
      final isAdmin = normalized.contains('admin'); // regla: sólo admins ven acciones
      if (mounted) setState(() => _isAdmin = isAdmin);
    } catch (_) {
      // en caso de error, por seguridad ocultamos acciones
      if (mounted) setState(() => _isAdmin = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    switch (widget.tipoFiltro) {
      case 'activos':
        context.read<EventoBloc>().add(LoadEventosActivos());
        break;
      case 'proximos':
        context.read<EventoBloc>().add(LoadProximosEventos());
        break;
      case 'emprendedor':
        if (widget.emprendedorId != null) {
          context.read<EventoBloc>().add(LoadEventosByEmprendedor(widget.emprendedorId!));
        }
        break;
      default:
        context.read<EventoBloc>().add(LoadEventos(refresh: true));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (widget.tipoFiltro == null) {
        final state = context.read<EventoBloc>().state;
        if (state is EventoLoaded && state.hasMore) {
          context.read<EventoBloc>().add(LoadEventos(page: state.currentPage));
        }
      }
    }
  }

  Future<void> _confirmDelete(EventoModel e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text('¿Seguro que deseas eliminar “${e.nombre}”?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) context.read<EventoBloc>().add(DeleteEvento(e.id));
  }

  Future<void> _openCreate() async {
    final repo = context.read<ev_repo.EventoRepository>();
    final res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider<ev_repo.EventoRepository>.value(
          value: repo,
          child: BlocProvider<EventoBloc>.value(
            value: context.read<EventoBloc>(),
            child: const EventoFormScreen(),
          ),
        ),
      ),
    );
    if (res == true) _loadInitialData();
  }

  Future<void> _openEdit(EventoModel e) async {
    final repo = context.read<ev_repo.EventoRepository>();
    final res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider<ev_repo.EventoRepository>.value(
          value: repo,
          child: BlocProvider<EventoBloc>.value(
            value: context.read<EventoBloc>(),
            child: EventoFormScreen(evento: e),
          ),
        ),
      ),
    );
    if (res == true) _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final canCreateHere = widget.tipoFiltro == null && _isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.tipoFiltro == null)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterDialog),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadInitialData),
        ],
      ),

      // 👇 Sólo admins ven el FAB de Crear
      floatingActionButton: canCreateHere
          ? FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Crear'),
        backgroundColor: Colors.amber[800],
      )
          : null,

      body: BlocConsumer<EventoBloc, EventoState>(
        listener: (context, state) {
          if (state is EventoError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
          if (state is EventoDeleted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Evento eliminado'), backgroundColor: Colors.green));
            _loadInitialData();
          }
          if (state is EventoCreated) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Evento creado'), backgroundColor: Colors.green));
            _loadInitialData();
          }
          if (state is EventoUpdated) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Evento actualizado'), backgroundColor: Colors.green));
            _loadInitialData();
          }
        },
        buildWhen: (previous, state) =>
        state is EventoLoading ||
            state is EventoError ||
            state is EventoLoaded ||
            state is EventosActivosLoaded ||
            state is ProximosEventosLoaded ||
            state is EventosByEmprendedorLoaded,
        builder: (context, state) {
          if (state is EventoLoading) return _buildLoadingState();
          if (state is EventoError) return _buildErrorState(state.message);

          List<EventoModel> eventos = [];
          bool hasMore = false;
          if (state is EventoLoaded) {
            eventos = state.eventos;
            hasMore = state.hasMore;
          } else if (state is EventosActivosLoaded) {
            eventos = state.eventos;
          } else if (state is ProximosEventosLoaded) {
            eventos = state.eventos;
          } else if (state is EventosByEmprendedorLoaded) {
            eventos = state.eventos;
          }

          if (eventos.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () async => _loadInitialData(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: eventos.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= eventos.length) return _buildLoadingMore();
                final e = eventos[index];
                return EventoCard(
                  evento: e,
                  onTap: () async {
                    final repo = context.read<ev_repo.EventoRepository>();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RepositoryProvider<ev_repo.EventoRepository>.value(
                          value: repo,
                          child: BlocProvider<EventoBloc>(
                            create: (_) => EventoBloc(repo)..add(LoadEventoById(e.id)),
                            child: EventoDetailScreen(eventoId: e.id),
                          ),
                        ),
                      ),
                    );
                  },
                  // 👇 Sólo admins ven Editar y Eliminar
                  onEdit: _isAdmin ? () => _openEdit(e) : null,
                  onDelete: _isAdmin ? () => _confirmDelete(e) : null,
                  showActions: _isAdmin,
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getTitle() {
    switch (widget.tipoFiltro) {
      case 'activos':
        return AppStrings.eventosActivos;
      case 'proximos':
        return AppStrings.proximosEventos;
      case 'emprendedor':
        return AppStrings.eventosEmprendedor;
      default:
        return AppStrings.eventos;
    }
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const ShimmerLoading(
        child: Card(child: SizedBox(height: 200, width: double.infinity)),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(AppStrings.errorCargarEventos,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadInitialData, child: const Text(AppStrings.reintentar)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(AppStrings.noEventosDisponibles,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(AppStrings.noEventosDescripcion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center),
          if (widget.tipoFiltro == null && _isAdmin) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _openCreate, child: const Text(AppStrings.crearEvento)),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.filtrarEventos),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(AppStrings.todosLosEventos),
              onTap: () {
                Navigator.of(context).pop();
                context.read<EventoBloc>().add(LoadEventos(refresh: true));
              },
            ),
            ListTile(
              title: const Text(AppStrings.eventosActivos),
              onTap: () {
                Navigator.of(context).pop();
                context.read<EventoBloc>().add(LoadEventosActivos());
              },
            ),
            ListTile(
              title: const Text(AppStrings.proximosEventos),
              onTap: () {
                Navigator.of(context).pop();
                context.read<EventoBloc>().add(LoadProximosEventos());
              },
            ),
          ],
        ),
      ),
    );
  }
}