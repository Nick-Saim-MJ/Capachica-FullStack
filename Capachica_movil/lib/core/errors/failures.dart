
// TODO: Add content to failures.dart

import 'package:equatable/equatable.dart';

// Clase base abstracta para los errores (Failures) de la aplicación.
// Se usa en la capa de Dominio para representar errores de negocio o de infraestructura
// de una manera limpia, sin exponer excepciones de bajo nivel como HttpException.
abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => [];
}

// --- Fallos Específicos ---

// Se devuelve cuando una llamada a la API falla (ej: status code 404, 500).
class ServerFailure extends Failure {}

// Se devuelve cuando el dispositivo no tiene conexión a internet.
class NetworkFailure extends Failure {}
// TODO: Add content to failures.dart

