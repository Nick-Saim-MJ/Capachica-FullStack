// paginated_response_model.dart
class LaravelPaginated<T> {
  final int currentPage;
  final List<T> data;
  final int perPage;
  final int total;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const LaravelPaginated({
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
    // Laravel pagination lives inside `data` key -> the array is `data.data`
    final List<dynamic> items = (json['data'] as List<dynamic>? ?? []);
    // Some backends nest: { current_page, data: [ ... ] }. If double nested was given
    // to this factory with the inner object, items is already the list.
    return LaravelPaginated<T>(
      currentPage: json['current_page'] as int,
      data: items.map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      lastPage: (json['last_page'] as num).toInt(),
      nextPageUrl: json['next_page_url'] as String?,
      prevPageUrl: json['prev_page_url'] as String?,
    );
  }
}

