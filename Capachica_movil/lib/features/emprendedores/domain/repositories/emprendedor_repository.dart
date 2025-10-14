
import '../entities/emprendedor.dart';

abstract class EmprendedorRepository {

  
  /// Obtener todos los emprendedores
  Future<List<EmprendedorEntity>> getAllEmprendedores();

  /// Obtener un emprendedor por su ID
  Future<EmprendedorEntity?> getEmprendedorById(int id);

  /// Crear un nuevo emprendedor
  Future<bool> createEmprendedor(EmprendedorEntity emprendedor);

  /// Actualizar un emprendedor existente
  Future<bool> updateEmprendedor(EmprendedorEntity emprendedor);

  /// Eliminar un emprendedor por su ID
  Future<bool> deleteEmprendedor(int id);

  Future<List<EmprendedorEntity>>searchEmprendedores(String query);
}
