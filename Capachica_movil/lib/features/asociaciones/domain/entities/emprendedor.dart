// emprendedor.dart
class EmprendedorEntity {
  final int id;
  final String nombre;
  final String apellidos;
  final String? telefono;
  final String? email;
  final String? foto;
  final String? descripcion;
  final int asociacionId;
  final String? asociacionNombre;
  final DateTime? fechaRegistro;

  const EmprendedorEntity({
    required this.id,
    required this.nombre,
    required this.apellidos,
    this.telefono,
    this.email,
    this.foto,
    this.descripcion,
    required this.asociacionId,
    this.asociacionNombre,
    this.fechaRegistro,
  });

  String get nombreCompleto => '$nombre $apellidos';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmprendedorEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Emprendedor(id: $id, nombreCompleto: $nombreCompleto)';
  }
}

