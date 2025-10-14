// lib/features/asociaciones/data/models/laravel_paginated.dart
import '../../../../core/utils/json_utils.dart';

class LaravelPaginated<T> {
  final int currentPage;
  final List<T> data;
  final int perPage;
  final int total;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  LaravelPaginated({
    required this.currentPage,
    required this.data,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory LaravelPaginated.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    final raw = (json['data'] as List? ?? const []);
    final list = raw
        .map((e) => fromJsonT(Map<String, dynamic>.from(e as Map)))
        .toList();

    return LaravelPaginated<T>(
      currentPage: asInt(json['current_page']) ?? 1,
      data: list,
      perPage: asInt(json['per_page']) ?? list.length,
      total: asInt(json['total']) ?? list.length,
      lastPage: asInt(json['last_page']) ?? 1,
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) => {
    'current_page': currentPage,
    'data': data.map((e) => toJsonT(e)).toList(),
    'per_page': perPage,
    'total': total,
    'last_page': lastPage,
    'next_page_url': nextPageUrl,
    'prev_page_url': prevPageUrl,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LaravelPaginated<T>) return false;
    
    // Comparar todos los campos importantes
    if (currentPage != other.currentPage) return false;
    if (perPage != other.perPage) return false;
    if (total != other.total) return false;
    if (lastPage != other.lastPage) return false;
    if (nextPageUrl != other.nextPageUrl) return false;
    if (prevPageUrl != other.prevPageUrl) return false;
    
    // Comparar la lista de datos
    if (data.length != other.data.length) return false;
    for (int i = 0; i < data.length; i++) {
      if (data[i] != other.data[i]) return false;
    }
    
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentPage,
      perPage,
      total,
      lastPage,
      nextPageUrl,
      prevPageUrl,
      Object.hashAll(data),
    );
  }
}
