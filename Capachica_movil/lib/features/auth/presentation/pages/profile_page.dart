import 'dart:io';

import 'package:aplicativo_capachica/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:aplicativo_capachica/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aplicativo_capachica/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para campos que no son dropdowns
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Variables para Dropdowns y DatePicker
  String? _selectedCountry;
  String? _selectedGender;
  String? _selectedLanguage;
  String? _birthDate; // Mantener como String (YYYY-MM-DD)
  String? _fotoPath;

  // Listas de opciones (ejemplo, puedes cargarlas de una API o config)
  // 🛑 CORRECCIÓN: Se vuelve a usar 'Perú' (con tilde) para coincidir con el último log.
  final List<String> _countries = ['Perú', 'Bolivia', 'Chile', 'Ecuador', 'Colombia', 'Otro'];
  final Map<String, String> _countryDisplay = {
    'Perú': 'Perú',
    'Bolivia': 'Bolivia',
    'Chile': 'Chile',
    'Ecuador': 'Ecuador',
    'Colombia': 'Colombia',
    'Otro': 'Otro',
  };

  final List<String> _genders = ['male', 'female', 'other', 'Prefer not to say'];
  final Map<String, String> _genderDisplay = {
    'male': 'Masculino',
    'female': 'Femenino',
    'other': 'No binario',
    'Prefer not to say': 'Prefiero no decirlo',
  };

  final List<String> _languages = ['es', 'en', 'Portugues', 'Frances'];
  final Map<String, String> _languageDisplay = {
    'es': 'Español',
    'en': 'Inglés',
    'Portugues': 'Portugués',
    'Frances': 'Francés',
  };

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Inicializa controladores y variables con los datos del usuario
  void _initializeFields(dynamic user) {
    _nameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phone ?? '';
    _addressController.text = user.address ?? '';

    // Inicializar dropdowns y fecha
    _selectedCountry = user.country;
    _selectedGender = user.gender;
    _selectedLanguage = user.preferredLanguage;
    _birthDate = user.birthDate;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _fotoPath = image.path);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = _birthDate != null && _birthDate!.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_birthDate!)
          : DateTime.now();
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'), // Para español
    );

    if (picked != null) {
      setState(() {
        _birthDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final params = UpdateProfileParams(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _selectedCountry,
        birthDate: _birthDate,
        address: _addressController.text.trim(),
        gender: _selectedGender,
        preferredLanguage: _selectedLanguage,
        fotoPerfilPath: _fotoPath,
      );
      context.read<ProfileCubit>().updateProfile(params);
    }
  }

  void _logout() async {
    // 1. Llama al AuthCubit global para ejecutar el logout.
    // La navegación será manejada por el AuthGate listener.
    context.read<AuthCubit>().logout();

    // Eliminar el pop() redundante o cualquier otro Navigator.of(context).push...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            // Se actualiza el estado local de la foto por si acaso
            setState(() => _fotoPath = null);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil actualizado con éxito!')),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && (_nameController.text.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = (state is ProfileLoaded)
              ? state.user
              : (state is ProfileUpdated)
              ? state.user
              : null;

          if (user != null) {
            // Inicializa los campos SOLO la primera vez que se tiene el objeto user
            if (_nameController.text.isEmpty) {
              _initializeFields(user);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- Selector de Foto ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _fotoPath != null
                                ? FileImage(File(_fotoPath!))
                                : (user.fotoPerfil != null ? NetworkImage(user.fotoPerfil!) : null) as ImageProvider?,
                            child: _fotoPath == null && user.fotoPerfil == null
                                ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                          ),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.amber[800],
                            child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- Campos Editables ---
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nombre Completo',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'El nombre es obligatorio' : null,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false, // El email no debería ser editable sin un proceso de verificación
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Dirección',
                      icon: Icons.location_on_outlined,
                    ),

                    // --- Dropdown Género ---
                    _buildDropdown(
                      label: 'Género',
                      icon: Icons.wc_outlined,
                      value: _selectedGender,
                      values: _genders,
                      displayMap: _genderDisplay,
                      onChanged: (newValue) => setState(() => _selectedGender = newValue),
                    ),

                    // --- Dropdown País ---
                    _buildDropdown(
                      label: 'País',
                      icon: Icons.public_outlined,
                      value: _selectedCountry,
                      values: _countries,
                      displayMap: _countryDisplay,
                      onChanged: (newValue) => setState(() => _selectedCountry = newValue),
                    ),

                    // Idioma Preferido
                    _buildDropdown(
                      label: 'Idioma Preferido',
                      icon: Icons.language_outlined,
                      value: _selectedLanguage,
                      values: _languages,
                      displayMap: _languageDisplay,
                      onChanged: (newValue) => setState(() => _selectedLanguage = newValue),
                    ),

                    // --- Selector de Fecha de Nacimiento ---
                    _buildDatePicker(),

                    const SizedBox(height: 30),

                    // --- Botón de Guardar ---
                    ElevatedButton.icon(
                      onPressed: _updateProfile,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Guardar cambios', style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Botón de Cerrar Sesión ---
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProfileError) {
            return Center(child: Text('Error al cargar el perfil: ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Helper para construir TextFormField con diseño mejorado
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.amber[800]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabled: enabled,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          filled: true,
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  // Helper para construir DropdownButton
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> values,
    required Map<String, String> displayMap,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.amber[800]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: value,
        isExpanded: true,
        hint: Text('Selecciona $label'),
        items: values.map((String itemValue) {
          return DropdownMenuItem<String>(
            value: itemValue,
            child: Text(displayMap[itemValue] ?? itemValue),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Selecciona un $label' : null,
      ),
    );
  }

  // Helper para construir el selector de fecha
  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Fecha de Nacimiento',
            prefixIcon: Icon(Icons.calendar_today_outlined, color: Colors.amber[800]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(
            _birthDate ?? 'Selecciona la fecha',
            style: TextStyle(
              fontSize: 16,
              color: _birthDate == null ? Colors.grey.shade600 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}