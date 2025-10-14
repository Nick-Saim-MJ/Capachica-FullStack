// paginated_response.dart
class PaginatedResponse<T> {
  final int currentPage;
  final List<T> data;
  final int perPage;
  final int total;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const PaginatedResponse({
    required this.currentPage,
    required this.data,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;

  @override
  String toString() {
    return 'PaginatedResponse(currentPage: $currentPage, total: $total, data: ${data.length} items)';
  }
}


