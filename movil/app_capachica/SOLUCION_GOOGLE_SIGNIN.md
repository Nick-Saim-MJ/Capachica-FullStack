# Solución para Problema de Google Sign-In

## Problema Identificado
Al seleccionar el botón de Google Sign-In, la aplicación se queda cargando y no avanza. El error indica que no se puede obtener la URL de autenticación de Google del backend.

## Análisis del Error
```
flutter: [AuthProvider] Obteniendo URL de autenticación de Google...
flutter: [WebView] Error al cargar la URL inicial: No se pudo obtener la URL de autenticación de Google del backend.
```

## Soluciones Implementadas

### 1. **Búsqueda Automática del Backend**
- La aplicación ahora busca automáticamente la URL correcta del backend
- Prueba múltiples URLs comunes (localhost, 127.0.0.1, IPs locales)
- Actualiza dinámicamente la URL base del AuthProvider

### 2. **Logging Detallado**
- Logs extensivos en cada paso del proceso
- Identificación exacta de dónde falla el proceso
- Información detallada de las respuestas del backend

### 3. **Prueba de Endpoints**
- Verificación de conectividad general
- Prueba específica del endpoint `/auth/google`
- Validación de la respuesta del backend

### 4. **Manejo de Errores Mejorado**
- Timeouts específicos para cada petición
- Mensajes de error descriptivos
- Manejo de diferentes códigos de estado HTTP

## Verificaciones Necesarias en el Backend

### 1. **Verificar que el Backend esté Ejecutándose**
```bash
# En tu laptop, verifica que Laravel esté corriendo
php artisan serve
# Debería mostrar: Server running on http://127.0.0.1:8000
```

### 2. **Verificar que el Endpoint de Google Exista**
El backend debe tener una ruta implementada para `/api/auth/google` que devuelva la URL de autenticación de Google.

**Ejemplo de implementación en Laravel:**
```php
// routes/api.php
Route::get('/auth/google', [AuthController::class, 'getGoogleAuthUrl']);

// AuthController.php
public function getGoogleAuthUrl()
{
    $url = Socialite::driver('google')->stateless()->redirect()->getTargetUrl();
    
    return response()->json([
        'data' => [
            'url' => $url
        ],
        'success' => true
    ]);
}
```

### 3. **Verificar Configuración de Google OAuth**
En tu backend Laravel, verifica que tengas configurado:
- Google OAuth credentials en `.env`
- Laravel Socialite configurado
- Rutas de callback implementadas

## Cómo Probar

### 1. **Ejecutar la Aplicación**
```bash
flutter run --debug
```

### 2. **Revisar los Logs**
Cuando selecciones Google Sign-In, revisa la consola para ver los logs detallados:

```
[WebView] Iniciando carga de URL de Google...
[WebView] Buscando URL del backend...
[AuthService] Buscando URL del backend...
[AuthService] Probando URL: http://127.0.0.1:8000/api
[AuthService] URL encontrada: http://127.0.0.1:8000/api
[WebView] Backend encontrado en: http://127.0.0.1:8000/api
[WebView] Conectividad OK, obteniendo URL de Google...
[WebView] Probando endpoint de Google...
[AuthService] Probando endpoint de Google...
[AuthService] Respuesta del endpoint Google - Status: 200
[WebView] Endpoint de Google OK, procediendo...
[AuthProvider] Obteniendo URL de autenticación de Google...
[AuthProvider] Respuesta de Google auth - Status: 200
[AuthProvider] Respuesta de Google auth - Body: {"data":{"url":"https://accounts.google.com/..."}}
[WebView] URL de autenticación obtenida: https://accounts.google.com/...
```

## Posibles Causas del Problema

### 1. **Backend No Ejecutándose**
- Verifica que `php artisan serve` esté corriendo
- Verifica que el puerto 8000 esté disponible

### 2. **Endpoint de Google No Implementado**
- El backend no tiene la ruta `/api/auth/google`
- La ruta existe pero devuelve error 404 o 500

### 3. **Configuración de Google OAuth Faltante**
- Credenciales de Google no configuradas en `.env`
- Laravel Socialite no instalado o configurado

### 4. **URL Incorrecta**
- Si usas emulador Android, puede necesitar `10.0.2.2:8000`
- Si usas dispositivo físico, puede necesitar tu IP local

## Configuración del Backend Laravel

### 1. **Instalar Laravel Socialite**
```bash
composer require laravel/socialite
```

### 2. **Configurar Google OAuth**
En `.env`:
```
GOOGLE_CLIENT_ID=tu-client-id
GOOGLE_CLIENT_SECRET=tu-client-secret
GOOGLE_REDIRECT_URI=http://127.0.0.1:8000/auth/google/callback
```

### 3. **Implementar Rutas**
En `routes/api.php`:
```php
Route::get('/auth/google', [AuthController::class, 'getGoogleAuthUrl']);
Route::get('/auth/google/callback', [AuthController::class, 'handleGoogleCallback']);
```

### 4. **Implementar Controlador**
```php
use Laravel\Socialite\Facades\Socialite;

public function getGoogleAuthUrl()
{
    try {
        $url = Socialite::driver('google')->stateless()->redirect()->getTargetUrl();
        
        return response()->json([
            'data' => [
                'url' => $url
            ],
            'success' => true
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'error' => $e->getMessage()
        ], 500);
    }
}
```

## Debugging Paso a Paso

### 1. **Verificar Backend**
```bash
curl http://127.0.0.1:8000/api/auth/google
```

### 2. **Verificar Respuesta**
La respuesta debe ser algo como:
```json
{
  "data": {
    "url": "https://accounts.google.com/o/oauth2/auth?..."
  },
  "success": true
}
```

### 3. **Verificar Configuración**
- Google OAuth credentials válidas
- Laravel Socialite configurado
- Rutas implementadas correctamente

## Próximos Pasos

1. **Verifica que tu backend esté ejecutándose**
2. **Verifica que tengas el endpoint `/api/auth/google` implementado**
3. **Ejecuta la aplicación y revisa los logs**
4. **Identifica el problema específico basado en los logs**
5. **Implementa la configuración faltante en el backend**

## Contacto para Soporte

Si el problema persiste, proporciona:
1. Los logs completos de la consola
2. La respuesta del endpoint `/api/auth/google` (usando curl)
3. Tu configuración de Google OAuth en Laravel
4. El contenido de tu archivo `routes/api.php` 