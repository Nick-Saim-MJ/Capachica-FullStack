/// Utilidad para convertir entre snake_case y camelCase
class CaseConverter {
  /// Convertir string de snake_case a camelCase
  String toCamelCase(String snakeCase) {
    if (snakeCase.isEmpty) return snakeCase;

    final parts = snakeCase.split('_');
    if (parts.length == 1) return parts[0];

    final firstPart = parts[0].toLowerCase();
    final remainingParts = parts.skip(1).map((part) {
      if (part.isEmpty) return part;
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).join('');

    return firstPart + remainingParts;
  }

  /// Convertir string de camelCase a snake_case
  String toSnakeCase(String camelCase) {
    if (camelCase.isEmpty) return camelCase;

    final buffer = StringBuffer();
    for (int i = 0; i < camelCase.length; i++) {
      final char = camelCase[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (isUpper && i > 0) buffer.write('_');
      buffer.write(char.toLowerCase());
    }

    return buffer.toString();
  }

  /// Convertir Map de snake_case keys a camelCase keys
  Map<String, dynamic> convertMapToCamelCase(Map<String, dynamic> map) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      final camelKey = toCamelCase(entry.key);
      final value = entry.value;

      if (value is Map<String, dynamic>) {
        result[camelKey] = convertMapToCamelCase(value);
      } else if (value is List) {
        result[camelKey] = convertListToCamelCase(value);
      } else {
        result[camelKey] = value;
      }
    }

    return result;
  }

  /// Convertir Map de camelCase keys a snake_case keys
  Map<String, dynamic> convertMapToSnakeCase(Map<String, dynamic> map) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      final snakeKey = toSnakeCase(entry.key);
      final value = entry.value;

      if (value is Map<String, dynamic>) {
        result[snakeKey] = convertMapToSnakeCase(value);
      } else if (value is List) {
        result[snakeKey] = convertListToSnakeCase(value);
      } else {
        result[snakeKey] = value;
      }
    }

    return result;
  }

  /// Convertir List de Maps de snake_case a camelCase
  List<dynamic> convertListToCamelCase(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return convertMapToCamelCase(item);
      } else if (item is List) {
        return convertListToCamelCase(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// Convertir List de Maps de camelCase a snake_case
  List<dynamic> convertListToSnakeCase(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return convertMapToSnakeCase(item);
      } else if (item is List) {
        return convertListToSnakeCase(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// Normalizar key con fallback a snake_case si no existe en camelCase
  String normalizeKey(Map<String, dynamic> map, String camelKey, String snakeKey) {
    if (map.containsKey(camelKey)) return camelKey;
    if (map.containsKey(snakeKey)) return snakeKey;
    return camelKey; // por defecto camelCase
  }

  /// Obtener valor con fallback entre camelCase y snake_case
  T? getValueWithFallback<T>(Map<String, dynamic> map, String camelKey, String snakeKey) {
    if (map.containsKey(camelKey)) return map[camelKey] as T?;
    if (map.containsKey(snakeKey)) return map[snakeKey] as T?;
    return null;
  }

  /// Verificar si una key está en camelCase
  bool isCamelCase(String key) {
    return key.isNotEmpty && key[0] == key[0].toLowerCase() && key.contains(RegExp(r'[A-Z]'));
  }

  /// Verificar si una key está en snake_case
  bool isSnakeCase(String key) {
    return key.isNotEmpty && key.contains('_') && !key.contains(RegExp(r'[A-Z]'));
  }

  /// Convertir keys de un Map manteniendo el valor original si no se encuentra la key convertida
  Map<String, dynamic> convertMapKeysWithFallback(
      Map<String, dynamic> map,
      bool useCamelCase, // <- renombrado (antes: toCamelCase) para evitar choque con el método
      ) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      final originalKey = entry.key;
      final convertedKey =
      useCamelCase ? toCamelCase(originalKey) : toSnakeCase(originalKey);

      // Usar la key convertida si existe, sino mantener la original
      final keyToUse = map.containsKey(convertedKey) ? convertedKey : originalKey;
      final value = entry.value;

      if (value is Map<String, dynamic>) {
        result[keyToUse] = convertMapKeysWithFallback(value, useCamelCase);
      } else if (value is List) {
        result[keyToUse] = convertListKeysWithFallback(value, useCamelCase);
      } else {
        result[keyToUse] = value;
      }
    }

    return result;
  }

  /// Convertir keys de una List de Maps con fallback
  List<dynamic> convertListKeysWithFallback(List<dynamic> list, bool useCamelCase) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return convertMapKeysWithFallback(item, useCamelCase);
      } else if (item is List) {
        return convertListKeysWithFallback(item, useCamelCase);
      } else {
        return item;
      }
    }).toList();
  }
}
