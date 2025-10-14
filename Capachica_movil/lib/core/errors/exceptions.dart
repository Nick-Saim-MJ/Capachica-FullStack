

// lib/core/errors/exceptions.dart

class ServerException implements Exception {}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class RequiresTwoFA implements Exception {
  final String email;
  final String password; // se usa para reintentar login con el code
  RequiresTwoFA(this.email, this.password);
}
class MustSetupTwoFA implements Exception {}

