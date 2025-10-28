<?php

namespace App\Http\Controllers\API\Payment;

use App\Http\Controllers\Controller;
use App\Services\CulqiService;
use App\Models\Reserva;
use App\Models\ReservaServicio;
use App\Models\Pago;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

class CulqiController extends Controller
{
    protected $culqiService;

    public function __construct(CulqiService $culqiService)
    {
        $this->culqiService = $culqiService;
    }

    /**
     * @OA\Post(
     *     path="/api/pagos/culqi/procesar",
     *     summary="Procesar pago con Culqi",
     *     tags={"Pagos"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"reserva_id", "token", "email"},
     *             @OA\Property(property="reserva_id", type="integer", example=10),
     *             @OA\Property(property="token", type="string", example="tkn_test_xxxxxxxxxxxxx", description="Token generado por Culqi.js"),
     *             @OA\Property(property="email", type="string", example="cliente@email.com"),
     *             @OA\Property(property="installments", type="integer", example=0, description="Número de cuotas (0 = sin cuotas)")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Pago procesado exitosamente"
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Error de validación"
     *     )
     * )
     */
    public function procesarPago(Request $request): JsonResponse
    {
        try {
            // Validar request
            $validator = Validator::make($request->all(), [
                'reserva_id' => 'required|integer|exists:reservas,id',
                'token' => 'required|string', // Token generado por Culqi.js en el frontend
                'email' => 'required|email',
                'installments' => 'nullable|integer|min:0|max:36',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'errors' => $validator->errors()
                ], Response::HTTP_UNPROCESSABLE_ENTITY);
            }

            // Obtener la reserva
            $reserva = Reserva::with(['usuario', 'servicios'])->find($request->reserva_id);

            // Verificar permisos
            if (!Auth::user()->hasRole('admin') && $reserva->usuario_id !== Auth::id()) {
                return response()->json([
                    'success' => false,
                    'message' => 'No tienes permiso para pagar esta reserva'
                ], Response::HTTP_FORBIDDEN);
            }

            // Verificar estado de la reserva
            if ($reserva->estado === Reserva::ESTADO_EN_CARRITO) {
                return response()->json([
                    'success' => false,
                    'message' => 'No se puede pagar una reserva en carrito'
                ], Response::HTTP_BAD_REQUEST);
            }

            if ($reserva->estado === Reserva::ESTADO_CONFIRMADA || $reserva->estado === Reserva::ESTADO_COMPLETADA) {
                return response()->json([
                    'success' => false,
                    'message' => 'Esta reserva ya ha sido pagada'
                ], Response::HTTP_BAD_REQUEST);
            }

            // Calcular monto total
            $montoTotal = $reserva->servicios->sum(function($servicio) {
                return $servicio->precio * $servicio->cantidad;
            });

            if ($montoTotal <= 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'El monto de la reserva debe ser mayor a 0'
                ], Response::HTTP_BAD_REQUEST);
            }

            // Convertir a céntimos (Culqi requiere el monto en céntimos)
            $montoCentimos = CulqiService::amountToCents($montoTotal);

            // Procesar el cargo en Culqi
            $chargeData = [
                'token' => $request->token,
                'amount' => $montoCentimos,
                'email' => $request->email,
                'description' => "Reserva #{$reserva->id} - {$reserva->codigo_reserva}",
                'order_id' => $reserva->codigo_reserva,
                'customer_name' => $reserva->usuario->name ?? 'Cliente',
                'reservation_code' => $reserva->codigo_reserva,
            ];

            // Si hay cuotas, agregarlas
            if ($request->has('installments') && $request->installments > 0) {
                $chargeData['installments'] = $request->installments;
            }

            // Crear el cargo
            $resultado = $this->culqiService->createCharge($chargeData);

            if (!$resultado['success']) {
                return response()->json([
                    'success' => false,
                    'message' => 'Error al procesar el pago',
                    'error' => $resultado['error'] ?? 'Error desconocido',
                    'error_code' => $resultado['error_code'] ?? null
                ], Response::HTTP_PAYMENT_REQUIRED);
            }

            // Actualizar la reserva
            DB::beginTransaction();

            try {
                // Crear registro de pago
                $pago = Pago::create([
                    'reserva_id' => $reserva->id,
                    'usuario_id' => Auth::id(),
                    'metodo_pago' => Pago::METODO_CULQI,
                    'monto' => $montoTotal,
                    'moneda' => $resultado['currency'],
                    'culqi_charge_id' => $resultado['charge_id'],
                    'referencia_pago' => $resultado['reference'] ?? null,
                    'estado' => Pago::ESTADO_EXITOSO,
                    'fecha_pago' => now(),
                    'fecha_confirmacion' => now(),
                    'num_cuotas' => $request->installments ?? 0,
                    'email_usuario' => $request->email,
                    'metadata' => [
                        'codigo_reserva' => $reserva->codigo_reserva,
                        'num_servicios' => $reserva->servicios->count(),
                    ],
                    'respuesta_culqi' => $resultado['raw_response'] ?? null,
                ]);

                // Actualizar la reserva
                $reserva->update([
                    'estado' => Reserva::ESTADO_CONFIRMADA,
                    'notas' => ($reserva->notas ?? '') . "\n\n" .
                              "✅ Pago procesado exitosamente con Culqi\n" .
                              "Fecha: " . now()->format('d/m/Y H:i:s') . "\n" .
                              "ID de cargo: {$resultado['charge_id']}\n" .
                              "ID de pago: {$pago->id}\n" .
                              "Monto: S/. " . number_format($montoTotal, 2) . "\n" .
                              "Método: Culqi (Tarjeta/Yape)\n" .
                              ($resultado['reference'] ? "Referencia: {$resultado['reference']}\n" : '')
                ]);

                // Actualizar servicios
                $reserva->servicios()->update(['estado' => ReservaServicio::ESTADO_CONFIRMADO]);

                DB::commit();

                Log::info('Pago Culqi procesado exitosamente', [
                    'reserva_id' => $reserva->id,
                    'pago_id' => $pago->id,
                    'charge_id' => $resultado['charge_id'],
                    'amount' => $montoTotal
                ]);

                return response()->json([
                    'success' => true,
                    'message' => '¡Pago procesado exitosamente!',
                    'data' => [
                        'reserva' => $reserva->fresh(['usuario', 'servicios']),
                        'pago' => [
                            'id' => $pago->id,
                            'charge_id' => $resultado['charge_id'],
                            'monto' => $montoTotal,
                            'moneda' => $resultado['currency'],
                            'estado' => $resultado['status'],
                            'referencia' => $resultado['reference'] ?? null,
                            'fecha' => now()->toISOString()
                        ]
                    ]
                ], Response::HTTP_OK);

            } catch (\Exception $e) {
                DB::rollBack();
                
                Log::error('Error al actualizar reserva después del pago', [
                    'reserva_id' => $reserva->id,
                    'charge_id' => $resultado['charge_id'],
                    'error' => $e->getMessage()
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'El pago se procesó pero hubo un error al actualizar la reserva. Contacta a soporte.',
                    'charge_id' => $resultado['charge_id']
                ], Response::HTTP_INTERNAL_SERVER_ERROR);
            }

        } catch (\Exception $e) {
            Log::error('Error general en procesamiento de pago Culqi', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error al procesar el pago',
                'error' => config('app.debug') ? $e->getMessage() : 'Error interno del servidor'
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * @OA\Post(
     *     path="/api/pagos/culqi/webhook",
     *     summary="Webhook de Culqi para notificaciones",
     *     tags={"Pagos"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent()
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Webhook procesado"
     *     )
     * )
     */
    public function webhook(Request $request): JsonResponse
    {
        try {
            // Obtener el payload
            $payload = $request->all();
            
            Log::info('Webhook Culqi recibido', ['payload' => $payload]);

            // Verificar el tipo de evento
            $eventType = $payload['object'] ?? null;

            if ($eventType === 'event') {
                $eventData = $payload['data'] ?? [];
                $eventId = $eventData['id'] ?? null;
                $chargeId = $eventData['charge_id'] ?? null;

                // Consultar el cargo en Culqi
                if ($chargeId) {
                    $chargeResult = $this->culqiService->getCharge($chargeId);
                    
                    if ($chargeResult['success']) {
                        $charge = $chargeResult['charge'];
                        
                        // Buscar la reserva por el código
                        $orderNumber = $charge->metadata->order_id ?? null;
                        
                        if ($orderNumber) {
                            $reserva = Reserva::where('codigo_reserva', $orderNumber)->first();
                            
                            if ($reserva) {
                                // Actualizar según el estado del cargo
                                if ($charge->outcome->type === 'venta_exitosa') {
                                    $reserva->update(['estado' => Reserva::ESTADO_CONFIRMADA]);
                                    Log::info('Reserva confirmada por webhook', ['reserva_id' => $reserva->id]);
                                }
                            }
                        }
                    }
                }
            }

            return response()->json(['success' => true], Response::HTTP_OK);

        } catch (\Exception $e) {
            Log::error('Error procesando webhook de Culqi', [
                'error' => $e->getMessage(),
                'payload' => $request->all()
            ]);

            return response()->json(['success' => false], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * @OA\Get(
     *     path="/api/pagos/culqi/config",
     *     summary="Obtener configuración pública de Culqi",
     *     tags={"Pagos"},
     *     @OA\Response(
     *         response=200,
     *         description="Configuración pública"
     *     )
     * )
     */
    public function getConfig(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'public_key' => config('culqi.public_key'),
                'currency' => config('culqi.currency'),
                'environment' => config('culqi.environment'),
            ]
        ], Response::HTTP_OK);
    }
}
