
// get_public_emprendedores.dart
// domain/usecases/get_public_emprendedores.dart
import '../entities/emprendedor.dart';
import '../repositories/emprendedor_repository.dart';

class GetPublicEmprendedores {
  final EmprendedorRepository repository;

  GetPublicEmprendedores({required this.repository});

  /// Devuelve la lista de emprendedores públicos
  Future<List<EmprendedorEntity>> call() async {
    try {
      final emprendedores = await repository.getAllEmprendedores();
      // Filtramos solo los activos (estado = true)
      return emprendedores.where((e) => e.estado).toList();
    } catch (e) {
      print("⚠️ Error en GetPublicEmprendedores use case: $e");
      return [];
    }
  }
}
