// lib/features/asociaciones/domain/entities/municipalidad.dart

class MunicipalidadEntity {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? provincia;
  final String? region;

  const MunicipalidadEntity({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.provincia,
    this.region,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MunicipalidadEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MunicipalidadEntity(id: $id, nombre: $nombre)';
  }
}

