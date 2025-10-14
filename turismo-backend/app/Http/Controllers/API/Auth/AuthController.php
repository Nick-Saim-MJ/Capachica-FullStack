<?php

namespace App\Http\Controllers\API\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Http\Requests\Auth\UpdateProfileRequest;
use App\Http\Requests\Auth\VerifyEmailRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use App\Traits\ApiResponseTrait;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Password;

class AuthController extends Controller
{
    use ApiResponseTrait;

    protected $authService;

    /**
     * Constructor
     *
     * @param AuthService $authService
     */
    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Register a new user
     *
     * @param RegisterRequest $request
     * @return JsonResponse
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = $this->authService->register(
            $request->validated(),
            $request->hasFile('foto_perfil') ? $request->file('foto_perfil') : null
        );

        $token = $user->createToken('auth_token')->plainTextToken;

        return $this->successResponse([
            'user' => new UserResource($user),
            'access_token' => $token,
            'token_type' => 'Bearer',
            'must_setup_2fa' => true,
        ], 'Usuario registrado. Debe habilitar y confirmar 2FA antes de usar la app.', 201);
    }

    /**
     * User login
     *
     * @param LoginRequest $request
     * @return JsonResponse
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login($request->email, $request->password);

        if (!$result) {
            return $this->errorResponse('Credenciales inválidas', 401);
        }

        if (isset($result['error']) && $result['error'] === 'inactive_user') {
            return $this->errorResponse('Usuario inactivo', 403);
        }

        /** @var \App\Models\User $user */
        $user = $result['user'];

        // === 2FA: si el usuario tiene 2FA confirmado, exige código ===
        if ($user->two_factor_confirmed) {

            // 1) si no envió código, pídeselo
            if (!$request->has('two_factor_code')) {
                return $this->errorResponse('Se requiere código 2FA', 403, [
                    'requires_2fa' => true
                ]);
            }

            $twoFactorOk = false;

            // 2) validar TOTP
            if ($user->two_factor_secret) {
                $secret = decrypt($user->two_factor_secret);
                $twoFactorOk = app('pragmarx.google2fa')->verifyKey($secret, $request->two_factor_code, 8);
            }

            // 3) permitir recovery code
            if (!$twoFactorOk) {
                $codes = $user->two_factor_recovery_codes
                    ? explode(',', decrypt($user->two_factor_recovery_codes))
                    : [];
                if (in_array($request->two_factor_code, $codes)) {
                    // invalidar el recovery usado
                    $codes = array_values(array_diff($codes, [$request->two_factor_code]));
                    $user->two_factor_recovery_codes = encrypt(implode(',', $codes));
                    $user->save();
                    $twoFactorOk = true;
                }
            }

            if (!$twoFactorOk) {
                return $this->errorResponse('Código 2FA inválido', 422);
            }
        }if (!$user->two_factor_confirmed) {
        return $this->errorResponse(
            'Debes habilitar y confirmar 2FA antes de usar la app',
            403,
            ['two_factor_setup_required' => true]
        );
    }
        // Nota: ya NO bloqueamos por email verificado (2FA es tu verificación fuerte)
        return $this->successResponse([
            'user' => new UserResource($result['user']),
            'roles' => $result['roles'],
            'permissions' => $result['permissions'],
            'administra_emprendimientos' => $result['administra_emprendimientos'],
            'access_token' => $result['access_token'],
            'token_type' => $result['token_type'],
            'two_factor_enabled' => $user->two_factor_confirmed,
        ], 'Inicio de sesión exitoso');
    }



    /**
     * Login with Google
     *
     * @return JsonResponse
     */
    public function redirectToGoogle(): JsonResponse
    {
        $url = \Laravel\Socialite\Facades\Socialite::driver('google')
            ->stateless()
            ->redirect()
            ->getTargetUrl();

        return $this->successResponse([
            'url' => $url
        ]);
    }

    /**
     * Handle Google callback
     *
     * @return JsonResponse
     */
    public function handleGoogleCallback(): JsonResponse
    {
        $result = $this->authService->handleGoogleCallback();

        if (isset($result['error'])) {
            return $this->errorResponse('Error al autenticar con Google: ' . $result['message'], 500);
        }

        return $this->successResponse([
            'user' => new UserResource($result['user']),
            'roles' => $result['roles'],
            'permissions' => $result['permissions'],
            'administra_emprendimientos' => $result['administra_emprendimientos'],
            'access_token' => $result['access_token'],
            'token_type' => $result['token_type'],
            'email_verified' => $result['email_verified'],
        ], 'Inicio de sesión con Google exitoso');
    }

    /**
     * Get authenticated user profile
     *
     * @return JsonResponse
     */
    public function profile(): JsonResponse
    {
        $user = Auth::user();
        $user->load('emprendimientos.asociacion');

        return $this->successResponse([
            'user' => new UserResource($user),
            'roles' => $user->getRoleNames(),
            'permissions' => $user->getAllPermissions()->pluck('name'),
            'administra_emprendimientos' => $user->administraEmprendimientos(),
            'emprendimientos' => $user->emprendimientos,
            'email_verified' => $user->hasVerifiedEmail(),
            'two_factor_enabled' => $user->two_factor_confirmed,
        ]);
    }

    /**
     * Update user profile
     *
     * @param UpdateProfileRequest $request
     * @return JsonResponse
     */
    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        try {
            $user = $this->authService->updateProfile(
                Auth::user(),
                $request->validated(),
                $request->hasFile('foto_perfil') ? $request->file('foto_perfil') : null
            );

            $emailChanged = $request->has('email') && $request->email !== Auth::user()->getOriginal('email');

            return $this->successResponse(
                new UserResource($user),
                $emailChanged
                    ? 'Perfil actualizado correctamente. Se ha enviado un correo de verificación a su nueva dirección de correo.'
                    : 'Perfil actualizado correctamente'
            );
        } catch (\Exception $e) {
            return $this->errorResponse(
                'Error al actualizar el perfil: ' . $e->getMessage(),
                500
            );
        }
    }

    /**
     * User logout
     *
     * @return JsonResponse
     */
    public function logout(): JsonResponse
    {
        Auth::user()->currentAccessToken()->delete();

        return $this->successResponse(null, 'Sesión cerrada correctamente');
    }


    /**
     * Send password reset link
     *
     * @param ForgotPasswordRequest $request
     * @return JsonResponse
     */
    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $status = $this->authService->sendPasswordResetLink($request->email);

        if ($status === Password::RESET_LINK_SENT) {
            return $this->successResponse(null, 'Se ha enviado un enlace de recuperación a su correo electrónico');
        }

        return $this->errorResponse('No se pudo enviar el correo de recuperación', 500);
    }

    /**
     * Reset password
     *
     * @param ResetPasswordRequest $request
     * @return JsonResponse
     */
    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        $status = $this->authService->resetPassword($request->only('email', 'password', 'password_confirmation', 'token'));

        if ($status === Password::PASSWORD_RESET) {
            return $this->successResponse(null, 'Contraseña actualizada correctamente');
        }

        return $this->errorResponse('No se pudo actualizar la contraseña', 500);
    }
}
