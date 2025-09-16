/// Utilidad para manejo de paginación
class PaginationHelper {
  
  /// Calcular offset basado en página y elementos por página
  static int calculateOffset(int page, int perPage) {
    return (page - 1) * perPage;
  }

  /// Calcular página basada en offset y elementos por página
  static int calculatePage(int offset, int perPage) {
    if (perPage <= 0) return 1;
    return (offset ~/ perPage) + 1;
  }

  /// Calcular total de páginas
  static int calculateTotalPages(int totalItems, int perPage) {
    if (perPage <= 0) return 1;
    return (totalItems / perPage).ceil();
  }

  /// Verificar si hay página siguiente
  static bool hasNextPage(int currentPage, int totalPages) {
    return currentPage < totalPages;
  }

  /// Verificar si hay página anterior
  static bool hasPreviousPage(int currentPage) {
    return currentPage > 1;
  }

  /// Obtener página siguiente
  static int? getNextPage(int currentPage, int totalPages) {
    return hasNextPage(currentPage, totalPages) ? currentPage + 1 : null;
  }

  /// Obtener página anterior
  static int? getPreviousPage(int currentPage) {
    return hasPreviousPage(currentPage) ? currentPage - 1 : null;
  }

  /// Generar lista de páginas para mostrar en UI
  static List<int> generatePageNumbers({
    required int currentPage,
    required int totalPages,
    int maxVisiblePages = 5,
  }) {
    if (totalPages <= 1) return [1];
    
    final pages = <int>[];
    final halfVisible = maxVisiblePages ~/ 2;
    
    int startPage = (currentPage - halfVisible).clamp(1, totalPages);
    int endPage = (currentPage + halfVisible).clamp(1, totalPages);
    
    // Ajustar si estamos cerca del inicio o final
    if (endPage - startPage < maxVisiblePages - 1) {
      if (startPage == 1) {
        endPage = (startPage + maxVisiblePages - 1).clamp(1, totalPages);
      } else {
        startPage = (endPage - maxVisiblePages + 1).clamp(1, totalPages);
      }
    }
    
    for (int i = startPage; i <= endPage; i++) {
      pages.add(i);
    }
    
    return pages;
  }

  /// Validar parámetros de paginación
  static PaginationParams validatePaginationParams({
    int? page,
    int? perPage,
    int maxPerPage = 100,
    int minPerPage = 1,
  }) {
    final validatedPage = (page ?? 1).clamp(1, 1000);
    final validatedPerPage = (perPage ?? 20).clamp(minPerPage, maxPerPage);
    
    return PaginationParams(
      page: validatedPage,
      perPage: validatedPerPage,
    );
  }

  /// Crear parámetros de paginación para API
  static Map<String, String> createPaginationParams({
    int page = 1,
    int perPage = 20,
  }) {
    return {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
  }

  /// Crear parámetros de paginación con límites
  static Map<String, String> createPaginationParamsWithLimits({
    int page = 1,
    int perPage = 20,
    int maxPerPage = 100,
  }) {
    final validatedParams = validatePaginationParams(
      page: page,
      perPage: perPage,
      maxPerPage: maxPerPage,
    );
    
    return createPaginationParams(
      page: validatedParams.page,
      perPage: validatedParams.perPage,
    );
  }

  /// Calcular información de paginación para UI
  static PaginationInfo calculatePaginationInfo({
    required int currentPage,
    required int perPage,
    required int totalItems,
  }) {
    final totalPages = calculateTotalPages(totalItems, perPage);
    final startItem = calculateOffset(currentPage, perPage) + 1;
    final endItem = (startItem + perPage - 1).clamp(1, totalItems);
    
    return PaginationInfo(
      currentPage: currentPage,
      perPage: perPage,
      totalItems: totalItems,
      totalPages: totalPages,
      startItem: startItem,
      endItem: endItem,
      hasNextPage: hasNextPage(currentPage, totalPages),
      hasPreviousPage: hasPreviousPage(currentPage),
      nextPage: getNextPage(currentPage, totalPages),
      previousPage: getPreviousPage(currentPage),
    );
  }

  /// Crear estado inicial de paginación
  static PaginationState createInitialPaginationState({
    int perPage = 20,
  }) {
    return PaginationState(
      currentPage: 1,
      perPage: perPage,
      totalItems: 0,
      totalPages: 0,
      isLoading: false,
      hasMore: true,
    );
  }

  /// Actualizar estado de paginación con nueva página
  static PaginationState updatePaginationState(
    PaginationState currentState,
    List<dynamic> newItems, {
    int? totalItems,
    bool isLoading = false,
  }) {
    final isFirstPage = currentState.currentPage == 1;
    final allItems = isFirstPage ? newItems : [...currentState.allItems, ...newItems];
    final actualTotalItems = totalItems ?? allItems.length;
    final totalPages = calculateTotalPages(actualTotalItems, currentState.perPage);
    final hasMore = hasNextPage(currentState.currentPage, totalPages);
    
    return PaginationState(
      currentPage: currentState.currentPage,
      perPage: currentState.perPage,
      totalItems: actualTotalItems,
      totalPages: totalPages,
      isLoading: isLoading,
      hasMore: hasMore,
      allItems: allItems,
    );
  }

  /// Cargar página siguiente
  static PaginationState loadNextPage(PaginationState currentState) {
    if (!currentState.hasMore || currentState.isLoading) {
      return currentState;
    }
    
    return PaginationState(
      currentPage: currentState.currentPage + 1,
      perPage: currentState.perPage,
      totalItems: currentState.totalItems,
      totalPages: currentState.totalPages,
      isLoading: true,
      hasMore: currentState.hasMore,
      allItems: currentState.allItems,
    );
  }

  /// Refrescar paginación (volver a página 1)
  static PaginationState refreshPagination(PaginationState currentState) {
    return PaginationState(
      currentPage: 1,
      perPage: currentState.perPage,
      totalItems: 0,
      totalPages: 0,
      isLoading: false,
      hasMore: true,
      allItems: [],
    );
  }
}

/// Parámetros de paginación
class PaginationParams {
  final int page;
  final int perPage;

  PaginationParams({
    required this.page,
    required this.perPage,
  });

  Map<String, String> toMap() {
    return {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
  }
}

/// Información de paginación para UI
class PaginationInfo {
  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final int startItem;
  final int endItem;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final int? nextPage;
  final int? previousPage;

  PaginationInfo({
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.startItem,
    required this.endItem,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.nextPage,
    this.previousPage,
  });

  String get displayText {
    return 'Mostrando $startItem-$endItem de $totalItems elementos';
  }

  String get pageText {
    return 'Página $currentPage de $totalPages';
  }
}

/// Estado de paginación para controladores
class PaginationState {
  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final bool isLoading;
  final bool hasMore;
  final List<dynamic> allItems;

  PaginationState({
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.isLoading,
    required this.hasMore,
    this.allItems = const [],
  });

  PaginationState copyWith({
    int? currentPage,
    int? perPage,
    int? totalItems,
    int? totalPages,
    bool? isLoading,
    bool? hasMore,
    List<dynamic>? allItems,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      allItems: allItems ?? this.allItems,
    );
  }
}
