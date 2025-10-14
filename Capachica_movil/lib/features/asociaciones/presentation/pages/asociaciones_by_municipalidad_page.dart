// asociaciones_by_municipalidad_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/asociacion_bloc.dart';
import '../bloc/asociacion_event.dart';
import '../bloc/asociacion_state.dart';
import 'asociacion_detail_page.dart';

class AsociacionesByMunicipalidadPage extends StatefulWidget {
  const AsociacionesByMunicipalidadPage({super.key});

  @override
  State<AsociacionesByMunicipalidadPage> createState() => _AsociacionesByMunicipalidadPageState();
}

class _AsociacionesByMunicipalidadPageState extends State<AsociacionesByMunicipalidadPage> {
  final TextEditingController _municipalidadController = TextEditingController();
  int? _selectedMunicipalidadId;

  @override
  void dispose() {
    _municipalidadController.dispose();
    super.dispose();
  }

  void _searchAsociaciones() {
    final municipalidadId = int.tryParse(_municipalidadController.text);
    if (municipalidadId != null) {
      setState(() {
        _selectedMunicipalidadId = municipalidadId;
      });
      context.read<AsociacionBloc>().add(LoadAsociacionesByMunicipalidad(municipalidadId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese un ID de municipalidad válido'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asociaciones por Municipalidad'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _municipalidadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID de Municipalidad',
                    hintText: 'Ingrese el ID de la municipalidad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _searchAsociaciones,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Asociaciones'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AsociacionBloc, AsociacionState>(
              builder: (context, state) {
                if (state is AsociacionesByMunicipalidadLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AsociacionesByMunicipalidadError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _searchAsociaciones,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                } else if (state is AsociacionesByMunicipalidadLoaded) {
                  if (state.asociaciones.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron asociaciones para esta municipalidad',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.asociaciones.length,
                    itemBuilder: (context, index) {
                      final asociacion = state.asociaciones[index];
                      return _AsociacionCard(asociacion: asociacion);
                    },
                  );
                }
                
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ingrese un ID de municipalidad para buscar asociaciones',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AsociacionCard extends StatelessWidget {
  final dynamic asociacion;

  const _AsociacionCard({required this.asociacion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: asociacion.logo != null
              ? NetworkImage(asociacion.logo!)
              : null,
          child: asociacion.logo == null
              ? const Icon(Icons.business)
              : null,
        ),
        title: Text(
          asociacion.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(asociacion.descripcion),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(asociacion.direccion)),
              ],
            ),
            if (asociacion.telefono != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16),
                  const SizedBox(width: 4),
                  Text(asociacion.telefono),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AsociacionDetailPage(asociacionId: asociacion.id),
            ),
          );
        },
      ),
    );
  }
}


