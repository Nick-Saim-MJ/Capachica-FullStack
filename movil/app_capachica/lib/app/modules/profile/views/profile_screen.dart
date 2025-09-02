import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  ProfileView({Key? key}) : super(key: key);

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile =
      await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile != null) {
        controller.setNewProfilePhoto(File(pickedFile.path));
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo seleccionar la imagen: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.profile.value;
        if (profile == null) {
          return const Center(child: Text('No se encontró el perfil.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(() => CircleAvatar(
                radius: 60,
                backgroundImage: controller.newProfilePhoto.value != null
                    ? FileImage(controller.newProfilePhoto.value!)
                    : (profile.fotoPerfilUrl != null
                    ? NetworkImage(profile.fotoPerfilUrl!)
                    : const AssetImage('assets/default_avatar.png')
                as ImageProvider),
              )),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Cambiar foto de perfil'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: controller.name.value,
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (val) => controller.name.value = val,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: controller.email.value,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => controller.email.value = val,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: controller.phone.value,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                onChanged: (val) => controller.phone.value = val,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: controller.country.value,
                decoration: const InputDecoration(labelText: 'País'),
                onChanged: (val) => controller.country.value = val,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: controller.address.value,
                decoration: const InputDecoration(labelText: 'Dirección'),
                onChanged: (val) => controller.address.value = val,
              ),
              const SizedBox(height: 30),
              Obx(() => ElevatedButton(
                onPressed: controller.isUpdating.value
                    ? null
                    : () => controller.updateProfile(),
                child: controller.isUpdating.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : const Text('Actualizar perfil'),
              )),
            ],
          ),
        );
      }),
    );
  }
}
