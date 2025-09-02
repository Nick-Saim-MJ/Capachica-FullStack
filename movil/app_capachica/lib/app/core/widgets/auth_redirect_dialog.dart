import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';

class AuthRedirectDialog extends StatelessWidget {
  final VoidCallback? onLoginPressed;
  final VoidCallback? onRegisterPressed;

  const AuthRedirectDialog({
    super.key,
    this.onLoginPressed,
    this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: theme.dialogBackgroundColor,
      title: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: theme.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Autenticación requerida',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        'Debes iniciar sesión o registrarte para poder reservar servicios.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
        ),
      ),
      actions: [
        // Botón Cancelar
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancelar',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.textTheme.labelLarge?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
        
        // Botón Registrar
        OutlinedButton.icon(
          onPressed: () {
            Get.back();
            final box = GetStorage();
            if (box.read('pending_route') == null) {
              box.write('pending_route', '/register');
            }
            if (onRegisterPressed != null) {
              onRegisterPressed!();
            } else {
              Get.toNamed(AppRoutes.REGISTER);
            }
          },
          icon: Icon(
            Icons.person_add_rounded,
            size: 18,
            color: theme.primaryColor,
          ),
          label: Text(
            'Registrar',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        
        // Botón Iniciar Sesión
        ElevatedButton.icon(
          onPressed: () {
            Get.back();
            final box = GetStorage();
            if (box.read('pending_route') == null) {
              box.write('pending_route', '/login');
            }
            if (onLoginPressed != null) {
              onLoginPressed!();
            } else {
              Get.toNamed(AppRoutes.LOGIN);
            }
          },
          icon: Icon(
            Icons.login_rounded,
            size: 18,
            color: Colors.white,
          ),
          label: Text(
            'Iniciar Sesión',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
} 