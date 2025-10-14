// asociaciones_by_location_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/asociacion_bloc.dart';
import '../bloc/asociacion_event.dart';
import '../bloc/asociacion_state.dart';
import 'asociacion_detail_page.dart';

class AsociacionesByLocationPage extends StatefulWidget {
  const AsociacionesByLocationPage({super.key});

  @override
  State<AsociacionesByLocationPage> createState() => _AsociacionesByLocationPageState();
}

class _AsociacionesByLocationPageState extends State<AsociacionesByLocationPage> {
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();
  final TextEditingController _distanciaController = TextEditingController(text: '10.0');

  @override
  void dispose() {
    _latitudController.dispose();
    _longitudController.dispose();
    _distanciaController.dispose();
    super.dispose();
  }

  void _searchAsociaciones() {
    final latitud = double.tryParse(_latitudController.text);
    final longitud = double.tryParse(_longitudController.text);
    final distancia = double.tryParse(_distanciaController.text) ?? 10.0;

    if (latitud != null && longitud != null) {
      context.read<AsociacionBloc>().add(SearchAsociacionesByLocation(
        latitud: latitud,
        longitud: longitud,
        distancia: distancia,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese coordenadas válidas'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asociaciones por Ubicación'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latitudController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Latitud',
                          hintText: 'Ej: -12.0464',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.my_location),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _longitudController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Longitud',
                          hintText: 'Ej: -77.0428',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.my_location),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _distanciaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Distancia (km)',
                    hintText: 'Radio de búsqueda en kilómetros',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.radio_button_unchecked),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _searchAsociaciones,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Asociaciones Cercanas'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingrese sus coordenadas para encontrar asociaciones cercanas',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<AsociacionBloc, AsociacionState>(
              builder: (context, state) {
                if (state is AsociacionesByLocationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AsociacionesByLocationError) {
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
                } else if (state is AsociacionesByLocationLoaded) {
                  if (state.asociaciones.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron asociaciones en el área especificada',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intente aumentar el radio de búsqueda',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.blue[50],
                        child: Text(
                          'Se encontraron ${state.asociaciones.length} asociaciones en un radio de ${state.distancia} km',
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.asociaciones.length,
                          itemBuilder: (context, index) {
                            final asociacion = state.asociaciones[index];
                            return _AsociacionCard(asociacion: asociacion);
                          },
                        ),
                      ),
                    ],
                  );
                }
                
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_searching,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ingrese sus coordenadas para buscar asociaciones cercanas',
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
            if (asociacion.latitud != null && asociacion.longitud != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.my_location, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${asociacion.latitud!.toStringAsFixed(4)}, ${asociacion.longitud!.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12),
                  ),
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


