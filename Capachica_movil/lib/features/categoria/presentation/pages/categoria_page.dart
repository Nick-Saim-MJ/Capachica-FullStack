// category_page.dart

import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import 'categoria_form.dart';

class CategoryPage extends StatefulWidget {
  final bool isAdmin;
  final bool isEmprendedor;
  final bool isMod;
  const CategoryPage({
    super.key,
    required this.isAdmin,
    required this.isEmprendedor,
    required this.isMod,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(LoadCategories());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Lógica de la Vista ---

  Future<void> _onRefresh(BuildContext context) async {
    final categoryBloc = context.read<CategoryBloc>();
    _searchController.clear();
    categoryBloc.add(ClearFilters());
    categoryBloc.add(RefreshCategories());
  }

  Widget _buildSearchAndFilters(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar categorías...',
          prefixIcon: Icon(Icons.search, color: Colors.amber[800]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.amber[800]),
            onPressed: () {
              _searchController.clear();
              context.read<CategoryBloc>().add(const SearchCategoryChanged(''));

              setState(() {});
            },
          )
              : const SizedBox.shrink(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          filled: true,
        ),
        onChanged: (value) {
          context.read<CategoryBloc>().add(SearchCategoryChanged(value));
          setState(() {});
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, bool isDark, String error) {
    return Center(
      child: Text('Error al cargar: $error', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 50, color: Colors.amber[800]),
          const SizedBox(height: 10),
          Text(
            'No se encontraron categorías.',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          TextButton(
            onPressed: () => _onRefresh(context),
            style: TextButton.styleFrom(foregroundColor: Colors.amber[800]),
            child: const Text('Recargar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    bool isDark,
    List<CategoryEntity> categories,
  ) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[800]!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.label, color: Colors.amber[800]),
              ),
              title: Text(
                category.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(category.descripcion ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: Colors.amber[800]),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CategoryFormPage(category: category),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context, category);
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryFormPage(category: category),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  void _confirmDelete(BuildContext context, CategoryEntity category) {
    final categoryBloc = context.read<CategoryBloc>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar la categoría "${category.nombre}"? Esta acción es irreversible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Intentando eliminar "${category.nombre}"...')),
                );
                categoryBloc.add(DeleteCategoryEvent(category.id));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Categorías',
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
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar categoría',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CategoryFormPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: widget.isAdmin
          ? Column(
              children: [
                _buildSearchAndFilters(context, isDark),
                Expanded(
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      final categories = state.categories;

                      if (state.isLoading && categories.isEmpty) {
                        return _buildLoadingState(isDark);
                      } else if (state.error.isNotEmpty && categories.isEmpty) {
                        return _buildErrorState(context, isDark, state.error);
                      } else if (categories.isEmpty) {
                        return _buildEmptyState(context, isDark);
                      } else {
                        return _buildCategoriesList(
                          context,
                          isDark,
                          categories,
                        );
                      }
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'No tienes permisos para ver esta página.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}