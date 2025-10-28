<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Pago extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'pagos';

    // Estados posibles del pago
    const ESTADO_PENDIENTE = 'pendiente';
    const ESTADO_PROCESANDO = 'procesando';
    const ESTADO_EXITOSO = 'exitoso';
    const ESTADO_FALLIDO = 'fallido';
    const ESTADO_REEMBOLSADO = 'reembolsado';

    // Métodos de pago
    const METODO_CULQI = 'culqi';
    const METODO_YAPE = 'yape';
    const METODO_VISA = 'visa';
    const METODO_MASTERCARD = 'mastercard';
    const METODO_EFECTIVO = 'efectivo';

    protected $fillable = [
        'reserva_id',
        'usuario_id',
        'metodo_pago',
        'monto',
        'moneda',
        'culqi_charge_id',
        'culqi_order_id',
        'referencia_pago',
        'estado',
        'fecha_pago',
        'fecha_confirmacion',
        'num_cuotas',
        'notas_pago',
        'metadata',
        'respuesta_culqi',
        'email_usuario',
    ];

    protected $casts = [
        'monto' => 'decimal:2',
        'fecha_pago' => 'datetime',
        'fecha_confirmacion' => 'datetime',
        'metadata' => 'array',
        'respuesta_culqi' => 'array',
        'num_cuotas' => 'integer',
    ];

    protected $hidden = [
        'respuesta_culqi', // Ocultar respuesta completa de Culqi por seguridad
    ];

    /**
     * Relación con Reserva
     */
    public function reserva(): BelongsTo
    {
        return $this->belongsTo(Reserva::class);
    }

    /**
     * Relación con Usuario
     */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    /**
     * Scopes
     */
    public function scopeExitosos($query)
    {
        return $query->where('estado', self::ESTADO_EXITOSO);
    }

    public function scopePendientes($query)
    {
        return $query->where('estado', self::ESTADO_PENDIENTE);
    }

    public function scopeFallidos($query)
    {
        return $query->where('estado', self::ESTADO_FALLIDO);
    }

    public function scopePorMetodo($query, string $metodo)
    {
        return $query->where('metodo_pago', $metodo);
    }

    public function scopeEntreFechas($query, $desde, $hasta)
    {
        return $query->whereBetween('fecha_pago', [$desde, $hasta]);
    }

    /**
     * Métodos auxiliares
     */
    public function esExitoso(): bool
    {
        return $this->estado === self::ESTADO_EXITOSO;
    }

    public function esPendiente(): bool
    {
        return $this->estado === self::ESTADO_PENDIENTE;
    }

    public function esFallido(): bool
    {
        return $this->estado === self::ESTADO_FALLIDO;
    }

    public function marcarComoExitoso(): bool
    {
        return $this->update([
            'estado' => self::ESTADO_EXITOSO,
            'fecha_confirmacion' => now()
        ]);
    }

    public function marcarComoFallido(string $razon = null): bool
    {
        $notas = $this->notas_pago ?? '';
        if ($razon) {
            $notas .= "\nFallo: {$razon} - " . now()->format('Y-m-d H:i:s');
        }

        return $this->update([
            'estado' => self::ESTADO_FALLIDO,
            'notas_pago' => $notas
        ]);
    }
}
