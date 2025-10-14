
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';

class ServicioLocalDataSource {
  // Simulación de una base de datos local
  List<ServicioCapachica> _cachedServices = [];

  Future<void> cacheServices(List<ServicioCapachica> services) async {
    // Aquí iría la lógica para guardar los datos en SQLite, Hive, etc.
    _cachedServices = services;
    print('Services cached locally.');
  }

  Future<List<ServicioCapachica>> getCachedServices() async {
    // Aquí iría la lógica para obtener los datos de la base de datos local
    if (_cachedServices.isNotEmpty) {
      print('Returning services from local cache.');
      return _cachedServices;
    } else {
      throw Exception('No local data found.');
    }
  }
}