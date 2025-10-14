// lib/features/plans/data/models/dia_model.dart

import 'package:aplicativo_capachica/features/plans/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/plans/domain/entities/dia_entity.dart';
import 'package:aplicativo_capachica/features/plans/domain/entities/servicio_entity.dart';

class DiaModel extends DiaEntity {
  const DiaModel({
    required int numeroDia,
    required String titulo,
    required String descripcion,
    List<ServicioEntity> servicios = const [],
  }) : super(
    numeroDia: numeroDia,
    titulo: titulo,
    descripcion: descripcion,
    servicios: servicios,
  );

  factory DiaModel.fromJson(Map<String, dynamic> json) {
    final serviciosData = json['servicios'] as List? ?? [];
    final listaDeServicios = serviciosData.map((s) => ServicioModel.fromJson(s)).toList();

    return DiaModel(
      numeroDia: json['numero_dia'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],

    );
  }
}