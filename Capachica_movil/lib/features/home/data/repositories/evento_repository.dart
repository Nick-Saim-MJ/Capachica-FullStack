// lib/features/home/data/repositories/evento_repository.dart
import 'dart:io';
import 'package:aplicativo_capachica/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/evento_model.dart';
import '../../../../core/network/api_client.dart';

abstract class EventoRepository {
  Future<Result<List<EventoModel>>> getEventos({int? page});
  Future<Result<EventoModel>> getEventoById(int id);
  Future<Result<EventoModel>> createEvento(CreateEventoRequest request);
  Future<Result<EventoModel>> updateEvento(int id, CreateEventoRequest request);
  Future<Result<bool>> deleteEvento(int id);
  Future<Result<List<EventoModel>>> getEventosActivos();
  Future<Result<List<EventoModel>>> getProximosEventos({int limite = 5});
  Future<Result<List<EventoModel>>> getEventosByEmprendedor(int emprendedorId);
}

class EventoRepositoryImpl implements EventoRepository {
  final ApiClient _apiClient;

  EventoRepositoryImpl(this._apiClient);

  @override
  Future<Result<List<EventoModel>>> getEventos({int? page}) async {
    try {
      final response = await _apiClient.get(
        '/eventos',
        queryParameters: page != null ? {'page': page} : null,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        List<EventoModel> eventos;

        // Manejar tanto respuesta paginada como simple
        if (data is Map && data.containsKey('data')) {
          eventos = (data['data'] as List)
              .map((json) => EventoModel.fromJson(json))
              .toList();
        } else {
          eventos = (data as List)
              .map((json) => EventoModel.fromJson(json))
              .toList();
        }

        return Result.success(eventos);
      } else {
        return Result.error(response.data['message'] ?? 'Error al obtener eventos');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<EventoModel>> getEventoById(int id) async {
    try {
      final response = await _apiClient.get('/eventos/$id');

      if (response.data['success'] == true) {
        final evento = EventoModel.fromJson(response.data['data']);
        return Result.success(evento);
      } else {
        return Result.error(response.data['message'] ?? 'Evento no encontrado');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<EventoModel>> createEvento(CreateEventoRequest request) async {
    try {
      FormData formData = await _buildFormData(request);

      final response = await _apiClient.post(
        '/eventos',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.data['success'] == true) {
        final evento = EventoModel.fromJson(response.data['data']);
        return Result.success(evento);
      } else {
        return Result.error(response.data['message'] ?? 'Error al crear evento');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<EventoModel>> updateEvento(int id, CreateEventoRequest request) async {
    try {
      final hasFiles = (request.sliders ?? [])
          .any((s) => s.imagenPath != null && s.imagenPath!.trim().isNotEmpty);

      if (hasFiles) {
        // Si algún día envías imágenes, usa multipart con method spoofing
        final formData = await _buildFormData(request);
        formData.fields.add(const MapEntry('_method', 'PUT'));

        final response = await _apiClient.post(
          '/eventos/$id',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );

        if (response.data['success'] == true) {
          return Result.success(EventoModel.fromJson(response.data['data']));
        }
        return Result.error(response.data['message'] ?? 'Error al actualizar evento');
      } else {
        // ✅ SIN archivos: PUT JSON “limpio”
        final json = request.toJson()
          ..removeWhere((k, v) => v == null || (v is List && v.isEmpty));

        final response = await _apiClient.put(
          '/eventos/$id',
          data: json,
          options: Options(contentType: Headers.jsonContentType),
        );

        if (response.data['success'] == true) {
          return Result.success(EventoModel.fromJson(response.data['data']));
        }
        return Result.error(response.data['message'] ?? 'Error al actualizar evento');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> deleteEvento(int id) async {
    try {
      final response = await _apiClient.delete('/eventos/$id');

      if (response.data['success'] == true) {
        return Result.success(true);
      } else {
        return Result.error(response.data['message'] ?? 'Error al eliminar evento');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<EventoModel>>> getEventosActivos() async {
    try {
      final response = await _apiClient.get('/eventos/activos');

      if (response.data['success'] == true) {
        final eventos = (response.data['data'] as List)
            .map((json) => EventoModel.fromJson(json))
            .toList();
        return Result.success(eventos);
      } else {
        return Result.error(response.data['message'] ?? 'Error al obtener eventos activos');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<EventoModel>>> getProximosEventos({int limite = 5}) async {
    try {
      final response = await _apiClient.get(
        '/eventos/proximos',
        queryParameters: {'limite': limite},
      );

      if (response.data['success'] == true) {
        final eventos = (response.data['data'] as List)
            .map((json) => EventoModel.fromJson(json))
            .toList();
        return Result.success(eventos);
      } else {
        return Result.error(response.data['message'] ?? 'Error al obtener próximos eventos');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<EventoModel>>> getEventosByEmprendedor(int emprendedorId) async {
    try {
      final response = await _apiClient.get('/eventos/emprendedor/$emprendedorId');

      if (response.data['success'] == true) {
        final eventos = (response.data['data'] as List)
            .map((json) => EventoModel.fromJson(json))
            .toList();
        return Result.success(eventos);
      } else {
        return Result.error(response.data['message'] ?? 'Error al obtener eventos del emprendedor');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  Future<FormData> _buildFormData(CreateEventoRequest request) async {
    final formData = FormData();
    final requestData = request.toJson();

    // Agregar campos básicos
    requestData.forEach((key, value) {
      if (key != 'sliders' && value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    // Agregar sliders
    if (request.sliders != null) {
      for (int i = 0; i < request.sliders!.length; i++) {
        final slider = request.sliders![i];
        final sliderData = slider.toJson();

        sliderData.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry('sliders[$i][$key]', value.toString()));
          }
        });

        // Agregar imagen si existe
        if (slider.imagenPath != null) {
          final file = File(slider.imagenPath!);
          if (await file.exists()) {
            final fileName = file.path.split('/').last;
            formData.files.add(MapEntry(
              'sliders[$i][imagen]',
              await MultipartFile.fromFile(
                file.path,
                filename: fileName,
                contentType: MediaType('image', _getImageExtension(fileName)),
              ),
            ));
          }
        }
      }
    }

    // Agregar sliders eliminados
    if (request.deletedSliders != null) {
      for (int i = 0; i < request.deletedSliders!.length; i++) {
        formData.fields.add(MapEntry(
          'deleted_sliders[$i]',
          request.deletedSliders![i].toString(),
        ));
      }
    }

    return formData;
  }

  String _getImageExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      default:
        return 'jpeg';
    }
  }
}