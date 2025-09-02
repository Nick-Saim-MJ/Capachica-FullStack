import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart'; // <- Importa Get aquí
import 'package:http/http.dart' as http;

import '../core/config/backend_config.dart';
import '../core/exceptions/api_exception.dart';
import '../data/models/profile_model.dart';

import 'auth_service.dart';

class ProfileService {

  final AuthService _authService = Get.find<AuthService>();
  final http.Client _client = http.Client();

  Future<String?> getToken() async {
    return _authService.token.value;
  }

  /// GET /api/profile - obtener perfil del usuario
  Future<ProfileModel> getProfile() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    try {
      print('👤 ProfileService: Obteniendo perfil del usuario...');

      // Omitted test mode logic for brevity
      final response = await _client.get(
        Uri.parse('${BackendConfig.getBaseUrl()}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(BackendConfig.requestTimeout);

      print('📡 ProfileService: Perfil response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Raw decoded data: $data');

        Map<String, dynamic>? profileData;

        // Correctly handle the nested structure
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          final innerData = data['data'] as Map<String, dynamic>;
          if (innerData.containsKey('user') && innerData['user'] is Map<String, dynamic>) {
            profileData = innerData['user'] as Map<String, dynamic>;
          } else {
            profileData = innerData;
          }
        } else if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          profileData = data['user'] as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          profileData = data;
        }

        if (profileData == null || !profileData.containsKey('id')) {
          throw Exception("JSON inválido, falta 'id' en la respuesta de perfil.");
        }

        // The ProfileModel.fromJson needs a map with 'id', 'name', etc. at the top level.
        return ProfileModel.fromJson(profileData);
      } else if (response.statusCode == 404) {
        throw ApiException(message: 'Perfil no encontrado', statusCode: 404);
      } else {
        throw ApiException(
          message: 'Error obteniendo perfil: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ ProfileService: Error obteniendo perfil: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  /// PUT /api/profile - actualizar perfil del usuario
  Future<ProfileModel> updateProfile(Map<String, dynamic> data, {File? fotoPerfil}) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    try {
      print('👤 ProfileService: Actualizando perfil del usuario...');

      if (BackendConfig.testMode) {
        print('🧪 ProfileService: Usando modo de prueba para actualizar perfil');
        await Future.delayed(Duration(milliseconds: 800));
        return ProfileModel.fromJson({
          ...data,
          'id': 1,
          'fotoUrl': fotoPerfil != null
              ? 'https://example.com/foto_perfil_actualizada.jpg'
              : 'https://example.com/foto_perfil.jpg',
          'fechaNacimiento': data['fechaNacimiento'] ?? '1990-05-20T00:00:00Z',
        });
      }

      http.Response response;

      if (fotoPerfil != null) {
        var uri = Uri.parse('${BackendConfig.getBaseUrl()}/profile');
        var request = http.MultipartRequest('PUT', uri);

        data.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });

        var multipartFile = await http.MultipartFile.fromPath('fotoPerfil', fotoPerfil.path);
        request.files.add(multipartFile);

        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

        final streamedResponse = await request.send().timeout(BackendConfig.requestTimeout);
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final body = json.encode(data);
        response = await _client.put(
          Uri.parse('${BackendConfig.getBaseUrl()}/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        ).timeout(BackendConfig.requestTimeout);
      }

      print('📡 ProfileService: Actualizar perfil response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Raw decoded update data: $data');

        Map<String, dynamic>? profileData;

        if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          profileData = data['user'] as Map<String, dynamic>;
        } else if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          profileData = data['data'] as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          profileData = data;
        } else {
          throw Exception('Formato JSON inesperado: $data');
        }

        if (profileData == null || profileData['id'] == null) {
          throw Exception("JSON inválido, falta 'id' en profileData: $profileData");
        }

        return ProfileModel.fromJson(profileData);
      } else {
        throw ApiException(
          message: 'Error actualizando perfil: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ ProfileService: Error actualizando perfil: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
