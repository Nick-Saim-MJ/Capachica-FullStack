import 'package:aplicativo_capachica/core/error/failures.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';
import 'package:dartz/dartz.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class CreateServicio implements UseCase<ServiceEntity, ServiceEntity> {
  final ServiceRepository repository;

  CreateServicio({required this.repository});
  @override
  Future<Either<Failure, ServiceEntity>> call(ServiceEntity service) async {
    return repository.createServicio(service);
  }
}