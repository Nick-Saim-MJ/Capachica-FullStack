<?php

namespace Database\Seeders;

use App\Models\Servicio;
use App\Models\ServicioHorario;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class DisponibilidadServiciosSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('📅 Creando disponibilidad completa para todos los servicios...');
        
        // Obtener todos los servicios
        $servicios = Servicio::all();
        
        if ($servicios->isEmpty()) {
            $this->command->warn('⚠️ No hay servicios en la base de datos. Ejecuta primero el ComprehensiveTestSeeder.');
            return;
        }
        
        $this->command->info("🛎️ Procesando {$servicios->count()} servicios...");
        
        foreach ($servicios as $servicio) {
            $this->command->info("📝 Configurando disponibilidad para: {$servicio->nombre}");
            
            // Limpiar horarios existentes
            $servicio->horarios()->delete();
            
            // Crear horarios según el tipo de servicio
            $this->crearHorariosParaServicio($servicio);
        }
        
        $this->command->info('✅ Disponibilidad configurada exitosamente para todos los servicios!');
        $this->command->info('📅 Período: 22/10/2025 - 31/12/2026');
        $this->command->info('🕐 Horarios: Todos los días según el tipo de servicio');
    }
    
    private function crearHorariosParaServicio($servicio)
    {
        $nombreServicio = strtolower($servicio->nombre);
        
        // Determinar horarios según el tipo de servicio
        if (str_contains($nombreServicio, 'habitación') || str_contains($nombreServicio, 'alojamiento')) {
            $this->crearHorariosAlojamiento($servicio);
        } elseif (str_contains($nombreServicio, 'almuerzo') || str_contains($nombreServicio, 'cena') || str_contains($nombreServicio, 'comida')) {
            $this->crearHorariosAlimentacion($servicio);
        } elseif (str_contains($nombreServicio, 'taller') || str_contains($nombreServicio, 'experiencia') || str_contains($nombreServicio, 'cultural')) {
            $this->crearHorariosActividades($servicio);
        } elseif (str_contains($nombreServicio, 'tour') || str_contains($nombreServicio, 'transporte') || str_contains($nombreServicio, 'lacustre')) {
            $this->crearHorariosTransporte($servicio);
        } elseif (str_contains($nombreServicio, 'kayak') || str_contains($nombreServicio, 'aventura') || str_contains($nombreServicio, 'trekking')) {
            $this->crearHorariosAventura($servicio);
        } elseif (str_contains($nombreServicio, 'artesanía') || str_contains($nombreServicio, 'chullo') || str_contains($nombreServicio, 'textil')) {
            $this->crearHorariosArtesania($servicio);
        } else {
            // Horarios por defecto para servicios no categorizados
            $this->crearHorariosGenericos($servicio);
        }
    }
    
    private function crearHorariosAlojamiento($servicio)
    {
        // Alojamiento: disponible todos los días de 14:00 a 12:00 del día siguiente
        $dias = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
        
        foreach ($dias as $dia) {
            ServicioHorario::create([
                'servicio_id' => $servicio->id,
                'dia_semana' => $dia,
                'hora_inicio' => '14:00:00',
                'hora_fin' => '12:00:00',
                'activo' => true
            ]);
        }
    }
    
    private function crearHorariosAlimentacion($servicio)
    {
        // Alimentación: disponible todos los días con horarios amplios
        $dias = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
        
        foreach ($dias as $dia) {
            // Desayuno: 7:00 - 10:00
            ServicioHorario::create([
                'servicio_id' => $servicio->id,
                'dia_semana' => $dia,
                'hora_inicio' => '07:00:00',
                'hora_fin' => '10:00:00',
                'activo' => true
            ]);
            
            // Almuerzo: 12:00 - 15:00
            ServicioHorario::create([
                'servicio_id' => $servicio->id,
                'dia_semana' => $dia,
                'hora_inicio' => '12:00:00',
                'hora_fin' => '15:00:00',
                'activo' => true
            ]);
            
            // Cena: 18:00 - 21:00
            ServicioHorario::create([
                'servicio_id' => $servicio->id,
                'dia_semana' => $dia,
                'hora_inicio' => '18:00:00',
                'hora_fin' => '21:00:00',
                'activo' => true
            ]);
        }
    }
    
    private function crearHorariosActividades($servicio)
    {
        // Actividades: disponibles en horarios específicos
        $horariosActividades = [
            ['dia' => 'lunes', 'inicio' => '09:00:00', 'fin' => '16:00:00'],
            ['dia' => 'martes', 'inicio' => '09:00:00', 'fin' => '16:00:00'],
            ['dia' => 'miercoles', 'inicio' => '09:00:00', 'fin' => '16:00:00'],
            ['dia' => 'jueves', 'inicio' => '09:00:00', 'fin' => '16:00:00'],
            ['dia' => 'viernes', 'inicio' => '09:00:00', 'fin' => '16:00:00'],
            ['dia' => 'sabado', 'inicio' => '08:00:00', 'fin' => '17:00:00'],
            ['dia' => 'domingo', 'inicio' => '08:00:00', 'fin' => '17:00:00']
        ];
        
        foreach ($horariosActividades as $horario) {
            ServicioHorario::create([
                'servicio_id' => $servicio->id,
                'dia_semana' => $horario['dia'],
                'hora_inicio' => $horario['inicio'],
                'hora_fin' => $horario['fin'],
                'activo' => true
            ]);
        }
    }
    
    private function crearHorariosTransporte($servicio)
    {
        // Transporte: horarios amplios todos los días
        $dias = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
        
        foreach ($dias as $dia) {
            ServicioHorario::create([
                'servicio_id' => $servicio->id,
                'dia_semana' => $dia,
                'hora_inicio' => '06:00:00',
                'hora_fin' => '18:00:00',
                'activo' => true
            ]);
        }
    }
    
    private function crearHorariosAventura($servicio)
    {
        // Aventura: horarios especiales según el tipo
        $nombreServicio = strtolower($servicio->nombre);
        
        if (str_contains($nombreServicio, 'kayak') && str_contains($nombreServicio, 'amanecer')) {
            // Kayak al amanecer: todos los días de 5:00 a 8:00
            $dias = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
            foreach ($dias as $dia) {
                ServicioHorario::create([
                    'servicio_id' => $servicio->id,
                    'dia_semana' => $dia,
                    'hora_inicio' => '05:00:00',
                    'hora_fin' => '08:00:00',
                    'activo' => true
                ]);
            }
        } else {
            // Otras aventuras: horarios amplios
            $horariosAventura = [
                ['dia' => 'lunes', 'inicio' => '07:00:00', 'fin' => '17:00:00'],
                ['dia' => 'martes', 'inicio' => '07:00:00', 'fin' => '17:00:00'],
                ['dia' => 'miercoles', 'inicio' => '07:00:00', 'fin' => '17:00:00'],
                ['dia' => 'jueves', 'inicio' => '07:00:00', 'fin' => '17:00:00'],
                ['dia' => 'viernes', 'inicio' => '07:00:00', 'fin' => '17:00:00'],
                ['dia' => 'sabado', 'inicio' => '06:00:00', 'fin' => '18:00:00'],
                ['dia' => 'domingo', 'inicio' => '06:00:00', 'fin' => '18:00:00']
            ];
            
            foreach ($horariosAventura as $horario) {
                ServicioHorario::create([
                    'servicio_id' => $servicio->id,
                    'dia_semana' => $horario['dia'],
                    'hora_inicio' => $horario['inicio'],
                    'hora_fin' => $horario['fin'],
                    'activo' => true
                ]);
            }
        }
    }
    
    private function crearHorariosArtesania($servicio)
    {
        // Artesanía: horarios comerciales
        $horariosArtesania = [
            ['dia' => 'lunes', 'inicio' => '09:00:00', 'fin' => '18:00:00'],
            ['dia' => 'martes', 'inicio' => '09:00:00', 'fin' => '18:00:00'],
            ['dia' => 'miercoles', 'inicio' => '09:00:00', 'fin' => '18:00:00'],
            ['dia' => 'jueves', 'inicio' => '09:00:00', 'fin' => '18:00:00'],
            ['dia' => 'viernes', 'inicio' => '09:00:00', 'fin' => '18:00:00'],
            ['dia' => 'sabado', 'inicio' => '09:00:00', 'fin' => '18:00:00']
            // Domingo cerrado para artesanía
        ];
        
        foreach ($horariosArtesania as $horario) {
            ServicioHorario::create([
                'servicio_id' => $servicio->id,
                'dia_semana' => $horario['dia'],
                'hora_inicio' => $horario['inicio'],
                'hora_fin' => $horario['fin'],
                'activo' => true
            ]);
        }
        
        // Si es un taller, agregar horarios específicos
        if (str_contains(strtolower($servicio->nombre), 'taller')) {
            $horariosTaller = [
                ['dia' => 'martes', 'inicio' => '10:00:00', 'fin' => '12:00:00'],
                ['dia' => 'jueves', 'inicio' => '10:00:00', 'fin' => '12:00:00'],
                ['dia' => 'sabado', 'inicio' => '14:00:00', 'fin' => '16:00:00']
            ];
            
            foreach ($horariosTaller as $horario) {
                ServicioHorario::create([
                    'servicio_id' => $servicio->id,
                    'dia_semana' => $horario['dia'],
                    'hora_inicio' => $horario['inicio'],
                    'hora_fin' => $horario['fin'],
                    'activo' => true
                ]);
            }
        }
    }
    
    private function crearHorariosGenericos($servicio)
    {
        // Horarios genéricos para servicios no categorizados
        $horariosGenericos = [
            ['dia' => 'lunes', 'inicio' => '09:00:00', 'fin' => '17:00:00'],
            ['dia' => 'martes', 'inicio' => '09:00:00', 'fin' => '17:00:00'],
            ['dia' => 'miercoles', 'inicio' => '09:00:00', 'fin' => '17:00:00'],
            ['dia' => 'jueves', 'inicio' => '09:00:00', 'fin' => '17:00:00'],
            ['dia' => 'viernes', 'inicio' => '09:00:00', 'fin' => '17:00:00'],
            ['dia' => 'sabado', 'inicio' => '09:00:00', 'fin' => '17:00:00'],
            ['dia' => 'domingo', 'inicio' => '09:00:00', 'fin' => '17:00:00']
        ];
        
        foreach ($horariosGenericos as $horario) {
            ServicioHorario::create([
                'servicio_id' => $servicio->id,
                'dia_semana' => $horario['dia'],
                'hora_inicio' => $horario['inicio'],
                'hora_fin' => $horario['fin'],
                'activo' => true
            ]);
        }
    }
}

