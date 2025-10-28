<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Reserva;
use App\Models\ReservaServicio;
use App\Models\Servicio;
use App\Models\Emprendedor;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ReservasPruebaSeeder extends Seeder
{
    /**
     * Seed the application's database con datos de prueba para reservas.
     */
    public function run(): void
    {
        // Buscar usuarios existentes o crear uno de prueba
        $usuarioPrueba = User::where('email', 'user@example.com')->first();
        
        if (!$usuarioPrueba) {
            $usuarioPrueba = User::create([
                'name' => 'Usuario Prueba',
                'email' => 'user@example.com',
                'password' => bcrypt('password'),
                'email_verified_at' => now(),
                'phone' => '987654321',
                'country' => 'Perú',
                'active' => true,
            ]);
        }

        // Buscar servicios existentes
        $servicios = Servicio::with('emprendedor')->take(6)->get();
        
        if ($servicios->isEmpty()) {
            $this->command->error('No hay servicios disponibles. Por favor ejecuta primero DatabaseSeeder.');
            return;
        }

        // Limpiar reservas de prueba anteriores si existen
        DB::table('reserva_servicios')->whereIn('reserva_id', function($query) use ($usuarioPrueba) {
            $query->select('id')
                  ->from('reservas')
                  ->where('usuario_id', $usuarioPrueba->id);
        })->delete();
        
        DB::table('reservas')->where('usuario_id', $usuarioPrueba->id)->delete();

        $this->command->info('Creando reservas de prueba...');

        // ===== RESERVA 1: PENDIENTE (Para probar PAGO) =====
        $reserva1 = Reserva::create([
            'usuario_id' => $usuarioPrueba->id,
            'codigo_reserva' => Reserva::generarCodigoReserva(),
            'estado' => Reserva::ESTADO_PENDIENTE,
            'notas' => 'Esta es una reserva pendiente para probar la funcionalidad de pago.',
            'created_at' => now()->subDays(2),
            'updated_at' => now()->subDays(2)
        ]);

        // Agregar servicios a la reserva 1
        $servicios->each(function($servicio, $index) use ($reserva1) {
            if ($index < 2) {
                ReservaServicio::create([
                    'reserva_id' => $reserva1->id,
                    'servicio_id' => $servicio->id,
                    'emprendedor_id' => $servicio->emprendedor_id,
                    'fecha_inicio' => now()->addDays(5)->format('Y-m-d'),
                    'fecha_fin' => now()->addDays(7)->format('Y-m-d'),
                    'hora_inicio' => '08:00:00',
                    'hora_fin' => '17:00:00',
                    'duracion_minutos' => 540,
                    'cantidad' => $index + 1,
                    'precio' => $servicio->precio_referencial,
                    'estado' => ReservaServicio::ESTADO_PENDIENTE,
                    'notas_cliente' => 'Nota de prueba para servicio ' . ($index + 1),
                    'created_at' => now()->subDays(2),
                    'updated_at' => now()->subDays(2)
                ]);
            }
        });

        $this->command->info("✓ Reserva 1 (PENDIENTE) creada con código: {$reserva1->codigo_reserva}");

        // ===== RESERVA 2: CONFIRMADA (Para probar IMPRESIÓN) =====
        $reserva2 = Reserva::create([
            'usuario_id' => $usuarioPrueba->id,
            'codigo_reserva' => Reserva::generarCodigoReserva(),
            'estado' => Reserva::ESTADO_CONFIRMADA,
            'notas' => 'Esta es una reserva confirmada para probar la funcionalidad de impresión de PDF.',
            'created_at' => now()->subDays(5),
            'updated_at' => now()->subDays(3)
        ]);

        // Agregar servicios a la reserva 2
        $servicios->skip(2)->take(2)->each(function($servicio, $index) use ($reserva2) {
            ReservaServicio::create([
                'reserva_id' => $reserva2->id,
                'servicio_id' => $servicio->id,
                'emprendedor_id' => $servicio->emprendedor_id,
                'fecha_inicio' => now()->addDays(10)->format('Y-m-d'),
                'fecha_fin' => now()->addDays(12)->format('Y-m-d'),
                'hora_inicio' => '10:00:00',
                'hora_fin' => '16:00:00',
                'duracion_minutos' => 360,
                'cantidad' => $index + 1,
                'precio' => $servicio->precio_referencial,
                'estado' => ReservaServicio::ESTADO_CONFIRMADO,
                'notas_cliente' => 'Servicio confirmado y listo para usar',
                'created_at' => now()->subDays(5),
                'updated_at' => now()->subDays(3)
            ]);
        });

        $this->command->info("✓ Reserva 2 (CONFIRMADA) creada con código: {$reserva2->codigo_reserva}");

        // ===== RESERVA 3: PENDIENTE CON MÚLTIPLES SERVICIOS (Para probar COMPRAS COMPLETAS) =====
        $reserva3 = Reserva::create([
            'usuario_id' => $usuarioPrueba->id,
            'codigo_reserva' => Reserva::generarCodigoReserva(),
            'estado' => Reserva::ESTADO_PENDIENTE,
            'notas' => 'Reserva con múltiples servicios para probar el total de compra.',
            'created_at' => now()->subDays(1),
            'updated_at' => now()->subDays(1)
        ]);

        // Agregar múltiples servicios a la reserva 3
        $servicios->take(3)->each(function($servicio, $index) use ($reserva3) {
            ReservaServicio::create([
                'reserva_id' => $reserva3->id,
                'servicio_id' => $servicio->id,
                'emprendedor_id' => $servicio->emprendedor_id,
                'fecha_inicio' => now()->addDays(15 + $index)->format('Y-m-d'),
                'fecha_fin' => now()->addDays(17 + $index)->format('Y-m-d'),
                'hora_inicio' => '09:00:00',
                'hora_fin' => '18:00:00',
                'duracion_minutos' => 540,
                'cantidad' => rand(1, 3),
                'precio' => $servicio->precio_referencial,
                'estado' => ReservaServicio::ESTADO_PENDIENTE,
                'notas_cliente' => 'Servicio de prueba número ' . ($index + 1),
                'created_at' => now()->subDays(1),
                'updated_at' => now()->subDays(1)
            ]);
        });

        $this->command->info("✓ Reserva 3 (PENDIENTE - Múltiples servicios) creada con código: {$reserva3->codigo_reserva}");

        // ===== RESERVA 4: COMPLETADA (Para mostrar historial) =====
        $reserva4 = Reserva::create([
            'usuario_id' => $usuarioPrueba->id,
            'codigo_reserva' => Reserva::generarCodigoReserva(),
            'estado' => Reserva::ESTADO_COMPLETADA,
            'notas' => 'Reserva completada para mostrar en el historial.',
            'created_at' => now()->subDays(15),
            'updated_at' => now()->subDays(10)
        ]);

        // Agregar servicios a la reserva 4
        $servicios->skip(1)->take(1)->each(function($servicio) use ($reserva4) {
            ReservaServicio::create([
                'reserva_id' => $reserva4->id,
                'servicio_id' => $servicio->id,
                'emprendedor_id' => $servicio->emprendedor_id,
                'fecha_inicio' => now()->subDays(20)->format('Y-m-d'),
                'fecha_fin' => now()->subDays(18)->format('Y-m-d'),
                'hora_inicio' => '14:00:00',
                'hora_fin' => '16:00:00',
                'duracion_minutos' => 120,
                'cantidad' => 1,
                'precio' => $servicio->precio_referencial,
                'estado' => ReservaServicio::ESTADO_COMPLETADO,
                'notas_cliente' => 'Experiencia excelente, totalmente recomendada',
                'created_at' => now()->subDays(15),
                'updated_at' => now()->subDays(10)
            ]);
        });

        $this->command->info("✓ Reserva 4 (COMPLETADA) creada con código: {$reserva4->codigo_reserva}");

        $this->command->info('');
        $this->command->info('========================================');
        $this->command->info('Reservas de prueba creadas exitosamente!');
        $this->command->info('========================================');
        $this->command->info('');
        $this->command->info('Credenciales para login:');
        $this->command->info('  Email: user@example.com');
        $this->command->info('  Password: password');
        $this->command->info('');
        $this->command->info('Reservas creadas:');
        $this->command->info('  1. PENDIENTE - Lista para probar PAGO');
        $this->command->info('  2. CONFIRMADA - Lista para probar IMPRESIÓN');
        $this->command->info('  3. PENDIENTE (múltiples servicios) - Para probar totales');
        $this->command->info('  4. COMPLETADA - Para ver en historial');
        $this->command->info('');
    }
}
