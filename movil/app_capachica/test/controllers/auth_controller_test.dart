import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:app_capachica/app/modules/login/controllers/login_controller.dart';
import 'package:app_capachica/app/services/auth_service.dart';
import 'package:app_capachica/app/data/models/login_model.dart';

void main() {
  group('LoginController Tests', () {
    late LoginController loginController;
    late AuthService authService;

    setUp(() async {
      Get.testMode = true;
      await GetStorage.init();

      authService = AuthService();
      Get.put<AuthService>(authService);

      loginController = LoginController();
      Get.put<LoginController>(loginController);
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize with correct default values', () {
      expect(loginController.isLoading.value, false);
      expect(loginController.isPasswordVisible.value, false);
      expect(loginController.emailController.text, '');
      expect(loginController.passwordController.text, '');
    });

    test('should toggle password visibility correctly', () {
      final initial = loginController.isPasswordVisible.value;
      loginController.togglePasswordVisibility();
      expect(loginController.isPasswordVisible.value, !initial);
    });

    test('should validate form correctly', () {
      loginController.emailController.text = 'test@example.com';
      loginController.passwordController.text = 'password123';
      final isValid = loginController.formKey.currentState!.validate();
      expect(isValid, true);
    });

    test('should not validate form with empty email', () {
      loginController.emailController.text = '';
      loginController.passwordController.text = 'password123';
      final isValid = loginController.formKey.currentState!.validate();
      expect(isValid, false);
    });

    test('should not validate form with invalid email', () {
      loginController.emailController.text = 'invalid-email';
      loginController.passwordController.text = 'password123';
      final isValid = loginController.formKey.currentState!.validate();
      expect(isValid, false);
    });

    test('should not validate form with empty password', () {
      loginController.emailController.text = 'test@example.com';
      loginController.passwordController.text = '';
      final isValid = loginController.formKey.currentState!.validate();
      expect(isValid, false);
    });

    test('should not validate form with short password', () {
      loginController.emailController.text = 'test@example.com';
      loginController.passwordController.text = '123';
      final isValid = loginController.formKey.currentState!.validate();
      expect(isValid, false);
    });

    test('onClose disposes controllers without throwing', () {
      expect(() => loginController.onClose(), returnsNormally);
    });
  });

  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() async {
      Get.testMode = true;
      await GetStorage.init();
      authService = AuthService();
      Get.put<AuthService>(authService);
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize with no user logged in', () {
      expect(authService.isLoggedIn, false);
      expect(authService.isAuthenticated, false);
      expect(authService.token.value, isNull);
      expect(authService.currentUser.value, isNull);
    });

    test('should save and retrieve auth data via public API', () async {
      // Construimos un LoginResponse sin el campo "success"
      final loginResponse = LoginResponse(
        token: 'test_token_123',
        message: 'Login exitoso',
        user: User(id: 1, name: 'Juan Pérez', email: 'juan@example.com'),
      );

      await authService.loginWithGoogleResponse(loginResponse);

      expect(authService.token.value, 'test_token_123');
      expect(authService.currentUser.value?.id, 1);
      expect(authService.currentUser.value?.name, 'Juan Pérez');
      expect(authService.currentUser.value?.email, 'juan@example.com');
      expect(authService.isLoggedIn, true);
      expect(authService.isAuthenticated, true);
    });

    test('should clear auth data via logout()', () async {
      await authService.loginWithGoogleResponse(
        LoginResponse(
          token: 'test_token_123',
          message: 'Login exitoso',
          user: User(id: 1, name: 'Juan Pérez', email: 'juan@example.com'),
        ),
      );

      await authService.logout();

      expect(authService.token.value, isNull);
      expect(authService.currentUser.value, isNull);
      expect(authService.isLoggedIn, false);
      expect(authService.isAuthenticated, false);
    });
  });
}