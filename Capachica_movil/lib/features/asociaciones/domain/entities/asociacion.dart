// asociacion.dart
class AsociacionEntity {
  final int id;
  final String nombre;
  final String descripcion;
  final String? direccion;
  final String? telefono;
  final String? email;
  final String? logo;
  final String? imagen;
  final bool? estado;
  final double? latitud;
  final double? longitud;
  final int? municipalidadId;
  final String? municipalidadNombre;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  const AsociacionEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.direccion,
    this.telefono,
    this.email,
    this.logo,
    this.imagen,
    this.estado,
    this.latitud,
    this.longitud,
    this.municipalidadId,
    this.municipalidadNombre,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AsociacionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Asociacion(id: $id, nombre: $nombre, direccion: $direccion)';
  }
}

