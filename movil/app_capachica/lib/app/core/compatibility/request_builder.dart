import 'dart:convert';
import 'package:http/http.dart' as http;

/// Constructor de peticiones HTTP con utilidades para parámetros y paginación
class RequestBuilder {
  
  /// Construir URI con query parameters
  Uri buildUri(String baseUrl, String endpoint, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  /// Construir query parameters para paginación
  Map<String, String> buildPaginationParams({
    int page = 1,
    int perPage = 20,
  }) {
    return {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
  }

  /// Construir query parameters para búsqueda
  Map<String, String> buildSearchParams({
    String? query,
    String? buscar,
    String? search,
  }) {
    final params = <String, String>{};
    
    // Priorizar 'q' como parámetro principal de búsqueda
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    } else if (buscar != null && buscar.isNotEmpty) {
      params['buscar'] = buscar;
    } else if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    
    return params;
  }

  /// Construir query parameters para filtros
  Map<String, String> buildFilterParams({
    String? categoria,
    int? emprendedorId,
    double? precioMin,
    double? precioMax,
    String? estado,
    String? tipo,
    Map<String, String>? additionalFilters,
  }) {
    final params = <String, String>{};
    
    if (categoria != null && categoria.isNotEmpty) {
      params['categoria'] = categoria;
    }
    
    if (emprendedorId != null) {
      params['emprendedor_id'] = emprendedorId.toString();
    }
    
    if (precioMin != null) {
      params['precio_min'] = precioMin.toString();
    }
    
    if (precioMax != null) {
      params['precio_max'] = precioMax.toString();
    }
    
    if (estado != null && estado.isNotEmpty) {
      params['estado'] = estado;
    }
    
    if (tipo != null && tipo.isNotEmpty) {
      params['tipo'] = tipo;
    }
    
    if (additionalFilters != null) {
      params.addAll(additionalFilters);
    }
    
    return params;
  }

  /// Combinar múltiples mapas de parámetros
  Map<String, String> combineParams(
    Map<String, String> params1,
    Map<String, String> params2,
  ) {
    return {...params1, ...params2};
  }

  /// Construir body para peticiones POST/PUT
  String buildRequestBody(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  /// Construir headers estándar
  Map<String, String> buildHeaders({
    String? token,
    Map<String, String>? additionalHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  /// Construir URL completa con parámetros
  String buildFullUrl(
    String baseUrl,
    String endpoint, {
    Map<String, String>? queryParams,
  }) {
    final uri = buildUri(baseUrl, endpoint, queryParams);
    return uri.toString();
  }

  /// Validar parámetros de paginación
  Map<String, String> validatePaginationParams({
    int? page,
    int? perPage,
    int maxPerPage = 100,
  }) {
    final validatedPage = (page ?? 1).clamp(1, 1000);
    final validatedPerPage = (perPage ?? 20).clamp(1, maxPerPage);
    
    return buildPaginationParams(
      page: validatedPage,
      perPage: validatedPerPage,
    );
  }

  /// Construir parámetros para ordenamiento
  Map<String, String> buildSortParams({
    String? sortBy,
    String? sortOrder = 'asc',
  }) {
    final params = <String, String>{};
    
    if (sortBy != null && sortBy.isNotEmpty) {
      params['sort_by'] = sortBy;
      params['sort_order'] = sortOrder ?? 'asc';
    }
    
    return params;
  }

  /// Construir parámetros para fechas
  Map<String, String> buildDateParams({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? fechaInicioParam = 'fecha_inicio',
    String? fechaFinParam = 'fecha_fin',
  }) {
    final params = <String, String>{};
    
    if (fechaInicio != null) {
      params[fechaInicioParam!] = fechaInicio.toIso8601String().split('T')[0];
    }
    
    if (fechaFin != null) {
      params[fechaFinParam!] = fechaFin.toIso8601String().split('T')[0];
    }
    
    return params;
  }
}
