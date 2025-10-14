// lib/core/network/network_info.dart

import 'package:connectivity_plus/connectivity_plus.dart';

/// Contrato: Define cómo debe ser una clase que verifica la conexión.
/// La capa de datos depende de esta abstracción, no de la implementación.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementación usando connectivity_plus.
/// Podemos cambiar la implementación en el futuro sin modificar el repositorio.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
