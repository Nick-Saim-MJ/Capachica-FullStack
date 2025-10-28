<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reserva {{ $reserva->codigo_reserva }}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'DejaVu Sans', Arial, sans-serif;
            margin: 0;
            padding: 15px;
            color: #1f2937;
            line-height: 1.3;
            font-size: 11px;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #2563eb;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        
        .header-left h1 {
            color: #2563eb;
            margin: 0;
            font-size: 20px;
            font-weight: bold;
        }
        
        .header-left h2 {
            color: #6b7280;
            margin: 3px 0 0 0;
            font-size: 14px;
            font-weight: normal;
        }
        
        .header-right {
            text-align: center;
        }
        
        .qr-code {
            width: 80px;
            height: 80px;
            margin: 0 auto 3px auto;
            border: 2px solid #e5e7eb;
            padding: 3px;
            background: white;
        }
        
        .qr-code svg {
            width: 100%;
            height: 100%;
            display: block;
        }
        
        .qr-label {
            font-size: 7px;
            color: #374151;
            margin-top: 2px;
            font-weight: bold;
            letter-spacing: 0.5px;
        }
        
        .reserva-info {
            background-color: #f8fafc;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 12px;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 6px;
        }
        
        .info-col {
            flex: 1;
        }
        
        .info-item {
            margin-bottom: 4px;
            font-size: 10px;
        }
        
        .info-label {
            font-weight: bold;
            color: #374151;
            display: inline-block;
            min-width: 75px;
        }
        
        .info-value {
            color: #6b7280;
        }
        
        .estado {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 9px;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .estado-pendiente {
            background-color: #fef3c7;
            color: #92400e;
        }
        
        .estado-confirmada {
            background-color: #d1fae5;
            color: #065f46;
        }
        
        .estado-cancelada {
            background-color: #fee2e2;
            color: #991b1b;
        }
        
        .estado-completada {
            background-color: #e0e7ff;
            color: #3730a3;
        }
        
        .servicios-section h3 {
            color: #2563eb;
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 5px;
            margin-bottom: 8px;
            font-size: 13px;
        }
        
        .servicio-item {
            background-color: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            padding: 8px;
            margin-bottom: 6px;
            page-break-inside: avoid;
        }
        
        .servicio-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 6px;
            border-bottom: 1px dashed #e5e7eb;
            padding-bottom: 4px;
        }
        
        .servicio-nombre {
            font-size: 12px;
            font-weight: bold;
            color: #1f2937;
        }
        
        .servicio-precio {
            font-size: 11px;
            font-weight: bold;
            color: #059669;
        }
        
        .servicio-details {
            display: flex;
            justify-content: space-between;
            font-size: 9px;
        }
        
        .servicio-col {
            flex: 1;
        }
        
        .servicio-detail {
            margin-bottom: 3px;
        }
        
        .servicio-detail-label {
            font-weight: bold;
            color: #374151;
            display: inline-block;
            min-width: 70px;
        }
        
        .servicio-detail-value {
            color: #6b7280;
        }
        
        .total-section {
            background-color: #1f2937;
            color: white;
            padding: 10px;
            border-radius: 5px;
            margin-top: 12px;
            text-align: center;
        }
        
        .total-label {
            font-size: 11px;
            margin-bottom: 4px;
        }
        
        .total-amount {
            font-size: 18px;
            font-weight: bold;
            color: #10b981;
        }
        
        .footer {
            margin-top: 12px;
            text-align: center;
            color: #6b7280;
            font-size: 8px;
            border-top: 1px solid #e5e7eb;
            padding-top: 8px;
        }
        
        .notas {
            background-color: #f3f4f6;
            padding: 8px;
            border-radius: 4px;
            margin-top: 8px;
            font-size: 9px;
        }
        
        .notas h4 {
            margin: 0 0 4px 0;
            color: #374151;
            font-size: 10px;
        }
        
        .notas p {
            margin: 0;
            color: #6b7280;
        }
        
        .two-columns {
            display: flex;
            gap: 8px;
        }
        
        .column {
            flex: 1;
        }
        
        @media print {
            body {
                margin: 0;
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-left">
            <h1>COMPROBANTE DE RESERVA</h1>
            <h2>{{ $reserva->codigo_reserva }}</h2>
        </div>
        <div class="header-right">
            <div class="qr-code">
                @php
                    // Obtener QR como base64 desde API externa
                    $qrData = urlencode($reserva->codigo_reserva);
                    $qrApiUrl = "https://api.qrserver.com/v1/create-qr-code/?size=120x120&data={$qrData}";
                    
                    try {
                        $qrImageData = @file_get_contents($qrApiUrl);
                        if ($qrImageData !== false) {
                            $qrBase64 = 'data:image/png;base64,' . base64_encode($qrImageData);
                        } else {
                            $qrBase64 = null;
                        }
                    } catch (\Exception $e) {
                        $qrBase64 = null;
                    }
                @endphp
                @if($qrBase64)
                    <img src="{{ $qrBase64 }}" alt="QR Code" style="width: 80px; height: 80px; display: block;">
                @else
                    <div style="width: 80px; height: 80px; border: 2px solid #000; display: flex; align-items: center; justify-content: center; font-size: 8px;">
                        QR no disponible
                    </div>
                @endif
            </div>
            <div class="qr-label">{{ $reserva->codigo_reserva }}</div>
        </div>
    </div>
    
    
    <div class="reserva-info">
        <div class="info-row">
            <div class="info-col">
                <div class="info-item">
                    <span class="info-label">Cliente:</span>
                    <span class="info-value">{{ $reserva->usuario ? $reserva->usuario->name : 'N/A' }}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Email:</span>
                    <span class="info-value">{{ $reserva->usuario ? $reserva->usuario->email : 'N/A' }}</span>
                </div>
            </div>
            <div class="info-col">
                <div class="info-item">
                    <span class="info-label">Fecha reserva:</span>
                    <span class="info-value">{{ $reserva->created_at->format('d/m/Y H:i') }}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Estado:</span>
                    <span class="estado estado-{{ $reserva->estado }}">{{ ucfirst($reserva->estado) }}</span>
                </div>
            </div>
        </div>
    </div>
    
    <div class="servicios-section">
        <h3>📋 Servicios Reservados ({{ $reserva->servicios->count() }})</h3>
        
        @foreach($reserva->servicios as $index => $servicio)
        <div class="servicio-item">
            <div class="servicio-header">
                <div class="servicio-nombre">{{ $index + 1 }}. {{ $servicio->servicio ? $servicio->servicio->nombre : 'Servicio' }}</div>
                <div class="servicio-precio">S/. {{ number_format(($servicio->precio ?? 0) * ($servicio->cantidad ?? 1), 2) }}</div>
            </div>
            
            <div class="servicio-details">
                <div class="servicio-col">
                    <div class="servicio-detail">
                        <span class="servicio-detail-label">Emprendedor:</span>
                        <span class="servicio-detail-value">{{ $servicio->emprendedor ? $servicio->emprendedor->nombre : 'N/A' }}</span>
                    </div>
                    <div class="servicio-detail">
                        <span class="servicio-detail-label">Fecha:</span>
                        <span class="servicio-detail-value">
                            {{ $servicio->fecha_inicio ? \Carbon\Carbon::parse($servicio->fecha_inicio)->format('d/m/Y') : 'N/A' }}
                            @if($servicio->fecha_fin && $servicio->fecha_fin != $servicio->fecha_inicio)
                                - {{ \Carbon\Carbon::parse($servicio->fecha_fin)->format('d/m/Y') }}
                            @endif
                        </span>
                    </div>
                </div>
                <div class="servicio-col">
                    <div class="servicio-detail">
                        <span class="servicio-detail-label">Horario:</span>
                        <span class="servicio-detail-value">
                            {{ $servicio->hora_inicio ? \Carbon\Carbon::parse($servicio->hora_inicio)->format('H:i') : 'N/A' }}
                            - {{ $servicio->hora_fin ? \Carbon\Carbon::parse($servicio->hora_fin)->format('H:i') : 'N/A' }}
                        </span>
                    </div>
                    <div class="servicio-detail">
                        <span class="servicio-detail-label">Cantidad:</span>
                        <span class="servicio-detail-value">{{ $servicio->cantidad ?? 1 }} x S/. {{ number_format($servicio->precio ?? 0, 2) }}</span>
                    </div>
                </div>
            </div>
            
            @if(!empty($servicio->notas_cliente))
            <div class="notas" style="margin-top: 5px;">
                <strong>Nota:</strong> {{ $servicio->notas_cliente }}
            </div>
            @endif
        </div>
        @endforeach
    </div>
    
    <div class="total-section">
        <div class="total-label">💰 Total de la Reserva</div>
        <div class="total-amount">S/. {{ number_format($reserva->servicios->sum(function($s) { return ($s->precio ?? 0) * ($s->cantidad ?? 1); }), 2) }}</div>
    </div>
    
    @if($reserva->notas)
    <div class="notas">
        <h4>📝 Notas adicionales:</h4>
        <p>{{ $reserva->notas }}</p>
    </div>
    @endif
    
    <div class="footer">
        <p><strong>Sistema de Turismo Capachica</strong> • Generado el {{ now()->format('d/m/Y H:i:s') }}</p>
        <p>📞 Contacto: info@turisimocapachica.com | 🌐 www.turismocapachica.com</p>
    </div>
</body>
</html>