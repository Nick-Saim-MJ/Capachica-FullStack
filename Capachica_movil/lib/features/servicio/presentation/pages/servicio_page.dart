// Archivo: lib/presentation/screens/service_screen.dart

import 'package:aplicativo_capachica/core/storage/secure_storage.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_bloc.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_event.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/pages/categoria_page.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/entities/emprendedor.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/bloc/emprendedor_bloc.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/bloc/emprendedor_event.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_bloc.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_event.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_state.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/pages/servicio_card.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/pages/servicio_detail_page.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/pages/servicio_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceScreen extends StatefulWidget {
  final Future<List<EmprendedorEntity>> emprendedoresFuture;
  const ServiceScreen({super.key, required this.emprendedoresFuture});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AppSecureStorage _secureStorage = AppSecureStorage();

  List<String> _userRoles = [];

  bool _isAdmin = false;
  bool _isEmprendedor = false;
  bool _isMod = false;
  bool _isUser = false;


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserRoles() async {
    try {
      final roles = await _secureStorage.getRoles();
      print('✅ Roles obtenidos en ServicioPage: $roles');
      setState(() {
        _userRoles = roles;
      });
    } catch (e) {
      print('❌ Error al obtener los roles: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserRoles();
    _checkUserPermissions();

    // 💡 Disparar la carga de los BLoCs auxiliares al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carga de servicios principal
      context.read<ServicioBloc>().add(LoadServicios());

      // Carga de BLoCs auxiliares para el formulario futuro
      context.read<EmprendedorBloc>().add(LoadEmprendedores());
      context.read<CategoryBloc>().add(LoadCategories());
    });
  }

  Future<void> _checkUserPermissions() async {
    try {
      final roles = await _secureStorage.getRoles();
      print('Roles obtenidos en ServicioPage: $roles');

      final isAdmin = roles.contains('admin');
      final isEmprendedor = roles.contains('emprendedor');
      final isMod = roles.contains('moderador');
      final isUser = roles.contains('user');

      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
          _isEmprendedor = isEmprendedor;
          _isMod = isMod;
          _isUser = isUser;
        });
      }

    } catch (e) {
      print('Error al obtener los roles: $e');
    }
  }

  Future<void> _onRefresh(BuildContext context) async {
    final servicioBloc = context.read<ServicioBloc>();
    _searchController.clear();
    servicioBloc.add(LimpiarFiltros());
    servicioBloc.add(LoadServicios());
  }

  @override
  Widget build(BuildContext context) {

    context.read<ServicioBloc>().add(LoadServicios());

    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1419)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () =>
              Navigator.of(context).pop(),
        ),
        title: const Text(
          'Servicios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.amber.shade700, Colors.amber.shade800]
                  : [Colors.amber.shade600, Colors.amber.shade800],
            ),
          ),
        ),
        actions: [
          /*CartIconWithBadge(),
          ThemeToggleButton(),*/
          if (_isAdmin)
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar servicio',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ServicioForm(
                  isAdmin: _isAdmin,
                  isEmprendedor: _isEmprendedor,
                  isMod: _isMod,
                ), // No se pasa 'servicio'
              ));
            },
          ),
          if (_isAdmin)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CategoryPage(
                  isAdmin: _isAdmin,
                  isEmprendedor: _isEmprendedor,
                  isMod: _isMod,), // No se pasa 'servicio'
              ));
            },
            icon: const Icon(Icons.account_balance, size: 20),
            label: const Text('Ver Categorías'),
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(context, isDark),
          Expanded(
            child: BlocBuilder<ServicioBloc, ServicioState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return _buildLoadingState(isDark);
                } else if (state.error.isNotEmpty) {
                  return _buildErrorState(context, isDark, state.error);
                } else if (state.serviciosFiltrados.isEmpty) {
                  return _buildEmptyState(context, isDark);
                } else {
                  return _buildServicesList(
                    context,
                    isDark,
                    state.serviciosFiltrados,
                    bottomSafeArea,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de construcción de estado (sin cambios significativos, solo un ajuste menor)
  Widget _buildSearchAndFilters(BuildContext context, bool isDark) {
    return BlocBuilder<ServicioBloc, ServicioState>(
      builder: (context, state) {
        final bloc = context.read<ServicioBloc>();
        final categorias = _getCategoriasUnicas(state.servicios);

        if (_searchController.text != state.searchQuery) {
          _searchController.value = _searchController.value.copyWith(
            text: state.searchQuery,
            selection: TextSelection.collapsed(
              offset: state.searchQuery.length,
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchTextField(context, isDark, bloc, state),
              const SizedBox(height: 16),

              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: ExpansionTileThemeData(
                    tilePadding: EdgeInsets.zero,
                    iconColor: isDark ? Colors.white70 : Colors.grey.shade700,
                    collapsedIconColor: isDark
                        ? Colors.white70
                        : Colors.grey.shade700,
                  ),
                ),
                child: ExpansionTile(
                  // Título del desplegable
                  title: Text(
                    'Filtros Avanzados (${_getActiveFilterCount(state)})',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF374151),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Contenido que se muestra al expandir
                  children: [
                    const SizedBox(height: 8),
                    // Filtros de categorías
                    if (categorias.isNotEmpty)
                      _buildCategoryFilters(
                        context,
                        isDark,
                        bloc,
                        state,
                        categorias,
                      ),

                    if (categorias.isNotEmpty && state.servicios.isNotEmpty)
                      const SizedBox(height: 16),

                    // Nuevo Combo Box para filtrar por Emprendedor
                    _buildEmprendedorFilter(context, isDark, bloc, state),

                    const SizedBox(height: 16),

                    _buildLimpiarButton(isDark, bloc, state),
                    
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchTextField(
    BuildContext context,
    bool isDark,
    ServicioBloc bloc,
    ServicioState state,
  ) {
    return TextField(
      controller: _searchController,
      onChanged: (query) {
        bloc.add(BuscarServicios(query));
      },
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1A202C),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar servicios...',
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.grey.shade500,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Colors.amber[800],
          size: 20,
        ),
        suffixIcon: state.searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: Colors.amber[800],
                  size: 20,
                ),
                onPressed: () {
                  //_searchController.clear();
                  bloc.add(LimpiarFiltros());
                },
              )
            : const SizedBox.shrink(),
        filled: true,
        fillColor: isDark
            ? const Color(0xFF334155).withOpacity(0.3)
            : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.amber.shade800,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(
    BuildContext context,
    bool isDark,
    ServicioBloc bloc,
    ServicioState state,
    List<String> categorias,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtrar por categoría:',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'Todas',
                state.categoriaSeleccionada == 0,
                () => bloc.add(LimpiarFiltros()),
                isDark,
              ),
              const SizedBox(width: 8),
              ...categorias.map((categoria) {
                final categoriaEncontrada = state.servicios
                    .expand((s) => s.categorias)
                    .firstWhere(
                      (cat) => cat.nombre == categoria,
                      orElse: () => CategoryEntity(
                        id: 0,
                        nombre: '',
                        descripcion: '',
                        iconoUrl: '',
                        createdAt: '',
                        updatedAt: '',
                      ),
                    );
                final categoriaId = categoriaEncontrada.id;
                final isSelected = state.categoriaSeleccionada == categoriaId;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(categoria, isSelected, () {
                    if (categoriaId != 0) {
                      bloc.add(FiltrarPorCategoria(categoriaId));
                    }
                  }, isDark),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmprendedorFilter(
      BuildContext context,
      bool isDark,
      ServicioBloc bloc,
      ServicioState state,
      ) {
    return FutureBuilder<List<EmprendedorEntity>>(
      future: widget.emprendedoresFuture,

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          );
        }

        if (snapshot.hasError) {
          // Capturamos el error del Future
          final errorMessage = snapshot.error.toString();
          return Center(
            child: Text(
              'Error al cargar emprendedores: $errorMessage',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.redAccent,
                fontSize: 14,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          final emprendedores = snapshot.data!;

          if (emprendedores.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar por emprendedor:',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF374151),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF334155).withOpacity(0.3)
                      : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A202C),
                ),
                // Aseguramos que el valor seleccionado sea 0 si es nulo o inválido
                value: emprendedores.any((e) => e.id == state.emprendedorSeleccionadoId)
                    ? state.emprendedorSeleccionadoId
                    : 0,

                items: [
                  const DropdownMenuItem<int>(
                    value: 0,
                    child: Text('Todos los emprendedores'),
                  ),
                  ...emprendedores.map((emprendedor) {
                    return DropdownMenuItem<int>(
                      value: emprendedor.id,
                      child: Text(emprendedor.nombre),
                    );
                  }).toList(),
                ],
                onChanged: (int? emprendedorId) {
                  if (emprendedorId != null && emprendedorId > 0) {
                    bloc.add(FiltrarPorEmprendedor(emprendedorId));
                  } else {
                    bloc.add(LimpiarFiltrosEmprendedor());
                  }
                },
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLimpiarButton(
      bool isDark,
      ServicioBloc bloc,
      ServicioState state,
      ) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Color(0xFF3B82F6) : Colors.lightBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
          ),
          onPressed: () {
            bloc.add(LimpiarFiltros());
            bloc.add(LimpiarFiltrosEmprendedor());
          },
          icon: const Icon(Icons.clear_rounded, size: 20),
          label: const Text('Limpiar filtros'),
        )
    );
  }

  int _getActiveFilterCount(ServicioState state) {
    int count = 0;
    if (state.searchQuery.isNotEmpty) {
      count++;
    }
    if (state.categoriaSeleccionada > 0) {
      count++;
    }
    if (state.emprendedorSeleccionadoId > 0) {
      count++;
    }
    return (state.categoriaSeleccionada > 0 ? 1 : 0) +
        (state.emprendedorSeleccionadoId > 0 ? 1 : 0);
  }

  // Helper method para los FilterChip
  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected
              ? isDark
                    ? Colors.white
                    : Colors.white
              : isDark
              ? Colors.white
              : Colors.black54,
        ),
      ),
      backgroundColor: isSelected
          ? isDark
                ? const Color(0xFF3B82F6)
                : Colors.lightBlue
          : isDark
          ? const Color(0xFF334155).withOpacity(0.5)
          : const Color(0xFFF8FAFC),
      side: BorderSide(
        color: isSelected
            ? isDark
                  ? const Color(0xFF3B82F6)
                  : Colors.lightBlue
            : isDark
            ? Colors.white10
            : Colors.grey.shade200,
        width: 1.5,
      ),
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  List<String> _getCategoriasUnicas(List<ServiceEntity> servicios) {
    final categorias = <String>{};
    if (servicios.isEmpty) return [];

    for (final servicio in servicios) {
      for (final categoria in servicio.categorias) {
        if (categoria.nombre.isNotEmpty) {
          categorias.add(categoria.nombre);
        }
      }
    }
    return categorias.toList()..sort();
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark
              ? Color(0xFF2D3748).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Color(0xFF3B82F6) : Colors.lightBlue,
              ),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Cargando servicios...',
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A202C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Obteniendo servicios disponibles',
              style: TextStyle(
                color: isDark ? Colors.white70 : Color(0xFF718096),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ServicioBloc>().add(LoadServicios());
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context,
      bool isDark,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                text: 'No se encontraron servicios.\n',
                children: [
                  TextSpan(
                    text: 'Intenta ajustar tus filtros o búsqueda.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _onRefresh(context),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Recargar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(
    BuildContext context,
    bool isDark,
    List<ServiceEntity> services,
      double bottomPadding,
      ) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: isDark ? const Color(0xFF3B82F6) : Colors.lightBlue,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + bottomPadding),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];

          return ServiceCard(
            servicio: service,
            isAdmin: _isAdmin,
            isEmprendedor: _isEmprendedor,
            isMod: _isMod,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailScreen(servicio: service),
                ),
              );
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServicioForm(
                    servicio: service,
                    isAdmin: _isAdmin,
                    isEmprendedor: _isEmprendedor,
                    isMod: _isMod,),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
Widget _buildActionButton(
    BuildContext context, {
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed,
    }) {
  // Usamos Expanded para que los 4 botones ocupen el mismo ancho
  return Expanded(
    child: Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 20),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}