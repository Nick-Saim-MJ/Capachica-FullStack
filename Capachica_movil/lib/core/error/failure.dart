
import 'package:equatable/equatable.dart';

// Clase base abstracta para representar un fallo en la aplicación.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// Representa un fallo relacionado con la API (ej. error 4xx, 5xx).
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Representa un fallo relacionado con la red (ej. sin conexión a internet).
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// Representa un fallo genérico o inesperado.
class GenericFailure extends Failure {
  const GenericFailure({required super.message});
}
