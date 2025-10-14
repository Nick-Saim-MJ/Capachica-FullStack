
import 'package:aplicativo_capachica/core/error/exceptions.dart';
import 'package:aplicativo_capachica/core/error/failures.dart';
import 'package:aplicativo_capachica/features/servicio/data/datasources/servicio_local_data_source.dart';
import 'package:aplicativo_capachica/features/servicio/data/datasources/servicio_remote_data_source.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/mappers/servicio_mapper.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/servicio.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServicioRemoteDataSource remoteDataSource;
  final ServicioLocalDataSource localDataSource;

  ServiceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<ServiceEntity>> getServices() async {
    try {
      final servicios = await remoteDataSource.fetchServicios();
      return servicios.map((e) => ServiceMapper.toEntity(e)).toList();
    } catch (e) {
      print("⚠️ Error en getServices Repository: $e");
      return [];
    }
  }
  @override
  Future<ServiceEntity?> getServicioById(int id) async {
    try {
      final servicio = await remoteDataSource.fetchServicioById(id);
      return ServiceMapper.toEntity(servicio);
    } catch (e) {
      print("⚠️ Error en getServicioById Repository: $e");
      return null;
    }
  }
  @override
  Future<List<ServiceEntity>> getServiciosByCategoria(int categoriaId) async {
    try {
      final servicios = await remoteDataSource.fetchServiciosByCategoria(categoriaId);
      return servicios.map((e) => ServiceMapper.toEntity(e)).toList();
    } catch (e) {
      print("⚠️ Error en getServiciosByCategoria Repository: $e");
      return [];
    }
  }
  @override
  Future<List<ServiceEntity>> getServiciosByEmprendedor(int emprendedorId) async {
    try {
      final servicios = await remoteDataSource.fetchServiciosByEmprendedor(emprendedorId);
      return servicios.map((e) => ServiceMapper.toEntity(e)).toList();
    } catch (e) {
      print("⚠️ Error en getServiciosByEmprendedor Repository: $e");
      return [];
    }
  }
  @override
  Future<bool> verificarDisponibilidadServicio(
     int servicioId,
     String fecha,
     String horaInicio,
     String horaFin,
  ) async {
    try {
      return await remoteDataSource.verificarDisponibilidadServicio(
        servicioId: servicioId,
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
      );
    } catch (e) {
      throw Exception('Error en el repositorio al verificar disponibilidad: $e');
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> createServicio(ServiceEntity service) async {
    try {
      final servicioDto = ServiceMapper.toDTO(service);
      final serviceModel = await remoteDataSource.createServicio(servicioDto);
      return Right(ServiceMapper.toEntity(serviceModel));
    } on Exception catch (e) {
      return Left(DataException(e.toString()) as Failure);
    }
  }

  // ----------------------------------------------------
  // 💡 UPDATE: Actualizar Servicio
  // ----------------------------------------------------
  @override
  Future<Either<Failure, ServiceEntity>> updateService(ServiceEntity service) async {
    try {
      if (service.id == 0) {
        return Left(DataException('No se puede actualizar un servicio sin un ID válido.') as Failure);
      }
      final servicioDto = ServiceMapper.toDTO(service);
      final serviceModel = await remoteDataSource.updateServicio(service.id, servicioDto);
      final updatedEntity = ServiceMapper.toEntity(serviceModel);
      return Right(updatedEntity);

    } on Failure catch (e) {
      print("⚠️ Failure en updateService Repository: $e");
      return Left(e);
    } catch (e) {
      print("⚠️ Error desconocido en updateService Repository: $e");
      return Left(DataException('Fallo al actualizar el servicio: ${e.toString()}') as Failure);
    }
  }

  // ----------------------------------------------------
  // 💡 DELETE: Eliminar Servicio
  // ----------------------------------------------------
  @override
  Future<void> deleteService(int id) async {
    try {
      await remoteDataSource.deleteServicio(id);
    } catch (e) {
      print("⚠️ Error en deleteService Repository: $e");
      throw DataException('Fallo al eliminar el servicio: $e');
    }
  }
}