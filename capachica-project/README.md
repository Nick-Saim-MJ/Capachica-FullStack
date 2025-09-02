# capachica-project
🌐 Proyecto de Turismo - Backend Laravel 12 & Frontend Angular 19
Este repositorio contiene un sistema completo dividido en dos partes:

backend/: Aplicación construida con Laravel 12 para la gestión del sistema.

frontend/: Interfaz de usuario desarrollada con Angular 19.

📁 Estructura del Proyecto
graphql
Copiar código
├── backend/        # API REST con Laravel 12
└── frontend/       # Aplicación SPA en Angular 19
🚀 Requisitos
Backend
PHP 8.2+

Composer

MySQL o PostgreSQL

Laravel 12

Laravel Sanctum (para autenticación)

Spatie Laravel Permission (para roles y permisos)

Frontend
Node.js 18+

Angular CLI v19

⚙️ Instalación del Backend (Laravel 12)
bash
Copiar código
cd backend

# Instalar dependencias
composer install

# Copiar el archivo de entorno
cp .env.example .env

# Generar la clave de aplicación
php artisan key:generate

# Configurar tu base de datos en .env

# Ejecutar migraciones
php artisan migrate

# Ejecutar los seeders para crear roles, permisos y usuario admin
php artisan db:seed --class=RolesAndPermissionsSeeder

# Iniciar el servidor local
php artisan serve
✅ Esto creará automáticamente:

Permisos básicos del sistema.

Roles: admin, operator, user.

Usuario Admin:

Email: admin@turismo.com

Password: password123

🎨 Instalación del Frontend (Angular 19 + Tailwind CSS)
bash
Copiar código
cd frontend

# Instalar dependencias
npm install

# Iniciar la app Angular
ng serve
Tailwind ya está configurado mediante tailwind.config.ts y styles.css.

Puedes personalizar estilos desde:

src/styles.css → donde encontrarás las utilidades y componentes custom usando @apply.

🧪 Comandos Útiles
Backend
bash
Copiar código
php artisan migrate:fresh --seed         # Reinicia y llena la base de datos
php artisan tinker                       # Probar funcionalidades desde consola
php artisan route:list                   # Ver rutas disponibles
Frontend
bash
Copiar código
ng build --configuration production      # Compilar para producción
ng generate component <name>             # Crear nuevos componentes
🔐 Autenticación y Control de Acceso
Este proyecto usa:

Laravel Sanctum: Para autenticación de usuarios vía tokens.

Spatie Laravel Permission: Para control de acceso basado en roles y permisos.

Los permisos y roles se generan automáticamente al ejecutar el seeder RolesAndPermissionsSeeder.

✍️ Contribuciones
¡Contribuciones son bienvenidas! Puedes enviar pull requests o reportar issues.