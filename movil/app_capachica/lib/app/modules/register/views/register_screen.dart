import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import 'package:get_storage/get_storage.dart';

class RegisterScreen extends GetView<RegisterController> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo y gradiente consistentes
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
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flecha de retroceso
                  GestureDetector(
                    onTap: () {
                      final box = GetStorage();
                      final pendingRoute = box.read('pending_route') as String?;
                      if (pendingRoute != null) {
                        box.remove('pending_route');
                        Get.back(); // Regresar del registro
                        Get.toNamed(pendingRoute);
                      } else {
                        Get.back();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 8),
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
                  SizedBox(height: 16),

                  Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),

                        // Selector de Imagen de Perfil
                        _buildProfileImageSelector(),
                        SizedBox(height: 30),

                        // Título
                        Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Completa tus datos para unirte',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 30),

                        // --- Campos del Formulario ---
                        _buildInputField(
                          controller: controller.nameController,
                          label: 'Nombre completo',
                          icon: Icons.person_outline,
                          validator: (value) => (value?.isEmpty ?? true) ? 'Ingresa tu nombre' : null,
                        ),
                        SizedBox(height: 20),
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
                        SizedBox(height: 20),
                         _buildInputField(
                          controller: controller.phoneController,
                          label: 'Teléfono (Opcional)',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 20),
                        Obx(() => _buildInputField(
                              controller: controller.passwordController,
                              label: 'Contraseña',
                              icon: Icons.lock_outline,
                              obscureText: !controller.isPasswordVisible.value,
                              suffixIcon: _buildPasswordToggle(controller.isPasswordVisible),
                              validator: (value) => (value?.length ?? 0) < 8 ? 'Mínimo 8 caracteres' : null,
                            )),
                        SizedBox(height: 20),
                        Obx(() => _buildInputField(
                              controller: controller.passwordConfirmationController,
                              label: 'Confirmar contraseña',
                              icon: Icons.lock_outline,
                              obscureText: !controller.isPasswordConfirmVisible.value,
                              suffixIcon: _buildPasswordToggle(controller.isPasswordConfirmVisible),
                              validator: (value) => value != controller.passwordController.text ? 'Las contraseñas no coinciden' : null,
                            )),
                        
                        SizedBox(height: 20),
                        _buildDatePickerField(context),

                        SizedBox(height: 20),
                        _buildDropdownField(
                          value: controller.gender.value,
                          onChanged: (value) => controller.gender.value = value,
                          items: ['Masculino', 'Femenino', 'Otro'],
                          hint: 'Género (Opcional)',
                          icon: Icons.wc_outlined,
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: controller.countryController,
                          label: 'País (Opcional)',
                          icon: Icons.public_outlined,
                        ),
                        SizedBox(height: 20),
                         _buildInputField(
                          controller: controller.addressController,
                          label: 'Dirección (Opcional)',
                          icon: Icons.location_on_outlined,
                        ),
                        SizedBox(height: 20),
                         _buildDropdownField(
                          value: controller.preferredLanguage.value,
                          onChanged: (value) => controller.preferredLanguage.value = value,
                          items: ['Español', 'Inglés', 'Portugués', 'Quechua'],
                          hint: 'Idioma Preferido (Opcional)',
                          icon: Icons.language_outlined,
                        ),

                        SizedBox(height: 40),
                        Obx(() => _buildRegisterButton()),
                        SizedBox(height: 20),

                         // Botón para volver al Login
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            '¿Ya tienes una cuenta? Inicia Sesión',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSelector() {
    return Center(
      child: Stack(
        children: [
          Obx(() => CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: controller.profileImage.value != null
                    ? FileImage(controller.profileImage.value!)
                    : null,
                child: controller.profileImage.value == null
                    ? Icon(Icons.camera_alt, color: Colors.white, size: 40)
                    : null,
              )),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFF9100),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 20),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: Colors.white,
      cursorWidth: 2.5,
      cursorRadius: Radius.circular(2),
      decoration: _inputDecoration(label, icon, suffixIcon),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return TextFormField(
      controller: controller.birthDateController,
      readOnly: true,
      onTap: () => controller.pickBirthDate(context),
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: Colors.white,
      cursorWidth: 2.5,
      cursorRadius: Radius.circular(2),
      decoration: _inputDecoration('Fecha de Nacimiento (Opcional)', Icons.calendar_today_outlined, null),
    );
  }
  
  Widget _buildDropdownField({
    String? value,
    required void Function(String?) onChanged,
    required List<String> items,
    required String hint,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: Color(0xFF3949AB),
      decoration: _inputDecoration(hint, icon, null).copyWith(
        // Adaptación para que la flecha del dropdown sea blanca
         suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.white70),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, Widget? suffixIcon) {
      return InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFFF9100)),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        );
  }

  Widget _buildPasswordToggle(RxBool isVisible) {
    return GestureDetector(
      onTap: () => isVisible.value = !isVisible.value,
      child: Icon(
        isVisible.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF9100),
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: controller.isLoading.value
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Crear Mi Cuenta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
} 