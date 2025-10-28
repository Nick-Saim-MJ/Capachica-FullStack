<?php

namespace App\Services;

use Culqi\Culqi;
use Exception;
use Illuminate\Support\Facades\Log;

class CulqiService
{
    protected $culqi;

    public function __construct()
    {
        $this->culqi = new Culqi([
            'api_key' => config('culqi.secret_key')
        ]);
    }

    /**
     * Crear un cargo (charge) en Culqi
     * 
     * @param array $data [
     *   'token' => 'token_id', // Token generado desde el frontend
     *   'amount' => 10000, // Monto en céntimos (100.00 soles = 10000)
     *   'email' => 'cliente@email.com',
     *   'description' => 'Reserva turística',
     *   'order_id' => 'ORD-001' // ID único de tu orden
     * ]
     * @return array
     * @throws Exception
     */
    public function createCharge(array $data): array
    {
        try {
            // Validar datos requeridos
            $this->validateChargeData($data);

            // Crear el cargo
            $charge = $this->culqi->Charges->create([
                'amount' => $data['amount'], // Monto en céntimos
                'currency_code' => config('culqi.currency', 'PEN'),
                'email' => $data['email'],
                'source_id' => $data['token'], // Token de tarjeta o Yape
                'description' => $data['description'] ?? 'Pago de reserva',
                'metadata' => [
                    'order_id' => $data['order_id'],
                    'customer_name' => $data['customer_name'] ?? null,
                    'reservation_code' => $data['reservation_code'] ?? null,
                ]
            ]);

            Log::info('Culqi charge created successfully', [
                'charge_id' => $charge->id,
                'order_id' => $data['order_id']
            ]);

            return [
                'success' => true,
                'charge_id' => $charge->id,
                'amount' => $charge->amount / 100, // Convertir de céntimos a soles
                'currency' => $charge->currency_code,
                'status' => $charge->outcome->type ?? 'success',
                'reference' => $charge->reference_code ?? null,
                'raw_response' => $charge
            ];

        } catch (Exception $e) {
            Log::error('Error creating Culqi charge', [
                'error' => $e->getMessage(),
                'order_id' => $data['order_id'] ?? null
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'error_code' => $e->getCode()
            ];
        }
    }

    /**
     * Crear un cargo con Yape
     * 
     * @param array $data
     * @return array
     * @throws Exception
     */
    public function createYapeCharge(array $data): array
    {
        try {
            $this->validateChargeData($data);

            $charge = $this->culqi->Charges->create([
                'amount' => $data['amount'],
                'currency_code' => 'PEN',
                'email' => $data['email'],
                'source_id' => $data['token'],
                'description' => $data['description'] ?? 'Pago con Yape',
                'metadata' => [
                    'order_id' => $data['order_id'],
                    'payment_method' => 'yape',
                    'reservation_code' => $data['reservation_code'] ?? null,
                ]
            ]);

            return [
                'success' => true,
                'charge_id' => $charge->id,
                'amount' => $charge->amount / 100,
                'status' => 'success',
                'raw_response' => $charge
            ];

        } catch (Exception $e) {
            Log::error('Error creating Yape charge', [
                'error' => $e->getMessage(),
                'order_id' => $data['order_id'] ?? null
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Consultar el estado de un cargo
     * 
     * @param string $chargeId
     * @return array
     */
    public function getCharge(string $chargeId): array
    {
        try {
            $charge = $this->culqi->Charges->get($chargeId);

            return [
                'success' => true,
                'charge' => $charge
            ];

        } catch (Exception $e) {
            Log::error('Error getting charge from Culqi', [
                'charge_id' => $chargeId,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Crear una orden (para mantener trazabilidad)
     * 
     * @param array $data
     * @return array
     */
    public function createOrder(array $data): array
    {
        try {
            $order = $this->culqi->Orders->create([
                'amount' => $data['amount'],
                'currency_code' => config('culqi.currency', 'PEN'),
                'description' => $data['description'] ?? 'Orden de reserva',
                'order_number' => $data['order_number'],
                'client_details' => [
                    'first_name' => $data['client']['first_name'],
                    'last_name' => $data['client']['last_name'],
                    'email' => $data['client']['email'],
                    'phone_number' => $data['client']['phone'] ?? null,
                ],
                'expiration_date' => $data['expiration_date'] ?? time() + (24 * 3600), // 24 horas por defecto
                'metadata' => $data['metadata'] ?? []
            ]);

            Log::info('Culqi order created', [
                'order_id' => $order->id,
                'order_number' => $data['order_number']
            ]);

            return [
                'success' => true,
                'order_id' => $order->id,
                'order' => $order
            ];

        } catch (Exception $e) {
            Log::error('Error creating Culqi order', [
                'error' => $e->getMessage(),
                'order_number' => $data['order_number'] ?? null
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Validar datos para crear un cargo
     * 
     * @param array $data
     * @throws Exception
     */
    protected function validateChargeData(array $data): void
    {
        if (empty($data['token'])) {
            throw new Exception('El token de pago es requerido');
        }

        if (empty($data['amount']) || $data['amount'] < 300) { // Mínimo 3 soles en céntimos
            throw new Exception('El monto debe ser al menos 3.00 soles');
        }

        if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            throw new Exception('Email inválido');
        }

        if (empty($data['order_id'])) {
            throw new Exception('El ID de la orden es requerido');
        }
    }

    /**
     * Convertir soles a céntimos
     * 
     * @param float $amount
     * @return int
     */
    public static function amountToCents(float $amount): int
    {
        return (int) round($amount * 100);
    }

    /**
     * Convertir céntimos a soles
     * 
     * @param int $cents
     * @return float
     */
    public static function centsToAmount(int $cents): float
    {
        return round($cents / 100, 2);
    }
}
