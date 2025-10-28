<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pagos', function (Blueprint $table) {
            $table->id();
            
            // Relación con la reserva
            $table->foreignId('reserva_id')
                  ->constrained('reservas')
                  ->onDelete('cascade');
            
            // Información del pago
            $table->string('metodo_pago')->default('culqi'); // culqi, yape, visa, mastercard, efectivo
            $table->decimal('monto', 10, 2);
            $table->string('moneda', 3)->default('PEN'); // PEN, USD
            
            // Información de Culqi
            $table->string('culqi_charge_id')->nullable()->unique(); // ID del cargo en Culqi
            $table->string('culqi_order_id')->nullable(); // ID de la orden en Culqi
            $table->string('referencia_pago')->nullable(); // Referencia interna o código de transacción
            
            // Estado del pago
            $table->enum('estado', ['pendiente', 'procesando', 'exitoso', 'fallido', 'reembolsado'])
                  ->default('pendiente');
            
            // Fechas
            $table->timestamp('fecha_pago')->nullable(); // Cuándo se procesó el pago
            $table->timestamp('fecha_confirmacion')->nullable(); // Cuándo se confirmó
            
            // Información adicional
            $table->integer('num_cuotas')->nullable(); // Número de cuotas (si aplica)
            $table->text('notas_pago')->nullable(); // Notas adicionales
            $table->json('metadata')->nullable(); // Información adicional en JSON
            $table->json('respuesta_culqi')->nullable(); // Respuesta completa de Culqi para debugging
            
            // Información del usuario (duplicado por seguridad)
            $table->foreignId('usuario_id')
                  ->constrained('users')
                  ->onDelete('cascade');
            $table->string('email_usuario'); // Email usado en el pago
            
            $table->timestamps();
            $table->softDeletes(); // Para mantener historial de pagos eliminados
            
            // Índices para búsquedas rápidas
            $table->index('estado');
            $table->index('fecha_pago');
            $table->index(['reserva_id', 'estado']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pagos');
    }
};
