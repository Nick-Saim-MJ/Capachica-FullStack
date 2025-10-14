import 'package:aplicativo_capachica/core/error/failures.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';
import 'package:dartz/dartz.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
class ToggleServicioEstado implements UseCase<ServiceEntity, ServiceEntity> {
  final ServiceRepository repository;

  ToggleServicioEstado({required this.repository});

  @override
  Future<Either<Failure, ServiceEntity>> call(ServiceEntity currentService) async {
    final updatedService = currentService.copyWith(
      estado: !currentService.estado,
    );
    return repository.updateService(updatedService);
  }
}