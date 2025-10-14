import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_user_model.dart';
import '../../domain/bloc/user_form_bloc.dart';

class UserFormScreen extends StatefulWidget {
  final AdminUserModel? user; // null => crear
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _country = TextEditingController();
  final _address = TextEditingController();
  final _gender = ValueNotifier<String?>(null);
  final _birthDate = ValueNotifier<DateTime?>(null);
  final _preferredLang = ValueNotifier<String?>('es');
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  final Set<String> _roles = {};
  String? _fotoPath;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final u = widget.user!;
      _name.text = u.name;
      _email.text = u.email;
      _phone.text = u.phone ?? '';
      _country.text = u.country ?? '';
      _address.text = u.address ?? '';
      _gender.value = u.gender;
      _preferredLang.value = u.preferredLanguage ?? 'es';
      // birthDate si viene en formato yyyy-mm-dd
      _birthDate.value = u.birthDate != null ? DateTime.tryParse(u.birthDate!) : null;
      _roles.addAll(u.roles);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose(); _country.dispose();
    _address.dispose(); _password.dispose(); _password2.dispose();
    _gender.dispose(); _birthDate.dispose(); _preferredLang.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final pic = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pic != null) setState(()=> _fotoPath = pic.path);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text.isNotEmpty && _password.text != _password2.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden')));
      return;
    }

    final fields = <String, dynamic>{
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      if (_password.text.isNotEmpty) 'password': _password.text.trim(),
      if (_password.text.isNotEmpty) 'password_confirmation': _password2.text.trim(),
      if (_phone.text.isNotEmpty) 'phone': _phone.text.trim(),
      if (_country.text.isNotEmpty) 'country': _country.text.trim(),
      if (_address.text.isNotEmpty) 'address': _address.text.trim(),
      if (_gender.value != null && _gender.value!.isNotEmpty) 'gender': _gender.value,
      if (_preferredLang.value != null) 'preferred_language': _preferredLang.value,
      if (_birthDate.value != null) 'birth_date': _birthDate.value!.toIso8601String().split('T').first,
      // roles los asignas con endpoint aparte si así es tu backend:
      // pero si tu store/update acepta roles: agrega 'roles': _roles.toList(),
    };

    final bloc = context.read<UserFormBloc>();
    if (_isEditing) {
      bloc.add(UserUpdateRequested(widget.user!.id, fields, fotoPerfilPath: _fotoPath));
    } else {
      bloc.add(UserCreateRequested(fields, fotoPerfilPath: _fotoPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<UserFormBloc, UserFormState>(
        listener: (context, state) {
          if (state is UserFormError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
          if (state is UserFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? 'Usuario actualizado' : 'Usuario creado'), backgroundColor: Colors.green));
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          final loading = state is UserFormLoading;
          return AbsorbPointer(
            absorbing: loading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Foto
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: (_fotoPath != null) ? FileImage(File(_fotoPath!)) : null,
                          child: _fotoPath == null ? const Icon(Icons.person, size: 32) : null,
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(onPressed: _pickPhoto, icon: const Icon(Icons.photo), label: const Text('Subir foto')),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nombre completo'),
                      validator: (v)=> v==null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v){
                        if (v==null || v.trim().isEmpty) return 'Requerido';
                        if (!v.contains('@')) return 'Correo no válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _country,
                      decoration: const InputDecoration(labelText: 'País'),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _address,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                    ),
                    const SizedBox(height: 8),

                    // Fila: fecha nacimiento + género
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<DateTime?>(
                            valueListenable: _birthDate,
                            builder: (_, val, __) {
                              return InkWell(
                                onTap: () async {
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: val ?? DateTime(now.year-20,1,1),
                                    firstDate: DateTime(1900,1,1),
                                    lastDate: now,
                                  );
                                  if (picked != null) _birthDate.value = picked;
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),
                                  child: Text(val != null ? val.toIso8601String().split('T').first : 'Seleccionar'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ValueListenableBuilder<String?>(
                            valueListenable: _gender,
                            builder: (_, val, __) {
                              return DropdownButtonFormField<String>(
                                value: val,
                                items: const [
                                  DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                                  DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                                ],
                                hint: const Text('Género'),
                                onChanged: (v)=> _gender.value = v,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ValueListenableBuilder<String?>(
                      valueListenable: _preferredLang,
                      builder: (_, val, __) {
                        return DropdownButtonFormField<String>(
                          value: val,
                          decoration: const InputDecoration(labelText: 'Idioma preferido'),
                          items: const [
                            DropdownMenuItem(value: 'es', child: Text('Español')),
                            DropdownMenuItem(value: 'en', child: Text('Inglés')),
                          ],
                          onChanged: (v)=> _preferredLang.value = v,
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Contraseña (solo obligatoria en crear)
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (v){
                        if (!_isEditing) {
                          if (v==null || v.trim().isEmpty) return 'Requerido';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _password2,
                      decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                      obscureText: true,
                      validator: (v){
                        if (!_isEditing && (v==null || v.trim().isEmpty)) return 'Requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Roles (selección sencilla; si prefieres, traer /roles)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          for (final r in const ['admin','user','emprendedor','moderador'])
                            FilterChip(
                              label: Text(r),
                              selected: _roles.contains(r),
                              onSelected: (sel){
                                setState(() {
                                  sel ? _roles.add(r) : _roles.remove(r);
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        child: Text(_isEditing ? 'Actualizar' : 'Crear'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
