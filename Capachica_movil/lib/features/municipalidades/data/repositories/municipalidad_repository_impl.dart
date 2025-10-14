import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/municipalidad.dart';
import '../../domain/repositories/municipalidad_repository.dart';

class MunicipalidadRepositoryImpl implements MunicipalidadRepository {
  final String baseUrl;

  MunicipalidadRepositoryImpl(this.baseUrl);

  @override
  Future<List<MunicipalidadEntity>> getAllMunicipalidades() async {
    try {
      final url = Uri.parse('$baseUrl/municipalidad');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['data'] ?? [];
        return list
            .map((e) => MunicipalidadModel.fromJson(e).toEntity())
            .toList();
      }
      return [];
    } catch (e) {
      print('Error parsing municipalidades: $e');
      return [];
    }
  }

  @override
  Future<MunicipalidadEntity?> getMunicipalidadById(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/municipalidad/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MunicipalidadModel.fromJson(data['data']).toEntity();
      }
      return null;
    } catch (e) {
      print('Error parsing municipalidad: $e');
      return null;
    }
  }

  @override
  Future<bool> createMunicipalidad(MunicipalidadEntity municipalidad) async {
    final url = Uri.parse('$baseUrl/municipalidad');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(MunicipalidadModel(
        id: municipalidad.id,
        nombre: municipalidad.nombre,
        descripcion: municipalidad.descripcion,
        redFacebook: municipalidad.redFacebook,
        redInstagram: municipalidad.redInstagram,
        redYoutube: municipalidad.redYoutube,
        coordenadasX: municipalidad.coordenadasX,
        coordenadasY: municipalidad.coordenadasY,
        frase: municipalidad.frase,
        comunidades: municipalidad.comunidades,
        historiaFamilias: municipalidad.historiaFamilias,
        historiaCapachica: municipalidad.historiaCapachica,
        comite: municipalidad.comite,
        mision: municipalidad.mision,
        vision: municipalidad.vision,
        valores: municipalidad.valores,
        ordenanzaMunicipal: municipalidad.ordenanzaMunicipal,
        alianzas: municipalidad.alianzas,
        correo: municipalidad.correo,
        horarioAtencion: municipalidad.horarioAtencion,
      ).toJson()),
    );

    return response.statusCode == 201;
  }

  @override
  Future<bool> updateMunicipalidad(MunicipalidadEntity municipalidad) async {
    final url = Uri.parse('$baseUrl/municipalidad/${municipalidad.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(MunicipalidadModel(
        id: municipalidad.id,
        nombre: municipalidad.nombre,
        descripcion: municipalidad.descripcion,
        redFacebook: municipalidad.redFacebook,
        redInstagram: municipalidad.redInstagram,
        redYoutube: municipalidad.redYoutube,
        coordenadasX: municipalidad.coordenadasX,
        coordenadasY: municipalidad.coordenadasY,
        frase: municipalidad.frase,
        comunidades: municipalidad.comunidades,
        historiaFamilias: municipalidad.historiaFamilias,
        historiaCapachica: municipalidad.historiaCapachica,
        comite: municipalidad.comite,
        mision: municipalidad.mision,
        vision: municipalidad.vision,
        valores: municipalidad.valores,
        ordenanzaMunicipal: municipalidad.ordenanzaMunicipal,
        alianzas: municipalidad.alianzas,
        correo: municipalidad.correo,
        horarioAtencion: municipalidad.horarioAtencion,
      ).toJson()),
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteMunicipalidad(int id) async {
    final url = Uri.parse('$baseUrl/municipalidad/$id');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}
