// Archivo: lib/domain/usecases/get_services_usecase.dart
import 'package:aplicativo_capachica/features/servicio/data/models/mappers/servicio_mapper.dart';
import '../entities/servicio.dart';
import '../repositories/servicio_repository.dart';

class GetServicesUseCase {
  final ServiceRepository repository;

  GetServicesUseCase({required this.repository});

  Future<List<ServiceEntity>> execute() async {
    final servicesModels = await repository.getServices();

    // Mapea los modelos de datos a entidades
    return servicesModels.map((entity) => entity).toList();
  }
}