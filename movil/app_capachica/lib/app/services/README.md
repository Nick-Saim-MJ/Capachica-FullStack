# AuthService - Documentación

## Descripción
El `AuthService` es una clase que maneja todas las operaciones de autenticación con el backend usando el paquete `http`. Proporciona métodos para login, registro, logout, recuperación de contraseña y verificación de email.

## Endpoints Implementados

### 1. POST /api/register
Registra un nuevo usuario en el sistema.

```dart
final authService = Get.find<AuthService>();
final request = RegisterRequest(
  name: 'Juan Pérez',
  email: 'juan@example.com',
  password: 'password123',
  passwordConfirmation: 'password123',
  phone: '+1234567890',
  country: 'Perú',
  // ... otros campos opcionales
);

try {
  final response = await authService.register(request);
  print('Usuario registrado: ${response.message}');
} catch (e) {
  print('Error en registro: $e');
}
```

### 2. POST /api/login
Inicia sesión con email y contraseña.

```dart
final authService = Get.find<AuthService>();
try {
  final response = await authService.login('juan@example.com', 'password123');
  print('Login exitoso: ${response.message}');
  print('Token: ${response.token}');
  print('Usuario: ${response.user?.name}');
} catch (e) {
  print('Error en login: $e');
}
```

### 3. POST /api/logout
Cierra la sesión del usuario actual.

```dart
final authService = Get.find<AuthService>();
try {
  await authService.logout();
  print('Sesión cerrada exitosamente');
} catch (e) {
  print('Error en logout: $e');
}
```

### 4. POST /api/forgot-password
Solicita un enlace de recuperación de contraseña.

```dart
final authService = Get.find<AuthService>();
try {
  final response = await authService.forgotPassword('juan@example.com');
  print('Enlace enviado: ${response.message}');
} catch (e) {
  print('Error: $e');
}
```

### 5. POST /api/reset-password
Restablece la contraseña usando un token.

```dart
final authService = Get.find<AuthService>();
try {
  final response = await authService.resetPassword(
    email: 'juan@example.com',
    password: 'nuevaPassword123',
    passwordConfirmation: 'nuevaPassword123',
    token: 'token_del_email',
  );
  print('Contraseña restablecida: ${response.message}');
} catch (e) {
  print('Error: $e');
}
```

### 6. GET /api/email/verify/{id}/{hash}
Verifica el email del usuario.

```dart
final authService = Get.find<AuthService>();
try {
  final response = await authService.verifyEmail('user_id', 'verification_hash');
  print('Email verificado: ${response.message}');
} catch (e) {
  print('Error: $e');
}
```

### 7. POST /api/email/verification-notification
Reenvía el email de verificación.

```dart
final authService = Get.find<AuthService>();
try {
  final response = await authService.sendEmailVerification();
  print('Email de verificación reenviado: ${response.message}');
} catch (e) {
  print('Error: $e');
}
```

## Estados de Autenticación

El servicio mantiene el estado de autenticación usando GetX observables:

```dart
final authService = Get.find<AuthService>();

// Verificar si el usuario está logueado
if (authService.isLoggedIn) {
  print('Usuario autenticado');
}

// Obtener el token actual
final token = authService.token.value;

// Obtener el usuario actual
final user = authService.currentUser.value;
```

## Manejo de Errores

Todos los métodos lanzan excepciones con mensajes descriptivos en caso de error:

- **401**: Credenciales inválidas
- **422**: Datos de entrada inválidos
- **500**: Error interno del servidor
- **Otros**: Error de conexión con el código de estado

## Configuración

El servicio está configurado para conectarse a `http://127.0.0.1:8000/api`. Para cambiar la URL base, modifica la constante `_baseUrl` en la clase `AuthService`.

## Integración con GetX

El servicio extiende `GetxService` para persistir durante toda la vida de la aplicación. Se inicializa automáticamente y mantiene el estado de autenticación en el almacenamiento local usando `GetStorage`. 