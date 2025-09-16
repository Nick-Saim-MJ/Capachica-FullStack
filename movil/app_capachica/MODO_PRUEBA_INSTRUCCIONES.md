# Modo de Prueba - Instrucciones

## Estado Actual
✅ **Modo de prueba ACTIVADO** - La aplicación simula las respuestas del backend

## ¿Qué hace el Modo de Prueba?

### 1. **Simula el Backend**
- No necesita que tu backend Laravel esté ejecutándose
- Simula todas las respuestas HTTP
- Permite probar la funcionalidad completa de la app

### 2. **Login con Email y Contraseña**
- Funciona con cualquier email y contraseña
- Simula un login exitoso
- Guarda el token y datos del usuario
- Muestra mensaje de éxito

### 3. **Google Sign-In**
- Simula la obtención de URL de Google
- Permite probar el flujo completo
- No requiere configuración real de Google OAuth

## Cómo Probar

### 1. **Login Normal**
1. Ve a la pantalla de login
2. Ingresa cualquier email (ej: `tu@email.com`)
3. Ingresa cualquier contraseña (ej: `123456`)
4. Presiona "Iniciar Sesión"
5. Deberías ver un mensaje de éxito

### 2. **Google Sign-In**
1. Ve a la pantalla de login
2. Presiona "Continuar con Google"
3. La app simulará el proceso de autenticación
4. Deberías ver un mensaje de éxito

## Logs que Verás

### Login Normal:
```
[LoginController] Iniciando proceso de login.
[AuthService] Buscando URL del backend...
[AuthService] Modo de prueba activado - simulando backend encontrado
[LoginController] Backend encontrado en: http://127.0.0.1:8000/api
[AuthService] Probando conectividad con el backend...
[AuthService] Modo de prueba activado - simulando conectividad exitosa
[LoginController] Conectividad OK, procediendo con login...
[AuthService] Iniciando login para: tu@email.com
[AuthService] Usando modo de prueba - simulando respuesta del backend
[AuthService] Respuesta de prueba: {token: test_token_123456789, user: {...}}
[LoginController] Login exitoso. Respuesta del servicio recibida.
[LoginController] Token: test_token_123456789
[LoginController] Usuario: Usuario de Prueba
```

### Google Sign-In:
```
[WebView] Iniciando carga de URL de Google...
[WebView] Buscando URL del backend...
[AuthService] Modo de prueba activado - simulando backend encontrado
[WebView] Backend encontrado en: http://127.0.0.1:8000/api
[WebView] Conectividad OK, obteniendo URL de Google...
[WebView] Probando endpoint de Google...
[AuthService] Modo de prueba activado - simulando endpoint de Google disponible
[WebView] Endpoint de Google OK, procediendo...
[AuthProvider] Obteniendo URL de autenticación de Google...
[AuthProvider] Modo de prueba activado - simulando URL de Google
[WebView] URL de autenticación obtenida: https://accounts.google.com/...
```

## Datos de Prueba

### Usuario Simulado:
- **ID**: 1
- **Nombre**: Usuario de Prueba
- **Email**: El que ingreses en el formulario
- **Token**: test_token_123456789

### Respuestas Simuladas:
- **Login**: Simula respuesta exitosa con token
- **Google Auth**: Simula URL de autenticación de Google
- **Conectividad**: Simula que el backend está disponible

## Para Desactivar el Modo de Prueba

Cuando tengas tu backend Laravel funcionando:

1. Abre el archivo: `lib/app/core/config/backend_config.dart`
2. Cambia la línea:
   ```dart
   static const bool testMode = true;
   ```
   Por:
   ```dart
   static const bool testMode = false;
   ```

## Configurar tu Backend Real

### 1. **Ejecutar Laravel**
```bash
cd tu-proyecto-laravel
php artisan serve
```

### 2. **Verificar que esté funcionando**
```bash
curl http://127.0.0.1:8000/api
```

### 3. **Implementar endpoints necesarios**
- POST /api/login
- POST /api/register
- GET /api/auth/google
- POST /api/logout

### 4. **Desactivar modo de prueba**
Cambiar `testMode = false` en la configuración

## Ventajas del Modo de Prueba

✅ **Desarrollo independiente**: Puedes trabajar en la app sin backend
✅ **Testing rápido**: Pruebas inmediatas de la funcionalidad
✅ **Debugging fácil**: Logs detallados de cada paso
✅ **Demo funcional**: La app funciona completamente
✅ **Sin dependencias**: No necesita servidor ni configuración externa

## Próximos Pasos

1. **Prueba el login** con cualquier email y contraseña
2. **Prueba Google Sign-In** para ver el flujo completo
3. **Revisa los logs** para entender el proceso
4. **Configura tu backend** cuando esté listo
5. **Desactiva el modo de prueba** para usar el backend real

¡La aplicación ahora debería funcionar completamente en modo de prueba! 