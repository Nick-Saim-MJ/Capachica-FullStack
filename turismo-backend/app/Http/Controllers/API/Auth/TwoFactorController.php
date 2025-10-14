<?php

namespace App\Http\Controllers\API\Auth;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TwoFactorController extends Controller
{
    use ApiResponseTrait;

    public function enable(Request $request)
    {
        $user = Auth::user();

        // Generar secreto + recovery si no existe aún
        if (!$user->two_factor_secret) {
            $secret = app('pragmarx.google2fa')->generateSecretKey();
            $user->two_factor_secret = encrypt($secret);

            // 8 códigos de recuperación
            $codes = collect(range(1,8))
                ->map(fn() => strtoupper(bin2hex(random_bytes(5))))
                ->implode(',');
            $user->two_factor_recovery_codes = encrypt($codes);

            $user->save();
        } else {
            $secret = decrypt($user->two_factor_secret);
        }

        // URL otpauth:// para escanear con Google Authenticator
        $otpUrl = app('pragmarx.google2fa')->getQRCodeUrl(
            config('app.name', 'Capachica'),
            $user->email,
            $secret
        );

        return $this->successResponse([
            'otpauth_url' => $otpUrl, // El front puede renderizar QR con esto
            'secret' => $secret,      // opcional mostrarlo como texto
            'recovery_codes' => explode(',', decrypt($user->two_factor_recovery_codes)),
            'two_factor_confirmed' => $user->two_factor_confirmed,
        ], 'Escanea el QR en Google Authenticator y confirma con el código.');
    }

    public function confirm(Request $request)
    {
        $request->validate(['code' => 'required|string']);

        $user = Auth::user();
        if (!$user->two_factor_secret) {
            return $this->errorResponse('Primero habilita 2FA', 400);
        }

        $secret = decrypt($user->two_factor_secret);
        $valid = app('pragmarx.google2fa')->verifyKey($secret, $request->code, 8);

        if (!$valid) {
            return $this->errorResponse('Código 2FA inválido', 422);
        }

        $user->two_factor_confirmed = true;
        $user->save();

        return $this->successResponse([
            'two_factor_confirmed' => true
        ], '2FA confirmado.');
    }

    public function disable(Request $request)
    {
        $request->validate([
            'code'     => 'nullable|string',
            'recovery' => 'nullable|string',
        ]);

        $user = Auth::user();
        if (!$user->two_factor_secret) {
            return $this->successResponse(null, '2FA ya estaba deshabilitado.');
        }

        $ok = false;
        // Validar TOTP
        if ($request->filled('code')) {
            $secret = decrypt($user->two_factor_secret);
            $ok = app('pragmarx.google2fa')->verifyKey($secret, $request->code, 8);
        }
        // O validar recovery
        if (!$ok && $request->filled('recovery')) {
            $codes = explode(',', decrypt($user->two_factor_recovery_codes));
            if (in_array($request->recovery, $codes)) {
                $codes = array_values(array_diff($codes, [$request->recovery]));
                $user->two_factor_recovery_codes = encrypt(implode(',', $codes));
                $ok = true;
            }
        }

        if (!$ok) {
            return $this->errorResponse('Ni el TOTP ni el recovery code son válidos', 422);
        }

        $user->two_factor_secret = null;
        $user->two_factor_recovery_codes = null;
        $user->two_factor_confirmed = false;
        $user->save();

        return $this->successResponse(null, '2FA deshabilitado.');
    }
}
