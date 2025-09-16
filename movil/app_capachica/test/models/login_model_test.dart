import 'package:flutter_test/flutter_test.dart';
import 'package:app_capachica/app/data/models/login_model.dart';

void main() {
  group('LoginModel Tests', () {
    test('LoginRequest should serialize to JSON correctly', () {
      // Arrange
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      // Act
      final json = request.toJson();

      // Assert
      expect(json['email'], equals('test@example.com'));
      expect(json['password'], equals('password123'));
    });

    test('RegisterRequest should serialize to Map correctly', () {
      // Arrange
      final request = RegisterRequest(
        name: 'Juan Pérez',
        email: 'juan@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
        phone: '+51987654321',
        country: 'Perú',
      );

      // Act
      final map = request.toMap();

      // Assert
      expect(map['name'], equals('Juan Pérez'));
      expect(map['email'], equals('juan@example.com'));
      expect(map['password'], equals('password123'));
      expect(map['password_confirmation'], equals('password123'));
      expect(map['phone'], equals('+51987654321'));
      expect(map['country'], equals('Perú'));
    });

    test('User should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Juan Pérez',
        'email': 'juan@example.com',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, equals(1));
      expect(user.name, equals('Juan Pérez'));
      expect(user.email, equals('juan@example.com'));
    });

    test('User should serialize to JSON correctly', () {
      // Arrange
      final user = User(
        id: 1,
        name: 'Juan Pérez',
        email: 'juan@example.com',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], equals(1));
      expect(json['name'], equals('Juan Pérez'));
      expect(json['email'], equals('juan@example.com'));
    });

    test('AuthResponse should deserialize from JSON with token correctly', () {
      // Arrange
      final json = {
        'token': 'test_token_123',
        'message': 'Login exitoso',
        'user': {
          'id': 1,
          'name': 'Juan Pérez',
          'email': 'juan@example.com',
        },
        'success': true,
      };

      // Act
      final authResponse = AuthResponse.fromJson(json);

      // Assert
      expect(authResponse.token, equals('test_token_123'));
      expect(authResponse.message, equals('Login exitoso'));
      expect(authResponse.success, equals(true));
      expect(authResponse.user?.id, equals(1));
      expect(authResponse.user?.name, equals('Juan Pérez'));
      expect(authResponse.user?.email, equals('juan@example.com'));
    });

    test('AuthResponse should deserialize from JSON with access_token correctly', () {
      // Arrange
      final json = {
        'access_token': 'test_token_456',
        'message': 'Login exitoso',
        'user': {
          'id': 2,
          'name': 'María García',
          'email': 'maria@example.com',
        },
      };

      // Act
      final authResponse = AuthResponse.fromJson(json);

      // Assert
      expect(authResponse.token, equals('test_token_456'));
      expect(authResponse.message, equals('Login exitoso'));
      expect(authResponse.success, equals(true));
      expect(authResponse.user?.id, equals(2));
      expect(authResponse.user?.name, equals('María García'));
      expect(authResponse.user?.email, equals('maria@example.com'));
    });

    test('AuthResponse should deserialize from JSON with data wrapper correctly', () {
      // Arrange
      final json = {
        'data': {
          'token': 'test_token_789',
          'message': 'Login exitoso',
          'user': {
            'id': 3,
            'name': 'Carlos López',
            'email': 'carlos@example.com',
          },
        },
        'success': true,
      };

      // Act
      final authResponse = AuthResponse.fromJson(json);

      // Assert
      expect(authResponse.token, equals('test_token_789'));
      expect(authResponse.message, equals('Login exitoso'));
      expect(authResponse.success, equals(true));
      expect(authResponse.user?.id, equals(3));
      expect(authResponse.user?.name, equals('Carlos López'));
      expect(authResponse.user?.email, equals('carlos@example.com'));
    });

    test('AuthResponse should handle errors correctly', () {
      // Arrange
      final json = {
        'message': 'Credenciales inválidas',
        'errors': {
          'email': ['El email es requerido'],
          'password': ['La contraseña es requerida'],
        },
        'success': false,
      };

      // Act
      final authResponse = AuthResponse.fromJson(json);

      // Assert
      expect(authResponse.token, isNull);
      expect(authResponse.message, equals('Credenciales inválidas'));
      expect(authResponse.success, equals(false));
      expect(authResponse.user, isNull);
      expect(authResponse.errors, isNotNull);
    });

    test('ForgotPasswordRequest should serialize to JSON correctly', () {
      // Arrange
      final request = ForgotPasswordRequest(email: 'test@example.com');

      // Act
      final json = request.toJson();

      // Assert
      expect(json['email'], equals('test@example.com'));
    });

    test('ResetPasswordRequest should serialize to JSON correctly', () {
      // Arrange
      final request = ResetPasswordRequest(
        email: 'test@example.com',
        password: 'newpassword123',
        passwordConfirmation: 'newpassword123',
        token: 'reset_token_123',
      );

      // Act
      final json = request.toJson();

      // Assert
      expect(json['email'], equals('test@example.com'));
      expect(json['password'], equals('newpassword123'));
      expect(json['password_confirmation'], equals('newpassword123'));
      expect(json['token'], equals('reset_token_123'));
    });
  });
}
