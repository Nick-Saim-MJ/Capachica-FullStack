import 'package:aplicativo_capachica/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  // Controllers existentes
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController(); // Nuevo
  // Nuevos controladores para los campos solicitados
  final _phone = TextEditingController();
  final _address = TextEditingController();

  // Variables de estado para Dropdowns y DatePicker
  String? _gender;
  String? _country;
  String? _preferredLanguage;
  DateTime? _birthDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Listas de ejemplo para Dropdowns
  final List<String> _genderOptions = ['Masculino', 'Femenino', 'Otro'];
  final List<String> _countryOptions = ['Perú', 'Bolivia', 'Chile', 'Argentina', 'Brasil'];
  final List<String> _languageOptions = ['Español', 'Inglés', 'Quechua', 'Aymara'];


  // Función para mostrar DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 años atrás
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Usamos el mismo diseño de fondo empresarial y sin AppBar que LoginPage
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is AuthEmailNotVerified) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Te enviamos un correo para verificar tu cuenta.')));
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading; // Variable 'loading' definida aquí

          // Usamos un Stack para colocar elementos de fondo detrás del formulario
          return Stack(
            children: [
              // 1. Elemento de Fondo (IMAGEN DE FONDO LOCAL, similar a LoginPage)
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    'assets/images/fondo_login.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.blue[800],
                      child: const Center(child: Text('Error cargando asset local', style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
              ),

              // 2. Título Flotante
              const Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'CREAR CUENTA',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(blurRadius: 5.0, color: Colors.black54, offset: Offset(0, 2))
                          ]
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Únete a la Gestión de Turismo Capachica',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          shadows: [
                            Shadow(blurRadius: 5.0, color: Colors.black54, offset: Offset(0, 1))
                          ]
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Formulario Centrado (envuelto en SingleChildScrollView para todos los campos)
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 150),
                  child: Card(
                    elevation: 10,
                    // Tarjeta casi transparente (0.05)
                    color: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Registro de Usuario',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // 1. Nombre Completo (required)
                            _buildTextFormField(
                              controller: _name,
                              label: 'Nombre Completo',
                              icon: Icons.person_outline,
                              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),

                            // 2. Correo (required)
                            _buildTextFormField(
                              controller: _email,
                              label: 'Correo Electrónico',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || !v.contains('@')) ? 'Correo inválido' : null,
                            ),
                            const SizedBox(height: 16),

                            // 3. Teléfono (phone)
                            _buildTextFormField(
                              controller: _phone,
                              label: 'Teléfono',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 16),

                            // 4. País (country) - Dropdown
                            _buildDropdown(
                              value: _country,
                              label: 'País',
                              icon: Icons.public_outlined,
                              items: _countryOptions,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _country = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // 5. Fecha de Nacimiento (birthDate) - Date Picker
                            _buildDatePickerField(context, loading: loading), // PASAMOS 'loading' AQUÍ
                            const SizedBox(height: 16),

                            // 6. Dirección (address)
                            _buildTextFormField(
                              controller: _address,
                              label: 'Dirección',
                              icon: Icons.location_on_outlined,
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 16),

                            // 7. Género (gender) - Dropdown
                            _buildDropdown(
                              value: _gender,
                              label: 'Género',
                              icon: Icons.wc_outlined,
                              items: _genderOptions,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _gender = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // 8. Idioma Preferido (preferredLanguage) - Dropdown
                            _buildDropdown(
                              value: _preferredLanguage,
                              label: 'Idioma Preferido',
                              icon: Icons.language_outlined,
                              items: _languageOptions,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _preferredLanguage = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // 9. Contraseña (required)
                            _buildTextFormField(
                              controller: _password,
                              label: 'Contraseña',
                              icon: Icons.lock_outline,
                              obscure: _obscurePassword,
                              isPassword: true,
                              onVisibilityToggle: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                              validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
                            ),
                            const SizedBox(height: 16),

                            // 10. Confirmar Contraseña (required)
                            _buildTextFormField(
                              controller: _confirmPassword,
                              label: 'Confirmar Contraseña',
                              icon: Icons.lock_outline,
                              obscure: _obscureConfirmPassword,
                              isPassword: true,
                              onVisibilityToggle: () {
                                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                              // Valida que esta contraseña sea igual a la anterior
                              validator: (v) => (v != _password.text) ? 'Las contraseñas no coinciden' : null,
                            ),

                            const SizedBox(height: 40),

                            // Botón Registrarme
                            ElevatedButton(
                              onPressed: loading ? null : () {
                                if (_form.currentState!.validate()) {
                                  // Llamada a register solo con los campos requeridos por el cubit existente.
                                  // NOTA: Los campos adicionales (teléfono, dirección, etc.) se recolectaron
                                  // pero no se pasan al método register actual, ya que solo acepta name, email y password.
                                  context.read<AuthCubit>().register(
                                      name: _name.text.trim(),
                                      email: _email.text.trim(),
                                      password: _password.text
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                              ),
                              child: Text(
                                loading ? 'CREANDO...' : 'REGISTRARME',
                                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Botón para Volver a Iniciar Sesión
                            TextButton(
                              onPressed: loading ? null : () => Navigator.of(context).pop(),
                              child: Text(
                                '¿Ya tienes cuenta? Inicia sesión aquí',
                                style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget helper para TextFormFields para mantener el estilo
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscure = false,
    bool isPassword = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey[900]),
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword && onVisibilityToggle != null
            ? IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.blueGrey),
          onPressed: onVisibilityToggle,
        )
            : null,
      ),
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: Colors.blueGrey[900]),
    );
  }

  // Widget helper para Dropdowns para mantener el estilo
  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey[900]),
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      dropdownColor: Colors.white,
      style: TextStyle(color: Colors.blueGrey[900]),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => null, // Los campos adicionales no son estrictamente requeridos aquí
    );
  }

  // Widget helper para Date Picker Field
  Widget _buildDatePickerField(BuildContext context, {required bool loading}) { // Modificado para aceptar 'loading'
    return InkWell(
      onTap: loading ? null : () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de Nacimiento',
          labelStyle: TextStyle(color: Colors.blueGrey[900]),
          prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.blueGrey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _birthDate == null
              ? 'Seleccionar fecha'
              : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
          style: TextStyle(
            color: _birthDate == null ? Colors.blueGrey[400] : Colors.blueGrey[900],
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
