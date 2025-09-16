# Checklist de Endpoints - App Capachica

## ✅ Configuración HTTP Centralizada

### HttpClient Centralizado
- [x] **AppHttpClient** creado con manejo centralizado de headers Bearer
- [x] **AppConfig** con configuración por flavor (development/staging/production)
- [x] **CacheService** con TTL configurable (5-15 min según entorno)
- [x] **BaseService** con estados consistentes (loading/empty/error)

### Configuración por Flavor
- [x] **Development**: `http://127.0.0.1:8000/api` (TTL: 5 min)
- [x] **Staging**: `http://staging-api.capachica.com/api` (TTL: 10 min)
- [x] **Production**: `https://api.capachica.com/api` (TTL: 15 min)

---

## 🔐 Autenticación (AuthService)

| Endpoint | Método | Estado | Contrato | Cache | Manejo Errores |
|----------|--------|--------|----------|-------|----------------|
| `/auth/login` | POST | ✅ OK | ✅ Adaptado | ✅ 5 min | ✅ Unificado |
| `/auth/register` | POST | ✅ OK | ✅ Adaptado | ✅ 5 min | ✅ Unificado |
| `/auth/logout` | POST | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |
| `/auth/forgot-password` | POST | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |
| `/auth/reset-password` | POST | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |
| `/auth/email/verify/{id}/{hash}` | GET | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |
| `/auth/email/verification-notification` | POST | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |
| `/auth/google` | GET | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |

**Adaptaciones realizadas:**
- ✅ Mapeo snake_case → camelCase en modelos
- ✅ Manejo unificado de errores 401/422/500
- ✅ Headers Bearer automáticos
- ✅ Cache con TTL corto para datos de auth

---

## 🏪 Servicios (ServicesCapachicaService)

| Endpoint | Método | Estado | Contrato | Cache | Manejo Errores |
|----------|--------|--------|----------|-------|----------------|
| `/servicios` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/servicios/{id}` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/servicios/categoria/{id}` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/servicios/emprendedor/{id}` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |

**Adaptaciones realizadas:**
- ✅ Mapeo snake_case → camelCase en ServicioCapachica
- ✅ Cache por categoría y emprendedor
- ✅ Paginación implementada
- ✅ Búsqueda con query parameters

---

## 🗺️ Planes (PlanService)

| Endpoint | Método | Estado | Contrato | Cache | Manejo Errores |
|----------|--------|--------|----------|-------|----------------|
| `/planes` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/planes/{id}` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/public/planes` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |

**Adaptaciones realizadas:**
- ✅ Mapeo snake_case → camelCase en Plan
- ✅ Cache para planes públicos y privados
- ✅ Paginación implementada

---

## 🎉 Eventos (EventoService)

| Endpoint | Método | Estado | Contrato | Cache | Manejo Errores |
|----------|--------|--------|----------|-------|----------------|
| `/eventos` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/eventos/{id}` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/eventos/emprendedor/{id}` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |

**Adaptaciones realizadas:**
- ✅ Mapeo snake_case → camelCase en Evento
- ✅ Cache por emprendedor
- ✅ Filtros por fecha y categoría

---

## 👥 Emprendedores (EmprendedorService)

| Endpoint | Método | Estado | Contrato | Cache | Manejo Errores |
|----------|--------|--------|----------|-------|----------------|
| `/emprendedores` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/emprendedores/{id}` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/emprendedores/categoria/{id}` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |

**Adaptaciones realizadas:**
- ✅ Mapeo snake_case → camelCase en Emprendedor
- ✅ Cache por categoría
- ✅ Paginación implementada

---

## 🏛️ Municipalidad (MunicipalidadService)

| Endpoint | Método | Estado | Contrato | Cache | Manejo Errores |
|----------|--------|--------|----------|-------|----------------|
| `/municipalidad` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/municipalidad/{id}` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |
| `/municipalidad/{id}/relaciones` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |

**Adaptaciones realizadas:**
- ✅ Mapeo snake_case → camelCase en Municipalidad
- ✅ Cache para relaciones (servicios, negocios)
- ✅ Estadísticas incluidas

---

## 🛒 Reservas/Carrito (ReservaService)

