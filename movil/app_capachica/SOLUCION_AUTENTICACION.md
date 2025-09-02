# Solución para Problema de Autenticación

## Problema Identificado
La aplicación se queda cargando al intentar autenticarse con el correo.

## Soluciones Implementadas

### 1. **Logging Detallado**
Se agregó logging extensivo para identificar exactamente dónde se detiene el proceso:
- Logs en AuthService para cada paso del proceso
- Logs en LoginController para el flujo de autenticación
- Logs en AuthResponse para el parsing de JSON

### 2. **Búsqueda Automática del Backend**
La aplicación ahora busca automáticamente la URL correcta del backend:
- Prueba múltiples URLs comunes (localhost, 127.0.0.1, IPs locales)
- Detecta automáticamente la URL correcta
- Permite cambiar la URL dinámicamente

### 3. **Manejo Flexible de Respuestas JSON**
El modelo AuthResponse ahora maneja diferentes formatos de respuesta del backend Laravel:
- Respuesta directa: `{"token": "...", "user": {...}}`
- Respuesta con wrapper: `{"data": {"token": "...", "user": {...}}}`
- Respuesta con access_token: `{"access_token": "...", "user": {...}}`

### 4. **Timeouts y Manejo de Errores**
- Timeout de 30 segundos para peticiones HTTP
- Timeout de 10 segundos para pruebas de conectividad
- Manejo específico de errores de conexión
- Mensajes de error descriptivos

## Cómo Probar

### 1. **Verificar que el Backend esté Ejecutándose**
```bash
# En tu laptop, verifica que Laravel esté corriendo
php artisan serve
# Debería mostrar algo como: Server running on http://127.0.0.1:8000
```

### 2. **Verificar la URL del Backend**
Si tu backend está en una URL diferente, modifica el archivo:
```
lib/app/core/config/backend_config.dart
```

### 3. **Ejecutar la Aplicación**
```bash
flutter run --debug
```

### 4. **Revisar los Logs**
Cuando intentes hacer login, revisa la consola para ver los logs detallados:
- `[AuthService]` - Logs del servicio de autenticación
- `[LoginController]` - Logs del controlador
- `[AuthResponse]` - Logs del parsing de JSON

## Posibles Causas del Problema

### 1. **Backend No Ejecutándose**
- Verifica que `php artisan serve` esté corriendo
- Verifica que el puerto 8000 esté disponible

### 2. **URL Incorrecta**
- Si usas emulador Android, puede necesitar `10.0.2.2:8000`
- Si usas dispositivo físico, puede necesitar tu IP local

### 3. **Formato de Respuesta Diferente**
- El backend puede estar devolviendo un formato JSON diferente
- Los logs mostrarán exactamente qué formato está devolviendo

### 4. **Problemas de Red**
- Firewall bloqueando conexiones
- Red WiFi con restricciones

## Debugging Paso a Paso

### 1. **Verificar Conectividad**
Los logs mostrarán:
```
[AuthService] Buscando URL del backend...
[AuthService] Probando URL: http://127.0.0.1:8000/api
[AuthService] Respuesta de http://127.0.0.1:8000/api - Status: 200
[AuthService] URL encontrada: http://127.0.0.1:8000/api
```

### 2. **Verificar Petición de Login**
Los logs mostrarán:
```
[AuthService] Iniciando login para: tu@email.com
[AuthService] Request body: {"email":"tu@email.com","password":"tucontraseña"}
[AuthService] Enviando petición HTTP...
[AuthService] Respuesta recibida - Status: 200
[AuthService] Response body: {"token":"...","user":{...}}
```

### 3. **Verificar Parsing de Respuesta**
Los logs mostrarán:
```
[AuthResponse] Parsing JSON: {"token":"...","user":{...}}
[AuthResponse] Parsed values:
[AuthResponse] - token: ...
[AuthResponse] - user: {...}
[AuthResponse] - success: true
```

## Configuración Manual

Si necesitas configurar manualmente la URL del backend:

```dart
// En cualquier controlador
final authService = Get.find<AuthService>();
authService.setBaseUrl('http://tu-ip:8000/api');
```

## Próximos Pasos

1. **Ejecuta la aplicación** y revisa los logs
2. **Identifica el problema específico** basado en los logs
3. **Ajusta la configuración** según sea necesario
4. **Reporta el resultado** para ajustes adicionales

## Contacto para Soporte

Si el problema persiste, proporciona:
1. Los logs completos de la consola
2. La URL donde está ejecutándose tu backend
3. El formato de respuesta que devuelve tu backend Laravel 