class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String? phone;
  final String? country;
  final String? birthDate;
  final String? address;
  final String? gender;
  final String? preferredLanguage;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.phone,
    this.country,
    this.birthDate,
    this.address,
    this.gender,
    this.preferredLanguage,
  });

  Map<String, String> toMap() {
    final map = <String, String>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    if (phone != null) map['phone'] = phone!;
    if (country != null) map['country'] = country!;
    if (birthDate != null) map['birth_date'] = birthDate!;
    if (address != null) map['address'] = address!;
    if (gender != null) map['gender'] = gender!;
    if (preferredLanguage != null) map['preferred_language'] = preferredLanguage!;
    return map;
  }
}

class LoginResponse {
  final String? token;
  final String? message;
  final User? user;

  LoginResponse({this.token, this.message, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'],
    message: json['message'],
    user: json['user'] != null ? User.fromJson(json['user']) : null,
  );

  Map<String, dynamic> toJson() => {
    'token': token,
    'message': message,
    'user': user?.toJson(),
  };
}

class User {
  final int id;
  final String? name;
  final String email;

  User({required this.id, this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}

class AuthResponse {
  final String? token;
  final String? message;
  final User? user;
  final bool success;
  final Map<String, dynamic>? errors;

  AuthResponse({
    this.token,
    this.message,
    this.user,
    required this.success,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('[AuthResponse] Parsing JSON: $json');
    
    // Manejar diferentes formatos de respuesta del backend Laravel
    String? token;
    String? message;
    User? user;
    bool success = false;
    Map<String, dynamic>? errors;

    // Buscar token en diferentes ubicaciones posibles
    token = json['token'] ?? 
            json['access_token'] ?? 
            json['data']?['token'] ?? 
            json['data']?['access_token'];

    // Buscar mensaje en diferentes ubicaciones posibles
    message = json['message'] ?? 
              json['msg'] ?? 
              json['data']?['message'] ?? 
              json['data']?['msg'];

    // Buscar usuario en diferentes ubicaciones posibles
    if (json['user'] != null) {
      user = User.fromJson(json['user']);
    } else if (json['data']?['user'] != null) {
      user = User.fromJson(json['data']['user']);
    }

    // Determinar si fue exitoso
    success = json['success'] ?? 
              json['status'] == 'success' || 
              json['status'] == 'ok' || 
              token != null;

    // Buscar errores
    errors = json['errors'] ?? json['data']?['errors'];

    print('[AuthResponse] Parsed values:');
    print('[AuthResponse] - token: $token');
    print('[AuthResponse] - message: $message');
    print('[AuthResponse] - user: ${user?.toJson()}');
    print('[AuthResponse] - success: $success');
    print('[AuthResponse] - errors: $errors');

    return AuthResponse(
      token: token,
      message: message,
      user: user,
      success: success,
      errors: errors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'message': message,
      'user': user?.toJson(),
      'success': success,
      'errors': errors,
    };
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}

class ResetPasswordRequest {
  final String email;
  final String password;
  final String passwordConfirmation;
  final String token;

  ResetPasswordRequest({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'password_confirmation': passwordConfirmation,
    'token': token,
  };
}