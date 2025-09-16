import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../services/auth_service.dart';

class GoogleSignInWebView extends StatefulWidget {
  const GoogleSignInWebView({super.key});

  @override
  GoogleSignInWebViewState createState() => GoogleSignInWebViewState();
}

class GoogleSignInWebViewState extends State<GoogleSignInWebView> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            // debug print opcional
            // print('[WebView] Page started: $url');
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            // print('[WebView] Page finished: $url');

            // Si la URL que llega ya incluye el token, capturamos y cerramos.
            if (_looksLikeCallbackWithToken(url)) {
              _handleAuthSuccess(url);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // print('[WebView] Nav to: ${request.url}');
            if (_looksLikeCallbackWithToken(request.url)) {
              _handleAuthSuccess(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadInitialUrl();
  }

  bool _looksLikeCallbackWithToken(String url) {
    // Relaja el match: el backend puede devolver token= o access_token=
    return url.contains('token=') || url.contains('access_token=');
  }

  Future<void> _loadInitialUrl() async {
    try {
      // Pide al backend la URL de inicio de sesión de Google
      final response = await _authProvider.getGoogleSignInUrl();

      if (response.statusCode == 200) {
        final body = response.body;
        // Se espera algo como { data: { url: "https://..." } } o similar
        String? authUrl;
        if (body is Map &&
            body['data'] is Map &&
            (body['data']['url'] is String)) {
          authUrl = (body['data']['url'] as String).replaceAll(r'\/', '/');
        } else if (body is Map && body['url'] is String) {
          // fallback por si el backend devuelve { url: ... }
          authUrl = (body['url'] as String).replaceAll(r'\/', '/');
        }

        if (authUrl != null && authUrl.isNotEmpty) {
          _webViewController.loadRequest(Uri.parse(authUrl));
          return;
        }
      }

      // Si llega aquí, la respuesta no es la esperada
      throw 'Respuesta inesperada del backend al solicitar la URL de Google (status: ${response.statusCode}).';
    } catch (e) {
      // print('[WebView] Error al cargar la URL inicial: $e');
      Get.snackbar(
        'Error de red',
        'No se pudo obtener la URL de autenticación de Google: $e',
        backgroundColor: const Color(0xFFFF9100),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      if (mounted) Get.back();
    }
  }

  Future<void> _handleAuthSuccess(String url) async {
    try {
      final uri = Uri.parse(url);

      // Captura desde query o fragment
      String? token = uri.queryParameters['token'] ??
          uri.queryParameters['access_token'];

      // Si vino en el fragment (implicit flow), intentar extraerlo manualmente
      if ((token == null || token.isEmpty) && uri.fragment.isNotEmpty) {
        final frag = uri.fragment; // e.g. access_token=...&token_type=...
        final parts = frag.split('&');
        for (final p in parts) {
          if (p.startsWith('access_token=')) {
            token = p.substring('access_token='.length);
            break;
          }
          if (p.startsWith('token=')) {
            token = p.substring('token='.length);
            break;
          }
        }
      }

      if (token != null && token.isNotEmpty) {
        // Verificar el token con el backend
        final response = await _authProvider.verifyGoogleToken(token);
        if (response.status.hasError) {
          throw 'Error en la autenticación: ${response.statusText}';
        }

        final loginResponse = response.body; // debe ser LoginResponse
        if (loginResponse?.token == null) {
          throw 'El servidor no devolvió un token de sesión válido.';
        }

        // Persistir sesión con AuthService
        await _authService.loginWithGoogleResponse(loginResponse!);

        Get.rawSnackbar(
          message: 'Inicio de sesión con Google exitoso',
          backgroundColor: const Color(0xFFFF9100),
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );

        if (mounted) {
          Get.back(); // cierra WebView
          Get.back(); // regresa a la pantalla anterior
        }
      }
    } catch (e) {
      // print('[GoogleSignInWebView] Error: $e');
      Get.snackbar(
        'Error',
        'No se pudo completar la autenticación: $e',
        backgroundColor: const Color(0xFFFF9100),
        colorText: Colors.white,
      );
      if (mounted) Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión con Google'),
        backgroundColor: const Color(0xFFFF9100),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFFF9100)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Cargando autenticación de Google...',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}