import 'dart:async';

/// Utilidad para debounce de búsquedas
class DebounceHelper {
  Timer? _timer;
  final Duration delay;

  DebounceHelper({this.delay = const Duration(milliseconds: 400)});

  /// Ejecutar función con debounce
  void debounce(Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Ejecutar función con debounce y parámetros
  void debounceWithParams<T>(Function(T) callback, T params) {
    _timer?.cancel();
    _timer = Timer(delay, () => callback(params));
  }

  /// Cancelar debounce pendiente
  void cancel() {
    _timer?.cancel();
  }

  /// Verificar si hay un debounce pendiente
  bool get isPending => _timer?.isActive ?? false;

  /// Dispose del helper
  void dispose() {
    _timer?.cancel();
  }
}

/// Mixin para agregar funcionalidad de debounce a controladores
mixin DebounceMixin {
  final Map<String, DebounceHelper> _debouncers = {};

  /// Crear o obtener debouncer por clave
  DebounceHelper _getDebouncer(String key, {Duration? delay}) {
    if (!_debouncers.containsKey(key)) {
      _debouncers[key] = DebounceHelper(delay: delay ?? const Duration(milliseconds: 400));
    }
    return _debouncers[key]!;
  }

  /// Ejecutar función con debounce
  void debounce(String key, Function() callback, {Duration? delay}) {
    _getDebouncer(key, delay: delay).debounce(callback);
  }

  /// Ejecutar función con debounce y parámetros
  void debounceWithParams<T>(String key, Function(T) callback, T params, {Duration? delay}) {
    _getDebouncer(key, delay: delay).debounceWithParams(callback, params);
  }

  /// Cancelar debounce por clave
  void cancelDebounce(String key) {
    _debouncers[key]?.cancel();
  }

  /// Cancelar todos los debounces
  void cancelAllDebounces() {
    for (final debouncer in _debouncers.values) {
      debouncer.cancel();
    }
  }

  /// Verificar si hay debounce pendiente
  bool isDebouncePending(String key) {
    return _debouncers[key]?.isPending ?? false;
  }

  /// Dispose de todos los debounces
  void disposeDebounces() {
    for (final debouncer in _debouncers.values) {
      debouncer.dispose();
    }
    _debouncers.clear();
  }
}
