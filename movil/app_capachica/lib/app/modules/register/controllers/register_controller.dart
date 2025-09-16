import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import '../../../services/auth_service.dart';
import '../../../data/models/login_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/controllers/cart_controller.dart';
import '../../../core/widgets/cart_bottom_sheet.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final birthDateController = TextEditingController();
  final addressController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isPasswordConfirmVisible = false.obs;
  final gender = Rxn<String>();
  final preferredLanguage = Rxn<String>();
  final profileImage = Rxn<File>();
  final birthDate = Rxn<DateTime>();

  static const Map<String, String> genderOptions = {
    'Masculino': 'male',
    'Femenino': 'female',
    'Otro': 'other',
  };

  void togglePasswordVisibility() => isPasswordVisible.value = !isPasswordVisible.value;
  void togglePasswordConfirmVisibility() => isPasswordConfirmVisible.value = !isPasswordConfirmVisible.value;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> pickBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDate.value ?? DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthDate.value) {
      birthDate.value = picked;
      birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar('Error de Validación', 'Por favor, corrige los campos marcados en rojo.');
      return;
    }

    isLoading.value = true;
    try {
      final request = RegisterRequest(
        name: nameController.text,
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
        passwordConfirmation: passwordConfirmationController.text,
        phone: phoneController.text,
        country: countryController.text,
        birthDate: birthDateController.text,
        address: addressController.text,
        gender: genderOptions[gender.value],
        preferredLanguage: preferredLanguage.value,
      );

      final response = await _authService.register(request);

      Get.snackbar(
        '¡Registro Exitoso!',
        response.message ?? 'Hemos enviado un enlace de verificación a tu correo. ¡Revisa tu bandeja de entrada!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      final box = GetStorage();
      final pendingRoute = box.read('pending_route');
      if (pendingRoute != null) {
        box.remove('pending_route');
        // Regresar a la pantalla anterior y luego navegar a la ruta pendiente
        Get.back(); // Regresar del registro
        Get.toNamed(pendingRoute);
        if (pendingRoute.startsWith('/services-capachica/detail/') || 
            pendingRoute.startsWith('/plan-detalle')) {
          Future.delayed(const Duration(milliseconds: 600), () {
            final cartController = Get.find<CartController>();
            Get.bottomSheet(
              CartBottomSheet(
                items: cartController.items,
                onEliminar: cartController.eliminarDelCarrito,
                onEditar: cartController.editarReserva,
                onConfirmar: ({String? notas, String metodoPago = 'efectivo'}) {
                  final request = {
                    'notas': notas,
                    'metodoPago': metodoPago,
                  };
                  cartController.confirmarReserva(request);
                },
              ),
              isScrollControlled: true,
              backgroundColor: Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            );
          });
        }
      } else {
        Get.back(); // Regresar del registro
        Get.toNamed('/home');
      }
    } catch (e) {
      Get.snackbar(
        'Error de Registro',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    phoneController.dispose();
    countryController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    super.onClose();
  }
} 