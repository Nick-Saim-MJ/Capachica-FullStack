import 'package:aplicativo_capachica/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aplicativo_capachica/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;


  @override
  Widget build(BuildContext context) {
    // Para un look más limpio y empresarial, a menudo se omite el AppBar en el login.
    return Scaffold(
      // El color de fondo de Scaffold no es tan importante ya que el Stack lo cubre
      backgroundColor: Colors.blueGrey[50],
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is AuthEmailNotVerified) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verifica tu correo antes de iniciar sesión.')));
          }

          // ✅ CORRECCIÓN: Si el login es exitoso, cierra esta pantalla
          if (state is AuthAuthenticated) {
            // Usamos pushReplacement para reemplazar la LoginPage en el stack
            // de navegación con la HomePage, asegurando que AuthGate tome el control.
            Navigator.of(context).pushReplacementNamed('/');

            // Alternativamente, puedes forzar la navegación directa a HomePage si no usas AuthGate para la transición:
            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => const HomePage()));
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;

          // Usamos un Stack para colocar elementos de fondo detrás del formulario
          return Stack(
            children: [
              // 1. Elemento de Fondo (IMAGEN DE FONDO LOCAL)
              Positioned.fill(
                child: ColorFiltered(
                  // Añadimos un filtro oscuro para mejorar la legibilidad del texto blanco
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    // ** RUTA DE IMAGEN LOCAL: Asegúrate de que esta ruta sea correcta **
                    'assets/images/fondo_login.jpg',
                    fit: BoxFit.cover,
                    // Usar un color de fallback en caso de que la imagen no se encuentre
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.blue[800],
                      child: const Center(child: Text('Error cargando asset local', style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
              ),

              // 2. Título Flotante (Opcional, similar al estilo de la foto de Capachica)
              const Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'ACCESO CORPORATIVO',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(blurRadius: 5.0, color: Colors.black54, offset: Offset(0, 2))
                          ] // Sombra para mejor contraste
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gestión de Turismo Capachica',
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

              // 3. Formulario Centrado (envuelto en SingleChildScrollView)
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 200),
                  child: Card(
                    elevation: 10, // Mantenemos la elevación para darle profundidad
                    // *** Tarjeta casi transparente (0.05) ***
                    color: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bordes más redondeados
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Título y Subtítulo - Cambiamos color para mejor contraste
                            Text(
                              'Bienvenido',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Color blanco para resaltar sobre el fondo oscuro
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ingresa tus credenciales',
                              style: TextStyle(color: Colors.white70, fontSize: 14), // Color gris claro
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Campo Correo
                            TextFormField(
                              controller: _email,
                              decoration: InputDecoration(
                                labelText: 'Correo Electrónico',
                                // *** CORRECCIÓN: Estilo de etiqueta al hacer foco ***
                                labelStyle: TextStyle(color: Colors.blueGrey[900]),
                                prefixIcon: const Icon(Icons.email_outlined, color: Colors.blueGrey),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: Colors.white, // Mantenemos blanco para mejor legibilidad del input
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || !v.contains('@')) ? 'Correo inválido' : null,
                            ),
                            const SizedBox(height: 16),

                            // Campo Contraseña
                            TextFormField(
                              controller: _password,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                // *** CORRECCIÓN: Estilo de etiqueta al hacer foco ***
                                labelStyle: TextStyle(color: Colors.blueGrey[900]),
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueGrey),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: Colors.white, // Mantenemos blanco para mejor legibilidad del input
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.blueGrey),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              obscureText: _obscure,
                              validator: (v) => (v == null || v.length < 8) ? 'La contraseña debe tener al menos 8 caracteres' : null,
                            ),
                            const SizedBox(height: 40),

                            // Botón Ingresar
                            ElevatedButton(
                              onPressed: loading ? null : () {
                                if (_form.currentState!.validate()) {
                                  context.read<AuthCubit>().login(_email.text.trim(), _password.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[800],
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                              ),
                              child: Text(
                                loading ? 'INGRESANDO...' : 'INGRESAR',
                                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Botón de Navegación a Registro
                            TextButton(
                              onPressed: loading ? null : () {
                                final cubit = context.read<AuthCubit>();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: cubit,
                                      child: const RegisterPage(),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                '¿No tienes cuenta? Regístrate aquí',
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
}