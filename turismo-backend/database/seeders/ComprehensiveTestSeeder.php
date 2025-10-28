<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Municipalidad;
use App\Models\Asociacion;
use App\Models\Emprendedor;
use App\Models\Servicio;
use App\Models\ServicioHorario;
use App\Models\Categoria;
use App\Models\Plan;
use App\Models\PlanDia;
use App\Models\PlanEmprendedor;
use App\Models\PlanInscripcion;
use App\Models\PlanDiaServicio;
use App\Models\Reserva;
use App\Models\ReservaServicio;
use App\Models\Evento;
use App\Models\Slider;
use App\Models\SliderDescripcion;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class ComprehensiveTestSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('🚀 Iniciando seeder completo del sistema de turismo Capachica...');
        
        // 1. Crear roles y permisos
        $this->createRolesAndPermissions();
        
        // 2. Crear usuarios de prueba
        $users = $this->createUsers();
        
        // 3. Crear municipalidad
        $municipalidad = $this->createMunicipalidad();
        
        // 4. Crear categorías
        $categorias = $this->createCategorias();
        
        // 5. Crear asociaciones
        $asociaciones = $this->createAsociaciones($municipalidad);
        
        // 6. Crear emprendedores
        $emprendedores = $this->createEmprendedores($asociaciones);
        
        // 7. Crear servicios con horarios
        $servicios = $this->createServicios($emprendedores, $categorias);
        
        // 8. Crear planes turísticos completos
        $planes = $this->createPlanes($emprendedores, $servicios, $users);
        
        // 9. Crear inscripciones a planes
        $this->createInscripciones($planes, $users);
        
        // 10. Crear reservas
        $this->createReservas($servicios, $users);
        
        // 11. Crear eventos
        $this->createEventos($emprendedores);
        
        // 12. Crear sliders
        $this->createSliders($municipalidad, $emprendedores);
        
        // 13. Asociar usuarios con emprendimientos
        $this->associateUsersWithEmprendimientos($users, $emprendedores);
        
        $this->command->info('✅ Seeder completo finalizado exitosamente!');
        $this->showSummary();
    }
    
    private function createRolesAndPermissions()
    {
        $this->command->info('📋 Creando roles y permisos...');
        
        $permissions = [
            'user_create', 'user_read', 'user_update', 'user_delete',
            'role_create', 'role_read', 'role_update', 'role_delete',
            'permission_read', 'permission_assign',
            'emprendedor_create', 'emprendedor_read', 'emprendedor_update', 'emprendedor_delete',
            'servicio_create', 'servicio_read', 'servicio_update', 'servicio_delete',
            'categoria_create', 'categoria_read', 'categoria_update', 'categoria_delete',
            'asociacion_create', 'asociacion_read', 'asociacion_update', 'asociacion_delete',
            'municipalidad_create', 'municipalidad_read', 'municipalidad_update', 'municipalidad_delete',
            'reserva_create', 'reserva_read', 'reserva_update', 'reserva_delete',
            'slider_create', 'slider_read', 'slider_update', 'slider_delete',
            'evento_create', 'evento_read', 'evento_update', 'evento_delete',
            'plan_create', 'plan_read', 'plan_update', 'plan_delete',
            'plan_manage_emprendedores', 'plan_manage_inscripciones',
            'inscripcion_create', 'inscripcion_read', 'inscripcion_update', 'inscripcion_delete',
            'inscripcion_confirmar', 'inscripcion_cancelar',
            'dashboard_read', 'estadisticas_read'
        ];
        
        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission, 'guard_name' => 'web']);
        }
        
        $adminRole = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web']);
        $userRole = Role::firstOrCreate(['name' => 'user', 'guard_name' => 'web']);
        $emprendedorRole = Role::firstOrCreate(['name' => 'emprendedor', 'guard_name' => 'web']);
        $moderadorRole = Role::firstOrCreate(['name' => 'moderador', 'guard_name' => 'web']);
        
        $adminRole->givePermissionTo(Permission::where('guard_name', 'web')->get());
    }
    
    private function createUsers()
    {
        $this->command->info('👥 Creando usuarios de prueba...');
        
        $users = [];
        
        // Admin
        $users['admin'] = User::firstOrCreate(
            ['email' => 'admin@capachica.com'],
            [
                'name' => 'Administrador Sistema',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
                'phone' => '951234567',
                'country' => 'Perú',
                'birth_date' => '1985-01-15',
                'address' => 'Plaza Principal, Capachica',
                'gender' => 'male',
                'preferred_language' => 'es',
                'active' => true,
            ]
        );
        $users['admin']->assignRole('admin');
        
        // Usuario turista
        $users['turista'] = User::firstOrCreate(
            ['email' => 'maria@turista.com'],
            [
                'name' => 'María González',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
                'phone' => '987654321',
                'country' => 'España',
                'birth_date' => '1990-06-20',
                'address' => 'Madrid, España',
                'gender' => 'female',
                'preferred_language' => 'es',
                'active' => true,
            ]
        );
        $users['turista']->assignRole('user');
        
        // Emprendedor principal
        $users['emprendedor1'] = User::firstOrCreate(
            ['email' => 'juan@llachon.com'],
            [
                'name' => 'Juan Mamani',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
                'phone' => '955444333',
                'country' => 'Perú',
                'birth_date' => '1980-12-10',
                'address' => 'Comunidad Llachón, Capachica',
                'gender' => 'male',
                'preferred_language' => 'es',
                'active' => true,
            ]
        );
        $users['emprendedor1']->assignRole('emprendedor');
        
        // Segundo emprendedor
        $users['emprendedor2'] = User::firstOrCreate(
            ['email' => 'rosa@artesania.com'],
            [
                'name' => 'Rosa Quispe',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
                'phone' => '956777888',
                'country' => 'Perú',
                'birth_date' => '1975-08-25',
                'address' => 'Comunidad Escallani, Capachica',
                'gender' => 'female',
                'preferred_language' => 'es',
                'active' => true,
            ]
        );
        $users['emprendedor2']->assignRole('emprendedor');
        
        // Moderador
        $users['moderador'] = User::firstOrCreate(
            ['email' => 'moderador@capachica.com'],
            [
                'name' => 'Carlos Moderador',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
                'phone' => '954321987',
                'country' => 'Perú',
                'birth_date' => '1988-03-15',
                'address' => 'Puno, Perú',
                'gender' => 'male',
                'preferred_language' => 'es',
                'active' => true,
            ]
        );
        $users['moderador']->assignRole('moderador');
        
        return $users;
    }
    
    private function createMunicipalidad()
    {
        $this->command->info('🏛️ Creando municipalidad...');
        
        return Municipalidad::create([
            'nombre' => 'Municipalidad Distrital de Capachica',
            'descripcion' => 'Municipalidad que promueve el turismo sostenible en la península de Capachica.',
            'red_facebook' => 'https://facebook.com/municapachica',
            'red_instagram' => 'https://instagram.com/municapachica',
            'red_youtube' => 'https://youtube.com/municapachica',
            'coordenadas_x' => -15.6425,
            'coordenadas_y' => -69.8330,
            'frase' => '¡Bienvenidos a Capachica, Paraíso del Lago Titicaca!',
            'comunidades' => '16 comunidades: Llachón, Cotos, Siale, Hilata, Isañura, San Cristóbal, Escallani, Chillora, Yapura, Collasuyo, Miraflores, Villa Lago, Capano, Ccotos, Yancaco y Central.',
            'historiafamilias' => 'Familias que mantienen tradiciones ancestrales por generaciones.',
            'historiacapachica' => 'Península con rica historia preinca e inca en el lago Titicaca.',
            'comite' => 'Comité de desarrollo turístico formado por comunidades y autoridades.',
            'mision' => 'Promover desarrollo sostenible mediante turismo vivencial.',
            'vision' => 'Ser distrito modelo en turismo sostenible al 2030.',
            'valores' => 'Honestidad, Transparencia, Respeto al medio ambiente, Identidad cultural.',
            'ordenanzamunicipal' => 'Ordenanza Municipal N° 015-2023-MDP',
            'alianzas' => 'MINCETUR, DIRCETUR Puno, Programa TRC, PNUD, GIZ',
            'correo' => 'informes@municapachica.gob.pe',
            'horariodeatencion' => 'Lunes a Viernes: 8:00 am - 4:00 pm'
        ]);
    }
    
    private function createCategorias()
    {
        $this->command->info('📂 Creando categorías...');
        
        $categorias = [
            ['nombre' => 'Alojamiento', 'descripcion' => 'Hospedaje rural y ecolodges', 'icono_url' => 'icons/alojamiento.svg'],
            ['nombre' => 'Alimentación', 'descripcion' => 'Comida tradicional de la región', 'icono_url' => 'icons/alimentacion.svg'],
            ['nombre' => 'Artesanía', 'descripcion' => 'Productos hechos a mano', 'icono_url' => 'icons/artesania.svg'],
            ['nombre' => 'Transporte', 'descripcion' => 'Transporte terrestre y lacustre', 'icono_url' => 'icons/transporte.svg'],
            ['nombre' => 'Actividades', 'descripcion' => 'Experiencias y actividades turísticas', 'icono_url' => 'icons/actividades.svg'],
            ['nombre' => 'Guiado', 'descripcion' => 'Servicios de guías turísticos', 'icono_url' => 'icons/guiado.svg']
        ];
        
        $createdCategorias = [];
        foreach ($categorias as $categoria) {
            $createdCategorias[] = Categoria::create($categoria);
        }
        
        return $createdCategorias;
    }
    
    private function createAsociaciones($municipalidad)
    {
        $this->command->info('🤝 Creando asociaciones...');
        
        $asociaciones = [
            [
                'nombre' => 'Asociación de Turismo Vivencial Llachón',
                'descripcion' => 'Familias que ofrecen turismo vivencial en Llachón.',
                'telefono' => '951234567',
                'email' => 'turvivllachon@gmail.com',
                'municipalidad_id' => $municipalidad->id,
                'estado' => true,
                'imagen' => 'asociaciones/llachon.jpg'
            ],
            [
                'nombre' => 'Asociación de Artesanos de Capachica',
                'descripcion' => 'Artesanos tradicionales de textiles y cerámica.',
                'telefono' => '951987654',
                'email' => 'artesanoscapachica@gmail.com',
                'municipalidad_id' => $municipalidad->id,
                'estado' => true,
                'imagen' => 'asociaciones/artesanos.jpg'
            ],
            [
                'nombre' => 'Asociación de Transportistas Lacustres',
                'descripcion' => 'Servicios de transporte en el lago Titicaca.',
                'telefono' => '952345678',
                'email' => 'transportistas.titicaca@gmail.com',
                'municipalidad_id' => $municipalidad->id,
                'estado' => true,
                'imagen' => 'asociaciones/transportistas.jpg'
            ]
        ];
        
        $createdAsociaciones = [];
        foreach ($asociaciones as $asociacion) {
            $createdAsociaciones[] = Asociacion::create($asociacion);
        }
        
        return $createdAsociaciones;
    }
    
    private function createEmprendedores($asociaciones)
    {
        $this->command->info('🏪 Creando emprendedores...');
        
        $emprendedores = [
            [
                'nombre' => 'Casa Hospedaje Samary',
                'tipo_servicio' => 'Alojamiento',
                'descripcion' => 'Casa hospedaje familiar con vista al lago Titicaca.',
                'ubicacion' => 'Comunidad Llachón, a 200m del muelle',
                'telefono' => '951222333',
                'email' => 'samary.llachon@gmail.com',
                'pagina_web' => 'https://samaryllachon.com',
                'horario_atencion' => 'Todos los días: 7:00 am - 10:00 pm',
                'precio_rango' => 'S/. 50 - S/. 100',
                'metodos_pago' => json_encode(['Efectivo', 'Transferencia', 'Yape']),
                'capacidad_aforo' => 12,
                'numero_personas_atiende' => 3,
                'comentarios_resenas' => 'Excelente servicio y comida deliciosa.',
                'imagenes' => json_encode(['samary1.jpg', 'samary2.jpg']),
                'categoria' => 'Alojamiento',
                'certificaciones' => 'TRC MINCETUR',
                'idiomas_hablados' => json_encode(['Español', 'Inglés básico', 'Quechua']),
                'opciones_acceso' => json_encode(['A pie', 'En bote']),
                'facilidades_discapacidad' => true,
                'asociacion_id' => $asociaciones[0]->id,
                'estado' => true
            ],
            [
                'nombre' => 'Restaurante Sumaq Mijuna',
                'tipo_servicio' => 'Alimentación',
                'descripcion' => 'Platos típicos con productos locales y orgánicos.',
                'ubicacion' => 'Plaza principal de Capachica',
                'telefono' => '954333222',
                'email' => 'sumaqmijuna@gmail.com',
                'horario_atencion' => 'Lunes a Domingo: 8:00 am - 8:00 pm',
                'precio_rango' => 'S/. 15 - S/. 35',
                'metodos_pago' => json_encode(['Efectivo', 'Yape']),
                'capacidad_aforo' => 30,
                'numero_personas_atiende' => 5,
                'comentarios_resenas' => 'La trucha frita es espectacular.',
                'imagenes' => json_encode(['sumaq1.jpg', 'sumaq2.jpg']),
                'categoria' => 'Alimentación',
                'certificaciones' => 'Restaurante Saludable Municipal',
                'idiomas_hablados' => json_encode(['Español', 'Quechua']),
                'opciones_acceso' => json_encode(['A pie', 'Transporte público']),
                'facilidades_discapacidad' => false,
                'asociacion_id' => null,
                'estado' => true
            ],
            [
                'nombre' => 'Artesanías Titicaca',
                'tipo_servicio' => 'Artesanía',
                'descripcion' => 'Taller de artesanía textil con técnicas ancestrales.',
                'ubicacion' => 'Comunidad Escallani, a 500m de la plaza',
                'telefono' => '957888999',
                'email' => 'artesanias.titicaca@gmail.com',
                'horario_atencion' => 'Lunes a Sábado: 9:00 am - 6:00 pm',
                'precio_rango' => 'S/. 10 - S/. 200',
                'metodos_pago' => json_encode(['Efectivo', 'Transferencia']),
                'capacidad_aforo' => 10,
                'numero_personas_atiende' => 2,
                'comentarios_resenas' => 'Hermosos trabajos textiles.',
                'imagenes' => json_encode(['artesania1.jpg', 'artesania2.jpg']),
                'categoria' => 'Artesanía',
                'certificaciones' => 'Marca Perú',
                'idiomas_hablados' => json_encode(['Español', 'Quechua', 'Aymara']),
                'opciones_acceso' => json_encode(['A pie']),
                'facilidades_discapacidad' => false,
                'asociacion_id' => $asociaciones[1]->id,
                'estado' => true
            ],
            [
                'nombre' => 'Transportes Lacustres Titicaca',
                'tipo_servicio' => 'Transporte',
                'descripcion' => 'Servicio de transporte en bote para islas y comunidades.',
                'ubicacion' => 'Muelle principal de Capachica',
                'telefono' => '956777888',
                'email' => 'lacustrestiticaca@gmail.com',
                'pagina_web' => 'https://transportestiticaca.com',
                'horario_atencion' => 'Todos los días: 6:00 am - 5:00 pm',
                'precio_rango' => 'S/. 30 - S/. 150',
                'metodos_pago' => json_encode(['Efectivo', 'Transferencia', 'Yape', 'Tarjeta']),
                'capacidad_aforo' => 15,
                'numero_personas_atiende' => 2,
                'comentarios_resenas' => 'Botes en buen estado y guías conocedores.',
                'imagenes' => json_encode(['transporte1.jpg', 'transporte2.jpg']),
                'categoria' => 'Transporte',
                'certificaciones' => 'MTC, Capitanía de Puertos',
                'idiomas_hablados' => json_encode(['Español', 'Inglés básico']),
                'opciones_acceso' => json_encode(['A pie']),
                'facilidades_discapacidad' => true,
                'asociacion_id' => $asociaciones[2]->id,
                'estado' => true
            ],
            [
                'nombre' => 'Aventuras Titicaca',
                'tipo_servicio' => 'Actividades',
                'descripcion' => 'Kayak, bicicleta, trekking y actividades al aire libre.',
                'ubicacion' => 'Comunidad Cotos, a 1km del centro',
                'telefono' => '959666777',
                'email' => 'aventuras@titicaca.pe',
                'pagina_web' => 'https://aventurastiticaca.pe',
                'horario_atencion' => 'Lunes a Domingo: 7:00 am - 6:00 pm',
                'precio_rango' => 'S/. 40 - S/. 120',
                'metodos_pago' => json_encode(['Efectivo', 'Transferencia', 'Tarjeta']),
                'capacidad_aforo' => 20,
                'numero_personas_atiende' => 4,
                'comentarios_resenas' => 'Increíble experiencia de kayak al amanecer.',
                'imagenes' => json_encode(['aventuras1.jpg', 'aventuras2.jpg']),
                'categoria' => 'Actividades',
                'certificaciones' => 'DIRCETUR, Primeros Auxilios',
                'idiomas_hablados' => json_encode(['Español', 'Inglés', 'Francés básico']),
                'opciones_acceso' => json_encode(['A pie', 'Transporte público']),
                'facilidades_discapacidad' => false,
                'asociacion_id' => null,
                'estado' => true
            ]
        ];
        
        $createdEmprendedores = [];
        foreach ($emprendedores as $emprendedor) {
            $createdEmprendedores[] = Emprendedor::create($emprendedor);
        }
        
        return $createdEmprendedores;
    }
    
    private function createServicios($emprendedores, $categorias)
    {
        $this->command->info('🛎️ Creando servicios...');
        
        $servicios = [
            // Servicios para Casa Hospedaje Samary
            [
                'nombre' => 'Habitación Matrimonial',
                'descripcion' => 'Habitación con cama matrimonial, baño privado y vista al lago.',
                'precio_referencial' => 80.00,
                'emprendedor_id' => $emprendedores[0]->id,
                'latitud' => -15.6428,
                'longitud' => -69.8334,
                'ubicacion_referencia' => 'A 200m del muelle principal de Llachón',
                'categorias' => [$categorias[0]->id], // Alojamiento
                'horarios' => $this->getHorariosAlojamiento()
            ],
            [
                'nombre' => 'Experiencia Cultural',
                'descripcion' => 'Participación en actividades tradicionales como agricultura y pesca.',
                'precio_referencial' => 50.00,
                'emprendedor_id' => $emprendedores[0]->id,
                'latitud' => -15.6430,
                'longitud' => -69.8336,
                'ubicacion_referencia' => 'En las chacras de la comunidad',
                'categorias' => [$categorias[4]->id], // Actividades
                'horarios' => $this->getHorariosActividades()
            ],
            
            // Servicios para Restaurante Sumaq Mijuna
            [
                'nombre' => 'Almuerzo Típico',
                'descripcion' => 'Sopa, plato principal, postre y mate de hierbas.',
                'precio_referencial' => 25.00,
                'emprendedor_id' => $emprendedores[1]->id,
                'latitud' => -15.6420,
                'longitud' => -69.8325,
                'ubicacion_referencia' => 'Plaza principal de Capachica',
                'categorias' => [$categorias[1]->id], // Alimentación
                'horarios' => $this->getHorariosAlmuerzo()
            ],
            
            // Servicios para Artesanías Titicaca
            [
                'nombre' => 'Chullo Tradicional',
                'descripcion' => 'Gorro tradicional tejido a mano con lana de alpaca.',
                'precio_referencial' => 45.00,
                'emprendedor_id' => $emprendedores[2]->id,
                'latitud' => -15.6415,
                'longitud' => -69.8340,
                'ubicacion_referencia' => 'Comunidad Escallani',
                'categorias' => [$categorias[2]->id], // Artesanía
                'horarios' => $this->getHorariosArtesania()
            ],
            [
                'nombre' => 'Taller de Tejido',
                'descripcion' => 'Taller de 2 horas enseñando técnicas básicas de tejido andino.',
                'precio_referencial' => 30.00,
                'emprendedor_id' => $emprendedores[2]->id,
                'latitud' => -15.6415,
                'longitud' => -69.8340,
                'ubicacion_referencia' => 'Comunidad Escallani',
                'categorias' => [$categorias[2]->id, $categorias[4]->id], // Artesanía + Actividades
                'horarios' => $this->getHorariosTaller()
            ],
            
            // Servicios para Transportes Lacustres
            [
                'nombre' => 'Tour a Isla Ticonata',
                'descripcion' => 'Viaje en bote a la isla Ticonata con guiado incluido.',
                'precio_referencial' => 70.00,
                'emprendedor_id' => $emprendedores[3]->id,
                'latitud' => -15.6410,
                'longitud' => -69.8320,
                'ubicacion_referencia' => 'Muelle principal de Capachica',
                'categorias' => [$categorias[3]->id, $categorias[5]->id], // Transporte + Guiado
                'horarios' => $this->getHorariosTour()
            ],
            
            // Servicios para Aventuras Titicaca
            [
                'nombre' => 'Kayak al Amanecer',
                'descripcion' => 'Paseo en kayak para ver el amanecer en el lago.',
                'precio_referencial' => 60.00,
                'emprendedor_id' => $emprendedores[4]->id,
                'latitud' => -15.6405,
                'longitud' => -69.8310,
                'ubicacion_referencia' => 'Comunidad Cotos',
                'categorias' => [$categorias[4]->id], // Actividades
                'horarios' => $this->getHorariosKayak()
            ]
        ];
        
        $createdServicios = [];
        foreach ($servicios as $servicioData) {
            $categoriasIds = $servicioData['categorias'];
            $horarios = $servicioData['horarios'];
            
            unset($servicioData['categorias']);
            unset($servicioData['horarios']);
            
            $servicio = Servicio::create($servicioData);
            
            // Asociar categorías
            $servicio->categorias()->attach($categoriasIds);
            
            // Crear horarios
            foreach ($horarios as $horario) {
                $horario['servicio_id'] = $servicio->id;
                ServicioHorario::create($horario);
            }
            
            $createdServicios[] = $servicio;
        }
        
        return $createdServicios;
    }
    
    private function createPlanes($emprendedores, $servicios, $users)
    {
        $this->command->info('🗺️ Creando planes turísticos...');
        
        $planes = [];
        
        // Plan 1: Experiencia Completa Capachica (3 días)
        $plan1 = Plan::create([
            'nombre' => 'Experiencia Completa Capachica',
            'descripcion' => 'Plan de 3 días que incluye alojamiento, alimentación, actividades culturales y transporte.',
            'que_incluye' => 'Alojamiento, 3 comidas diarias, actividades culturales, transporte lacustre, guiado.',
            'capacidad' => 20,
            'duracion_dias' => 3,
            'es_publico' => true,
            'estado' => 'activo',
            'creado_por_usuario_id' => $users['emprendedor1']->id,
            'precio_total' => 350.00,
            'dificultad' => 'moderado',
            'requerimientos' => 'Ropa abrigada, zapatos cómodos, cámara fotográfica.',
            'que_llevar' => 'Protector solar, gorra, agua, snacks.',
            'imagen_principal' => 'planes/experiencia-completa.jpg',
            'imagenes_galeria' => json_encode(['plan1-1.jpg', 'plan1-2.jpg', 'plan1-3.jpg'])
        ]);
        
        // Asociar emprendedores al plan
        $plan1->agregarEmprendedor($emprendedores[0]->id, [
            'rol' => 'organizador',
            'es_organizador_principal' => true,
            'descripcion_participacion' => 'Provee alojamiento y experiencia cultural',
            'porcentaje_ganancia' => 40.00
        ]);
        
        $plan1->agregarEmprendedor($emprendedores[1]->id, [
            'rol' => 'colaborador',
            'es_organizador_principal' => false,
            'descripcion_participacion' => 'Provee alimentación tradicional',
            'porcentaje_ganancia' => 25.00
        ]);
        
        $plan1->agregarEmprendedor($emprendedores[3]->id, [
            'rol' => 'colaborador',
            'es_organizador_principal' => false,
            'descripcion_participacion' => 'Provee transporte lacustre',
            'porcentaje_ganancia' => 20.00
        ]);
        
        $plan1->agregarEmprendedor($emprendedores[4]->id, [
            'rol' => 'colaborador',
            'es_organizador_principal' => false,
            'descripcion_participacion' => 'Provee actividades de aventura',
            'porcentaje_ganancia' => 15.00
        ]);
        
        // Crear días del plan
        $this->createPlanDias($plan1, $servicios);
        
        $planes[] = $plan1;
        
        // Plan 2: Tour Cultural Express (1 día)
        $plan2 = Plan::create([
            'nombre' => 'Tour Cultural Express',
            'descripcion' => 'Tour de un día enfocado en la cultura y artesanía local.',
            'que_incluye' => 'Almuerzo, taller de tejido, visita a comunidades, transporte.',
            'capacidad' => 15,
            'duracion_dias' => 1,
            'es_publico' => true,
            'estado' => 'activo',
            'creado_por_usuario_id' => $users['emprendedor2']->id,
            'precio_total' => 120.00,
            'dificultad' => 'facil',
            'requerimientos' => 'Ropa cómoda, interés por la cultura local.',
            'que_llevar' => 'Cámara fotográfica, cuaderno para notas.',
            'imagen_principal' => 'planes/tour-cultural.jpg',
            'imagenes_galeria' => json_encode(['plan2-1.jpg', 'plan2-2.jpg'])
        ]);
        
        $plan2->agregarEmprendedor($emprendedores[2]->id, [
            'rol' => 'organizador',
            'es_organizador_principal' => true,
            'descripcion_participacion' => 'Provee taller de tejido y artesanía',
            'porcentaje_ganancia' => 50.00
        ]);
        
        $plan2->agregarEmprendedor($emprendedores[1]->id, [
            'rol' => 'colaborador',
            'es_organizador_principal' => false,
            'descripcion_participacion' => 'Provee almuerzo tradicional',
            'porcentaje_ganancia' => 30.00
        ]);
        
        $plan2->agregarEmprendedor($emprendedores[3]->id, [
            'rol' => 'colaborador',
            'es_organizador_principal' => false,
            'descripcion_participacion' => 'Provee transporte entre comunidades',
            'porcentaje_ganancia' => 20.00
        ]);
        
        $this->createPlanDias($plan2, $servicios);
        $planes[] = $plan2;
        
        return $planes;
    }
    
    private function createPlanDias($plan, $servicios)
    {
        if ($plan->duracion_dias == 3) {
            // Día 1: Llegada y experiencia cultural
            $dia1 = PlanDia::create([
                'plan_id' => $plan->id,
                'numero_dia' => 1,
                'titulo' => 'Llegada y Experiencia Cultural',
                'descripcion' => 'Recepción, instalación y primera experiencia cultural en la comunidad.',
                'hora_inicio' => '14:00:00',
                'hora_fin' => '18:00:00',
                'duracion_estimada_minutos' => 240,
                'notas_adicionales' => 'Incluye merienda tradicional',
                'orden' => 1
            ]);
            
            // Día 2: Actividades y aventura
            $dia2 = PlanDia::create([
                'plan_id' => $plan->id,
                'numero_dia' => 2,
                'titulo' => 'Aventura en el Lago',
                'descripcion' => 'Kayak al amanecer y tour a isla Ticonata.',
                'hora_inicio' => '05:00:00',
                'hora_fin' => '16:00:00',
                'duracion_estimada_minutos' => 660,
                'notas_adicionales' => 'Incluye desayuno y almuerzo',
                'orden' => 2
            ]);
            
            // Día 3: Artesanía y despedida
            $dia3 = PlanDia::create([
                'plan_id' => $plan->id,
                'numero_dia' => 3,
                'titulo' => 'Artesanía y Despedida',
                'descripcion' => 'Taller de tejido y compra de artesanías antes de la partida.',
                'hora_inicio' => '09:00:00',
                'hora_fin' => '12:00:00',
                'duracion_estimada_minutos' => 180,
                'notas_adicionales' => 'Tiempo libre para compras',
                'orden' => 3
            ]);
            
            // Asociar servicios a los días
            $this->associateServiciosToPlanDia($dia1, [$servicios[1]], $plan); // Experiencia cultural
            $this->associateServiciosToPlanDia($dia2, [$servicios[5], $servicios[6]], $plan); // Tour y kayak
            $this->associateServiciosToPlanDia($dia3, [$servicios[4]], $plan); // Taller de tejido
            
        } else {
            // Plan de 1 día
            $dia1 = PlanDia::create([
                'plan_id' => $plan->id,
                'numero_dia' => 1,
                'titulo' => 'Tour Cultural Completo',
                'descripcion' => 'Visita a comunidades, taller de tejido y almuerzo tradicional.',
                'hora_inicio' => '08:00:00',
                'hora_fin' => '17:00:00',
                'duracion_estimada_minutos' => 540,
                'notas_adicionales' => 'Incluye transporte y almuerzo',
                'orden' => 1
            ]);
            
            $this->associateServiciosToPlanDia($dia1, [$servicios[2], $servicios[4], $servicios[5]], $plan);
        }
    }
    
    private function associateServiciosToPlanDia($planDia, $servicios, $plan)
    {
        foreach ($servicios as $index => $servicio) {
            PlanDiaServicio::create([
                'plan_dia_id' => $planDia->id,
                'servicio_id' => $servicio->id,
                'hora_inicio' => $this->getHoraInicioServicio($index),
                'hora_fin' => $this->getHoraFinServicio($index),
                'duracion_minutos' => $this->getDuracionServicio($servicio),
                'notas' => 'Servicio incluido en el plan',
                'orden' => $index + 1,
                'es_opcional' => false,
                'precio_adicional' => 0.00
            ]);
        }
    }
    
    private function createInscripciones($planes, $users)
    {
        $this->command->info('📝 Creando inscripciones a planes...');
        
        // Inscripción confirmada para el plan de 3 días
        PlanInscripcion::create([
            'plan_id' => $planes[0]->id,
            'user_id' => $users['turista']->id,
            'estado' => 'confirmada',
            'notas' => 'Primera visita a Capachica, muy emocionado.',
            'fecha_inscripcion' => now()->subDays(5),
            'fecha_inicio_plan' => now()->addDays(10),
            'fecha_fin_plan' => now()->addDays(13),
            'notas_usuario' => 'Soy vegetariano, necesito opciones sin carne.',
            'requerimientos_especiales' => 'Dieta vegetariana',
            'numero_participantes' => 2,
            'precio_pagado' => 700.00,
            'metodo_pago' => 'transferencia',
            'comentarios_adicionales' => 'Viaje de aniversario de bodas'
        ]);
        
        // Inscripción pendiente para el tour cultural
        PlanInscripcion::create([
            'plan_id' => $planes[1]->id,
            'user_id' => $users['turista']->id,
            'estado' => 'pendiente',
            'notas' => 'Interesado en conocer la cultura local.',
            'fecha_inscripcion' => now()->subDays(2),
            'fecha_inicio_plan' => now()->addDays(15),
            'fecha_fin_plan' => now()->addDays(15),
            'numero_participantes' => 1,
            'precio_pagado' => 0.00,
            'metodo_pago' => null,
            'comentarios_adicionales' => 'Esperando confirmación de disponibilidad'
        ]);
    }
    
    private function createReservas($servicios, $users)
    {
        $this->command->info('📅 Creando reservas...');
        
        // Reserva confirmada
        $reserva1 = Reserva::create([
            'usuario_id' => $users['turista']->id,
            'codigo_reserva' => Reserva::generarCodigoReserva(),
            'estado' => 'confirmada',
            'notas' => 'Reserva para fin de semana largo'
        ]);
        
        ReservaServicio::create([
            'reserva_id' => $reserva1->id,
            'servicio_id' => $servicios[0]->id, // Habitación Matrimonial
            'emprendedor_id' => $servicios[0]->emprendedor_id,
            'fecha_inicio' => now()->addDays(7),
            'fecha_fin' => now()->addDays(9),
            'hora_inicio' => '14:00:00',
            'hora_fin' => '12:00:00',
            'duracion_minutos' => 1320,
            'cantidad' => 1,
            'precio' => 80.00,
            'estado' => 'confirmado',
            'notas_cliente' => 'Habitación con vista al lago preferible'
        ]);
        
        // Reserva pendiente
        $reserva2 = Reserva::create([
            'usuario_id' => $users['turista']->id,
            'codigo_reserva' => Reserva::generarCodigoReserva(),
            'estado' => 'pendiente',
            'notas' => 'Reserva para actividades de aventura'
        ]);
        
        ReservaServicio::create([
            'reserva_id' => $reserva2->id,
            'servicio_id' => $servicios[6]->id, // Kayak al Amanecer
            'emprendedor_id' => $servicios[6]->emprendedor_id,
            'fecha_inicio' => now()->addDays(8),
            'fecha_fin' => null,
            'hora_inicio' => '05:00:00',
            'hora_fin' => '08:00:00',
            'duracion_minutos' => 180,
            'cantidad' => 2,
            'precio' => 120.00,
            'estado' => 'pendiente',
            'notas_cliente' => 'Somos principiantes en kayak'
        ]);
    }
    
    private function createEventos($emprendedores)
    {
        $this->command->info('🎉 Creando eventos...');
        
        Evento::create([
            'nombre' => 'Festival de la Trucha',
            'descripcion' => 'Festival gastronómico con platos tradicionales de trucha.',
            'tipo_evento' => 'Gastronómico',
            'idioma_principal' => 'Español',
            'fecha_inicio' => now()->addDays(20),
            'hora_inicio' => '10:00:00',
            'fecha_fin' => now()->addDays(20),
            'hora_fin' => '18:00:00',
            'duracion_horas' => 8,
            'coordenada_x' => -15.6420,
            'coordenada_y' => -69.8325,
            'id_emprendedor' => $emprendedores[1]->id,
            'que_llevar' => 'Ropa cómoda y apetito'
        ]);
        
        Evento::create([
            'nombre' => 'Exposición de Artesanía Andina',
            'descripcion' => 'Exposición y venta de artesanías tradicionales.',
            'tipo_evento' => 'Cultural',
            'idioma_principal' => 'Español',
            'fecha_inicio' => now()->addDays(30),
            'hora_inicio' => '09:00:00',
            'fecha_fin' => now()->addDays(30),
            'hora_fin' => '17:00:00',
            'duracion_horas' => 8,
            'coordenada_x' => -15.6415,
            'coordenada_y' => -69.8340,
            'id_emprendedor' => $emprendedores[2]->id,
            'que_llevar' => 'Dinero para compras'
        ]);
    }
    
    private function createSliders($municipalidad, $emprendedores)
    {
        $this->command->info('🖼️ Creando sliders...');
        
        // Sliders para municipalidad
        $slider1 = Slider::create([
            'url' => 'sliders/municipalidad-principal.jpg',
            'nombre' => 'Bienvenidos a Capachica',
            'es_principal' => true,
            'tipo_entidad' => 'municipalidad',
            'entidad_id' => $municipalidad->id,
            'orden' => 1,
            'activo' => true
        ]);
        
        SliderDescripcion::create([
            'slider_id' => $slider1->id,
            'titulo' => 'Paraíso Turístico del Lago Titicaca',
            'descripcion' => 'Descubre la belleza natural y cultural de Capachica'
        ]);
        
        // Sliders para emprendedores
        $slider2 = Slider::create([
            'url' => 'sliders/samary-hospedaje.jpg',
            'nombre' => 'Casa Hospedaje Samary',
            'es_principal' => true,
            'tipo_entidad' => 'emprendedor',
            'entidad_id' => $emprendedores[0]->id,
            'orden' => 1,
            'activo' => true
        ]);
        
        SliderDescripcion::create([
            'slider_id' => $slider2->id,
            'titulo' => 'Turismo Vivencial Auténtico',
            'descripcion' => 'Experimenta la vida tradicional en Llachón'
        ]);
    }
    
    private function associateUsersWithEmprendimientos($users, $emprendedores)
    {
        $this->command->info('🔗 Asociando usuarios con emprendimientos...');
        
        // Emprendedor 1 administra Casa Hospedaje Samary
        $users['emprendedor1']->emprendimientos()->attach($emprendedores[0]->id, [
            'es_principal' => true,
            'rol' => 'administrador'
        ]);
        
        // Emprendedor 2 administra Artesanías Titicaca
        $users['emprendedor2']->emprendimientos()->attach($emprendedores[2]->id, [
            'es_principal' => true,
            'rol' => 'administrador'
        ]);
        
        // Admin también puede administrar algunos emprendimientos
        $users['admin']->emprendimientos()->attach($emprendedores[1]->id, [
            'es_principal' => true,
            'rol' => 'administrador'
        ]);
    }
    
    // Métodos auxiliares para horarios
    private function getHorariosAlojamiento()
    {
        return [
            ['dia_semana' => 'lunes', 'hora_inicio' => '14:00:00', 'hora_fin' => '12:00:00', 'activo' => true],
            ['dia_semana' => 'martes', 'hora_inicio' => '14:00:00', 'hora_fin' => '12:00:00', 'activo' => true],
            ['dia_semana' => 'miercoles', 'hora_inicio' => '14:00:00', 'hora_fin' => '12:00:00', 'activo' => true],
            ['dia_semana' => 'jueves', 'hora_inicio' => '14:00:00', 'hora_fin' => '12:00:00', 'activo' => true],
            ['dia_semana' => 'viernes', 'hora_inicio' => '14:00:00', 'hora_fin' => '12:00:00', 'activo' => true],
            ['dia_semana' => 'sabado', 'hora_inicio' => '14:00:00', 'hora_fin' => '12:00:00', 'activo' => true],
            ['dia_semana' => 'domingo', 'hora_inicio' => '14:00:00', 'hora_fin' => '12:00:00', 'activo' => true]
        ];
    }
    
    private function getHorariosActividades()
    {
        return [
            ['dia_semana' => 'lunes', 'hora_inicio' => '09:00:00', 'hora_fin' => '16:00:00', 'activo' => true],
            ['dia_semana' => 'miercoles', 'hora_inicio' => '09:00:00', 'hora_fin' => '16:00:00', 'activo' => true],
            ['dia_semana' => 'viernes', 'hora_inicio' => '09:00:00', 'hora_fin' => '16:00:00', 'activo' => true]
        ];
    }
    
    private function getHorariosAlmuerzo()
    {
        return [
            ['dia_semana' => 'lunes', 'hora_inicio' => '12:00:00', 'hora_fin' => '15:00:00', 'activo' => true],
            ['dia_semana' => 'martes', 'hora_inicio' => '12:00:00', 'hora_fin' => '15:00:00', 'activo' => true],
            ['dia_semana' => 'miercoles', 'hora_inicio' => '12:00:00', 'hora_fin' => '15:00:00', 'activo' => true],
            ['dia_semana' => 'jueves', 'hora_inicio' => '12:00:00', 'hora_fin' => '15:00:00', 'activo' => true],
            ['dia_semana' => 'viernes', 'hora_inicio' => '12:00:00', 'hora_fin' => '15:00:00', 'activo' => true],
            ['dia_semana' => 'sabado', 'hora_inicio' => '12:00:00', 'hora_fin' => '15:00:00', 'activo' => true],
            ['dia_semana' => 'domingo', 'hora_inicio' => '12:00:00', 'hora_fin' => '15:00:00', 'activo' => true]
        ];
    }
    
    private function getHorariosArtesania()
    {
        return [
            ['dia_semana' => 'lunes', 'hora_inicio' => '09:00:00', 'hora_fin' => '18:00:00', 'activo' => true],
            ['dia_semana' => 'martes', 'hora_inicio' => '09:00:00', 'hora_fin' => '18:00:00', 'activo' => true],
            ['dia_semana' => 'miercoles', 'hora_inicio' => '09:00:00', 'hora_fin' => '18:00:00', 'activo' => true],
            ['dia_semana' => 'jueves', 'hora_inicio' => '09:00:00', 'hora_fin' => '18:00:00', 'activo' => true],
            ['dia_semana' => 'viernes', 'hora_inicio' => '09:00:00', 'hora_fin' => '18:00:00', 'activo' => true],
            ['dia_semana' => 'sabado', 'hora_inicio' => '09:00:00', 'hora_fin' => '18:00:00', 'activo' => true]
        ];
    }
    
    private function getHorariosTaller()
    {
        return [
            ['dia_semana' => 'martes', 'hora_inicio' => '10:00:00', 'hora_fin' => '12:00:00', 'activo' => true],
            ['dia_semana' => 'jueves', 'hora_inicio' => '10:00:00', 'hora_fin' => '12:00:00', 'activo' => true],
            ['dia_semana' => 'sabado', 'hora_inicio' => '14:00:00', 'hora_fin' => '16:00:00', 'activo' => true]
        ];
    }
    
    private function getHorariosTour()
    {
        return [
            ['dia_semana' => 'lunes', 'hora_inicio' => '08:00:00', 'hora_fin' => '14:00:00', 'activo' => true],
            ['dia_semana' => 'miercoles', 'hora_inicio' => '08:00:00', 'hora_fin' => '14:00:00', 'activo' => true],
            ['dia_semana' => 'viernes', 'hora_inicio' => '08:00:00', 'hora_fin' => '14:00:00', 'activo' => true],
            ['dia_semana' => 'domingo', 'hora_inicio' => '08:00:00', 'hora_fin' => '14:00:00', 'activo' => true]
        ];
    }
    
    private function getHorariosKayak()
    {
        return [
            ['dia_semana' => 'lunes', 'hora_inicio' => '05:00:00', 'hora_fin' => '08:00:00', 'activo' => true],
            ['dia_semana' => 'martes', 'hora_inicio' => '05:00:00', 'hora_fin' => '08:00:00', 'activo' => true],
            ['dia_semana' => 'miercoles', 'hora_inicio' => '05:00:00', 'hora_fin' => '08:00:00', 'activo' => true],
            ['dia_semana' => 'jueves', 'hora_inicio' => '05:00:00', 'hora_fin' => '08:00:00', 'activo' => true],
            ['dia_semana' => 'viernes', 'hora_inicio' => '05:00:00', 'hora_fin' => '08:00:00', 'activo' => true],
            ['dia_semana' => 'sabado', 'hora_inicio' => '05:00:00', 'hora_fin' => '08:00:00', 'activo' => true],
            ['dia_semana' => 'domingo', 'hora_inicio' => '05:00:00', 'hora_fin' => '08:00:00', 'activo' => true]
        ];
    }
    
    private function getHoraInicioServicio($index)
    {
        $horas = ['08:00:00', '10:00:00', '12:00:00', '14:00:00', '16:00:00'];
        return $horas[$index] ?? '08:00:00';
    }
    
    private function getHoraFinServicio($index)
    {
        $horas = ['10:00:00', '12:00:00', '14:00:00', '16:00:00', '18:00:00'];
        return $horas[$index] ?? '10:00:00';
    }
    
    private function getDuracionServicio($servicio)
    {
        // Duración en minutos basada en el tipo de servicio
        $duraciones = [
            'Habitación Matrimonial' => 1320, // 22 horas
            'Experiencia Cultural' => 420,    // 7 horas
            'Almuerzo Típico' => 180,         // 3 horas
            'Chullo Tradicional' => 60,       // 1 hora
            'Taller de Tejido' => 120,        // 2 horas
            'Tour a Isla Ticonata' => 360,    // 6 horas
            'Kayak al Amanecer' => 180        // 3 horas
        ];
        
        return $duraciones[$servicio->nombre] ?? 120;
    }
    
    private function showSummary()
    {
        $this->command->info('📊 RESUMEN DE DATOS CREADOS:');
        $this->command->info('👥 Usuarios: ' . User::count());
        $this->command->info('🏛️ Municipalidades: ' . Municipalidad::count());
        $this->command->info('🤝 Asociaciones: ' . Asociacion::count());
        $this->command->info('🏪 Emprendedores: ' . Emprendedor::count());
        $this->command->info('🛎️ Servicios: ' . Servicio::count());
        $this->command->info('🗺️ Planes: ' . Plan::count());
        $this->command->info('📝 Inscripciones: ' . PlanInscripcion::count());
        $this->command->info('📅 Reservas: ' . Reserva::count());
        $this->command->info('🎉 Eventos: ' . Evento::count());
        $this->command->info('🖼️ Sliders: ' . Slider::count());
        
        $this->command->info('');
        $this->command->info('🔑 CREDENCIALES DE PRUEBA:');
        $this->command->info('👑 Admin: admin@capachica.com / password');
        $this->command->info('👤 Turista: maria@turista.com / password');
        $this->command->info('🏪 Emprendedor 1: juan@llachon.com / password');
        $this->command->info('🏪 Emprendedor 2: rosa@artesania.com / password');
        $this->command->info('🔧 Moderador: moderador@capachica.com / password');
        
        $this->command->info('');
        $this->command->info('✨ ¡Sistema listo para probar todas las funcionalidades!');
    }
}
