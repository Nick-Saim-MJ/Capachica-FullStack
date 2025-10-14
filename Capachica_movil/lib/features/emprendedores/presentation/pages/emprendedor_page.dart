import 'package:aplicativo_capachica/core/widgets/role_visibility.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/entities/emprendedor.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/pages/emprededor_card.dart';
import 'package:flutter/material.dart';
import 'emprendedor_form_page.dart';
import 'package:dio/dio.dart';
import 'package:aplicativo_capachica/core/config/backend_config.dart';

class EmprendedorPage extends StatefulWidget {
  const EmprendedorPage({super.key});

  @override
  _EmprendedorPageState createState() => _EmprendedorPageState();
}

class _EmprendedorPageState extends State<EmprendedorPage> {
  final Dio dio = Dio(BaseOptions(baseUrl: BackendConfig.baseUrl));

  List<EmprendedorEntity> _emprendedoresOriginal = [];
  List<EmprendedorEntity> _emprendedoresFiltrados = [];
  String _searchText = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmprendedores();
  }

  Future<void> _loadEmprendedores() async {
    setState(() => isLoading = true);

    int page = 1;
    List<EmprendedorEntity> allEmprendedores = [];

    try {
      while (true) {
        final response = await dio.get('/emprendedores', queryParameters: {'page': page});
        if (response.statusCode != 200) break;

        final dataList = response.data['data']['data'] as List<dynamic>;
        if (dataList.isEmpty) break;

        allEmprendedores.addAll(
            dataList.map((e) => EmprendedorEntityJson.fromJson(e as Map<String, dynamic>)).toList()
        );

        final currentPage = response.data['data']['current_page'] as int;
        final lastPage = response.data['data']['last_page'] as int;

        if (currentPage >= lastPage) break; // terminamos si llegamos a la última página
        page++; // siguiente página
      }

      _emprendedoresOriginal = allEmprendedores;
      _applyFilter();
    } catch (e) {
      print('Error cargando emprendedores: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }



  void _applyFilter() {
    if (_searchText.isEmpty) {
      _emprendedoresFiltrados = List.from(_emprendedoresOriginal);
    } else {
      _emprendedoresFiltrados = _emprendedoresOriginal
          .where((emp) => emp.nombre.toLowerCase().contains(_searchText))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emprendedores',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
            child: TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Buscar emprendedor...',
                hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                prefixIcon: Icon(Icons.search, color: Colors.amber[800]),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Colors.amber.shade800, width: 2),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                  _applyFilter();
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _emprendedoresFiltrados.isEmpty
                ? const Center(child: Text('No hay emprendedores disponibles'))
                : ListView.builder(
              itemCount: _emprendedoresFiltrados.length,
              itemBuilder: (context, index) {
                final emprendedor = _emprendedoresFiltrados[index];
                return EmprendedorCard(
                  emprendedor: emprendedor,
                  onUpdated: () async {
                    // Al editar o eliminar, recargar lista automáticamente
                    await _loadEmprendedores();
                  },
                );

              },
            ),
          ),
        ],
      ),
      floatingActionButton: RoleVisibility(
        anyOf: ['admin'],
        fallback: const SizedBox.shrink(),
        child: FloatingActionButton(
          backgroundColor: Colors.amber[800],
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmprendedorCreatePage(),
              ),
            ).then((_) => _loadEmprendedores()); // recarga después de crear
          },
        ),
      ),
    );
  }
}
