import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/login_controller.dart';
import '../../../routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';

class LoginScreen extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background similar al HomeScreen
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_home.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Gradient overlay
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A237E).withOpacity(0.4),
                  Color(0xFF3949AB).withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight * 0.9),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button (se muestra solo si se puede volver)
                      if (Get.previousRoute.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                      ] else ...[
                        SizedBox(height: screenHeight * 0.08),
                      ],

                      // Title
                      Text(
                        'Iniciar\nSesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),

                      SizedBox(height: 8),
                      Text(
                        'Accede a tu cuenta',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.08),

                      // Email field
                      _buildInputField(
                        controller: controller.emailController,
                        label: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim().toLowerCase() ?? '';
                          if (email.isEmpty) return 'Ingresa tu email';
                          if (!GetUtils.isEmail(email)) return 'Email inválido';
                          return null;
                        },
                      ),

                      SizedBox(height: 24),

                      // Password field
                      Obx(() => _buildInputField(
                        controller: controller.passwordController,
                        label: 'Contraseña',
                        icon: Icons.lock_outline,
                        obscureText: !controller.isPasswordVisible.value,
                        suffixIcon: GestureDetector(
                          onTap: controller.togglePasswordVisibility,
                          child: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white70,
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Ingresa tu contraseña';
                          if (value!.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      )),

                      SizedBox(height: screenHeight * 0.06),

                      // Login button
                      Obx(() => _buildLoginButton(screenWidth)),

                      SizedBox(height: 16),

                      // Forgot Password link
                      _buildForgotPasswordButton(),

                      SizedBox(height: 16),

                      // Divider
                      _buildDivider(),

                      SizedBox(height: 24),

                      // Google Sign-In Button
                      _buildGoogleSignInButton(),

                      SizedBox(height: 24),

                      // Register link
                      Center(
                        child: GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.REGISTER),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                              children: [
                                TextSpan(text: '¿No tienes cuenta? '),
                                TextSpan(
                                  text: 'Regístrate',
                                  style: TextStyle(
                                    color: Color(0xFFFF9100),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          color: Colors.white, 
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: Colors.white,
        cursorWidth: 2.5,
        cursorRadius: Radius.circular(2),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton(double screenWidth) {
    return GestureDetector(
      onTap: controller.isLoading.value ? null : controller.login,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9100), Color(0xFFFF6F00)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF9100).withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: controller.isLoading.value
            ? Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ),
        )
            : Text(
          'Iniciar Sesión',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('O', style: TextStyle(color: Colors.white70)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return ElevatedButton.icon(
      onPressed: controller.signInWithGoogle,
      icon: Image.asset(
        'assets/google_logo.png',
        height: 22.0,
        width: 22.0,
      ),
      label: Text('Continuar con Google'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        minimumSize: Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          final email = controller.emailController.text.trim();
          if (email.isEmpty) {
            Get.snackbar(
              'Campo requerido',
              'Por favor ingresa tu correo electrónico para recuperar tu contraseña.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }

          try {
            await controller.forgotPassword(email);
            Get.snackbar(
              'Enlace enviado',
              'Se ha enviado un enlace de recuperación a tu correo electrónico.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              e.toString(),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}