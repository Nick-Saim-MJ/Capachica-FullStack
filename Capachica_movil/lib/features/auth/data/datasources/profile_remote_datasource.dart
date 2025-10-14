// Tu código modificado (y correcto):
import 'dart:convert';
import 'package:aplicativo_capachica/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart'; // <-- Correcto: Importas el tipo Response<dynamic>
import '../../../../core/network/api_client.dart';

class ProfileRemoteDataSource {
  final ApiClient apiClient;
  ProfileRemoteDataSource(this.apiClient);

  Future<UserModel> fetchProfile() async {
    // AHORA el tipo coincide
    final Response<dynamic> response = await apiClient.get('/profile');

    // Correcto: Usas .data
    final decodedData = response.data as Map<String, dynamic>;

    return UserModel.fromJson(decodedData['data']['user']);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> body, {String? filePath}) async {
    // AHORA el tipo coincide
    final Response<dynamic> response;

    if (filePath != null) {
      // Usa putMultipart (que ahora usa POST + _method:PUT)
      response = await apiClient.putMultipart('/profile', body, filePath: filePath);
    } else {
      // Usa el método PUT estándar para JSON
      response = await apiClient.put('/profile', data: body);
    }

    final decodedData = response.data as Map<String, dynamic>;
    // Asegúrate de que esta línea de parseo esté correcta para tu API
    // Si tu API devuelve {'success': true, 'data': { ...user data... } }

    return UserModel.fromJson(decodedData['data']);
  }
}