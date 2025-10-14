// data/repositories/municipalidad_repository_impl.dart

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/emprendedor.dart';
import '../../domain/repositories/emprendedor_repository.dart';
import '../datasources/emprendedor_remote_data_source.dart';
import '../models/emprendedor_model.dart';
import 'package:http/http.dart' as http;


class EmprendedorRepositoryImpl implements EmprendedorRepository {
  final EmprendedorRemoteDataSource remoteDataSource;
  final String baseUrl;
  final FlutterSecureStorage storage = const FlutterSecureStorage(); // <- aquí

  EmprendedorRepositoryImpl({
    required this.baseUrl,
    required this.remoteDataSource,

  });

  @override
  Future<List<EmprendedorEntity>> getAllEmprendedores() async {
    try {
      final emprendedores = await remoteDataSource.getAllEmprendedores();
      return emprendedores.map((e) => e.toEntity()).toList();
    } catch (e) {
      print("⚠️ Error en getAllEmprendedores Repository: $e");
      return [];
    }
  }

  @override
  Future<EmprendedorEntity?> getEmprendedorById(int id) async {
    try {
      final emprendedor = await remoteDataSource.getEmprendedorById(id);
      return emprendedor?.toEntity();
    } catch (e) {
      print("⚠️ Error en getEmprendedorById Repository: $e");
      return null;
    }
  }

  @override
  Future<bool> createEmprendedor(EmprendedorEntity emprendedor) async {
    try {
      // Convertimos la entidad a modelo, usando valores por defecto solo cuando sea necesario
      final model = EmprendedorModel(
        id: emprendedor.id,
        nombre: emprendedor.nombre,
        tipoServicio: emprendedor.tipoServicio ?? 'General',
        descripcion: '', // si no tienes descripción en la Entity
        ubicacion: emprendedor.ubicacion ?? '',
        telefono: emprendedor.telefono ?? '',
        email: emprendedor.email ?? '',
        paginaWeb: null,
        horarioAtencion: null,
        precioRango: null,
        metodosPago: [],
        capacidadAforo: null,
        numeroPersonasAtienden: null,
        comentariosResenas: null,
        imagenes: [],
        categoria: 'General', // puedes cambiar según lógica de negocio
        certificaciones: [],
        idiomasHablados: [],
        opcionesAcceso: [],
        facilidadesDiscapacidad: false,
        asociacionId: null,
        estado: true,
        slidersPrincipales: [],
        slidersSecundarios: [],
        createdAt: null,
        updatedAt: null,
      );

      await remoteDataSource.createEmprendedor(model);
      return true;
    } catch (e) {
      print("⚠️ Error en createEmprendedor Repository: $e");
      return false;
    }
  }

  @override
  Future<bool> updateEmprendedor(EmprendedorEntity emprendedor) async {
    try {
      final existing = await remoteDataSource.getEmprendedorById(emprendedor.id);

      final model = EmprendedorModel(
        id: emprendedor.id,
        nombre: emprendedor.nombre,
        tipoServicio: emprendedor.tipoServicio ?? existing?.tipoServicio ?? 'General',
        descripcion: existing?.descripcion ?? '',
        ubicacion: emprendedor.ubicacion ?? existing?.ubicacion ?? '',
        telefono: emprendedor.telefono ?? existing?.telefono ?? '',
        email: emprendedor.email ?? existing?.email ?? '',
        paginaWeb: existing?.paginaWeb,
        horarioAtencion: existing?.horarioAtencion,
        precioRango: existing?.precioRango,
        metodosPago: existing?.metodosPago ?? [],
        capacidadAforo: existing?.capacidadAforo,
        numeroPersonasAtienden: existing?.numeroPersonasAtienden,
        comentariosResenas: existing?.comentariosResenas,
        imagenes: existing?.imagenes ?? [],
        categoria: existing?.categoria ?? 'General',
        certificaciones: existing?.certificaciones ?? [],
        idiomasHablados: existing?.idiomasHablados ?? [],
        opcionesAcceso: existing?.opcionesAcceso ?? [],
        facilidadesDiscapacidad: existing?.facilidadesDiscapacidad ?? false,
        asociacionId: existing?.asociacionId,
        estado: existing?.estado ?? true,
        slidersPrincipales: existing?.slidersPrincipales ?? [],
        slidersSecundarios: existing?.slidersSecundarios ?? [],
        createdAt: existing?.createdAt,
        updatedAt: DateTime.now(),
      );

      await remoteDataSource.updateEmprendedor(model);
      return true;
    } catch (e) {
      print("⚠️ Error en updateEmprendedor Repository: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteEmprendedor(int id) async {
    // Leer token
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('Debes iniciar sesión primero');

    final url = Uri.parse('$baseUrl/emprendedores/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('StatusCode: ${response.statusCode}');
      print('Body: ${response.body}');

      // Manejo robusto de la respuesta
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          return data['success'] == true;
        } catch (_) {
          // Si no devuelve JSON, asumimos éxito
          return true;
        }
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado: revisa tu token o inicia sesión de nuevo');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para eliminar este emprendedor');
      } else if (response.statusCode == 404) {
        throw Exception('Emprendedor no encontrado');
      } else {
        throw Exception('Error al eliminar el emprendedor: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error en deleteEmprendedor Repository: $e');
      rethrow;
    }
  }


  @override
  Future<List<EmprendedorEntity>> searchEmprendedores(String query) async {
    try {
      final models = await remoteDataSource.searchEmprendedores(query);
      return models.map((e) => e.toEntity()).toList();
    } catch (e) {
      print("⚠️ Error en searchEmprendedores Repository: $e");
      return [];
    }
  }
}

