<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Culqi API Keys
    |--------------------------------------------------------------------------
    |
    | Llaves de API de Culqi. Usar llaves de prueba (test) en desarrollo
    | y llaves de producción (live) en producción.
    |
    | Obtén tus llaves en: https://panel.culqi.com/
    |
    */

    'public_key' => env('CULQI_PUBLIC_KEY'),
    'secret_key' => env('CULQI_SECRET_KEY'),
    
    /*
    |--------------------------------------------------------------------------
    | Webhook Secret
    |--------------------------------------------------------------------------
    |
    | Secret para validar webhooks de Culqi
    |
    */
    
    'webhook_secret' => env('CULQI_WEBHOOK_SECRET'),

    /*
    |--------------------------------------------------------------------------
    | Configuración General
    |--------------------------------------------------------------------------
    */

    // Moneda por defecto (PEN = Soles peruanos, USD = Dólares)
    'currency' => env('CULQI_CURRENCY', 'PEN'),
    
    // Ambiente (test o live)
    'environment' => env('CULQI_ENVIRONMENT', 'test'),
    
    // URL de retorno después del pago
    'success_url' => env('APP_URL') . '/pago-exitoso',
    'cancel_url' => env('APP_URL') . '/pago-cancelado',
];
