import 'dart:io';
import 'dart:ui';
import 'package:flutter/src/material/theme_data.dart';
import 'package:get/get.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../data/models/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository;

  ProfileController(this._profileRepository);

  var profile = Rxn<ProfileModel>();

  var isLoading = false.obs;
  var isUpdating = false.obs;

  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var country = ''.obs;
  var address = ''.obs;

  var newProfilePhoto = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final loadedProfile = await _profileRepository.getProfile();
      profile.value = loadedProfile;

      name.value = loadedProfile.name;
      email.value = loadedProfile.email;
      phone.value = loadedProfile.phone ?? '';
      country.value = loadedProfile.country ?? '';
      address.value = loadedProfile.address ?? '';
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el perfil: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.errorColor,
          colorText: Get.theme.colorScheme.onError);
    } finally {
      isLoading.value = false;
    }
  }

  void setNewProfilePhoto(File photo) {
    newProfilePhoto.value = photo;
  }

  Future<void> updateProfile() async {
    // Lógica para actualizar perfil...
  }
}

extension on ThemeData {
  Color? get errorColor => null;
}
