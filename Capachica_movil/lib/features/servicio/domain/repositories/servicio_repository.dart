import 'package:aplicativo_capachica/core/error/failures.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:dartz/dartz.dart';

abstract class ServiceRepository {

  Future<List<ServiceEntity>> getServices();

  Future<ServiceEntity?> getServicioById(int id);

  Future<List<ServiceEntity>> getServiciosByCategoria(int categoriaId);

  Future<List<ServiceEntity>> getServiciosByEmprendedor(int emprendedorId);
  Future<bool> verificarDisponibilidadServicio(
      int servicioId,
      String fecha,
      String horaInicio,
      String horaFin,
  );

  Future<Either<Failure, ServiceEntity>> createServicio(ServiceEntity service);

  Future<Either<Failure, ServiceEntity>> updateService(ServiceEntity service);

  Future<void> deleteService(int id);
  }