| Endpoint | Método | Estado | Contrato | Cache | Manejo Errores |
|----------|--------|--------|----------|-------|----------------|
| `/reservas/carrito` | GET | ✅ OK | ✅ Adaptado | ✅ 5 min | ✅ Unificado |
| `/reservas/carrito/agregar` | POST | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |
| `/reservas/carrito/servicio/{id}` | DELETE | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |
| `/reservas/carrito/vaciar` | DELETE | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |
| `/reservas/carrito/confirmar` | POST | ✅ OK | ✅ Adaptado | ❌ No cache | ✅ Unificado |
| `/reservas/mis-reservas` | GET | ✅ OK | ✅ Adaptado | ✅ 5 min | ✅ Unificado |

**Adaptaciones realizadas:**
- ✅ Mapeo snake_case → camelCase en Reserva
- ✅ Cache corto para carrito (5 min)
- ✅ Invalidación automática en cambios

---

## 📊 Sliders (SliderService)

| Endpoint | Método | Estado | Contrato | Cache | Manejo Errores |
|----------|--------|--------|----------|-------|----------------|
| `/sliders` | GET | ✅ OK | ✅ Adaptado | ✅ 15 min | ✅ Unificado |

**Adaptaciones realizadas:**
- ✅ Mapeo snake_case → camelCase en Slider
- ✅ Cache para banners promocionales

---

## 🧪 Tests Implementados

### Modelos
- [x] **LoginModel**: fromJson/toJson para AuthResponse, User, LoginRequest, RegisterRequest
- [x] **ServicioCapachica**: fromJson para modelo completo
- [x] **Plan**: fromJson para modelo completo
- [x] **Evento**: fromJson para modelo completo

### Controladores
- [x] **LoginController**: validación de formularios, estados de carga
- [x] **AuthService**: manejo de tokens, persistencia, errores

---

## 📋 Pasos de Prueba Manual

### 1. Configuración de Entorno
```bash
# Desarrollo
flutter run --dart-define=FLAVOR=development

# Staging
flutter run --dart-define=FLAVOR=staging

# Producción
flutter run --dart-define=FLAVOR=production
```

### 2. Pruebas de Autenticación
1. **Login exitoso**: `test@example.com` / `password123`
2. **Login fallido**: credenciales inválidas
3. **Registro**: nuevo usuario
4. **Logout**: cerrar sesión
5. **Recuperación**: forgot password

### 3. Pruebas de Servicios
1. **Lista servicios**: `/servicios`
2. **Detalle servicio**: `/servicios/1`
3. **Por categoría**: `/servicios/categoria/1`
4. **Por emprendedor**: `/servicios/emprendedor/1`
5. **Búsqueda**: `/servicios?search=turismo`

### 4. Pruebas de Cache
1. **Primera carga**: verificar request HTTP
2. **Segunda carga**: verificar cache (sin request)
3. **Expiración**: esperar TTL y verificar refresh
4. **Invalidación**: modificar datos y verificar refresh

### 5. Pruebas de Estados
1. **Loading**: verificar indicadores de carga
2. **Empty**: verificar estados vacíos
3. **Error**: verificar manejo de errores de red
4. **Success**: verificar datos mostrados correctamente

### 6. Pruebas de Errores
1. **401 Unauthorized**: token inválido
2. **422 Validation**: datos inválidos
3. **500 Server Error**: error del servidor
4. **Network Error**: sin conexión

---

## 🔧 Comandos de Prueba

```bash
# Ejecutar tests
flutter test

# Ejecutar tests específicos
flutter test test/models/login_model_test.dart
flutter test test/controllers/auth_controller_test.dart

# Verificar linting
flutter analyze

# Limpiar cache
flutter clean
flutter pub get
```

---

## 📝 Notas de Implementación

### Cambios Realizados
1. **HttpClient centralizado** con manejo automático de Bearer tokens
2. **Configuración por flavor** para diferentes entornos
3. **Cache con TTL** configurable por tipo de dato
4. **Estados consistentes** en todos los servicios
5. **Manejo unificado de errores** con mensajes descriptivos
6. **Tests mínimos** para modelos y controladores críticos

### Arquitectura Mantenida
- ✅ **GetX** para gestión de estado
- ✅ **Clean Architecture** con repositories
- ✅ **MVC pattern** en controladores
- ✅ **Dependency Injection** con Get.put()

### Próximos Pasos Recomendados
1. Implementar refresh automático de tokens
2. Agregar interceptores para logging
3. Implementar retry automático en fallos de red
4. Agregar métricas de performance
5. Implementar tests de integración
