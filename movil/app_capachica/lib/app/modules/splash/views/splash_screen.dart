import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/cart_bottom_sheet.dart';
import '../../../core/controllers/cart_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _heartbeatController;
  late AnimationController _fastSpinController;
  late AnimationController _exitAnimationController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoPulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _progressFadeAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _fastSpinAnimation;
  late Animation<double> _exitFadeAnimation;

  late SplashController controller;
  bool _showIntenseAnimation = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SplashController>();
    _initAnimations();
    _startIntenseAnimationTimer();
  }

  void _startIntenseAnimationTimer() {
    // Inicia la animación intensa después de 2.5 segundos
    Future.delayed(Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showIntenseAnimation = true;
        });
        _startIntenseAnimations();
      }
    });

    // Inicia la animación de salida 600ms antes de la navegación (a los 2.4 segundos)
    // Esto crea una transición más suave sin espacios oscuros
    Future.delayed(Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          _isExiting = true;
        });
        _exitAnimationController.forward();
      }
    });
  }

  void _startIntenseAnimations() {
    // Animación de corazón (bombeo)
    _heartbeatController.repeat();

    // Rotación rápida después de un pequeño delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _fastSpinController.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _isExiting ? _exitFadeAnimation.value : 1.0,
          child: Scaffold(
            backgroundColor: Color(0xFFFF6600), // Naranja vivo de fondo
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Sin iconos de carrito ni modo noche/día
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF6600), // Naranja vivo
                    Color(0xFFFF7700), // Naranja vivo ligeramente más claro
                    Color(0xFFFF8800), // Naranja vivo más claro
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo con animaciones múltiples
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _logoAnimationController,
                        _fadeAnimationController,
                        _heartbeatController,
                        _fastSpinController,
                      ]),
                      builder: (context, child) {
                        double heartbeatScale = _showIntenseAnimation ? _heartbeatAnimation.value : 1.0;
                        double rotationAngle = _showIntenseAnimation ? _fastSpinAnimation.value : _logoRotateAnimation.value;

                        return Transform.scale(
                          scale: _logoScaleAnimation.value * _logoPulseAnimation.value * heartbeatScale,
                          child: Transform.rotate(
                            angle: rotationAngle,
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 50),

                    // Indicador de carga con animación
                    AnimatedBuilder(
                      animation: _progressAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _progressFadeAnimation.value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(_progressFadeAnimation.value),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 40),

                    // Textos con animación de deslizamiento
                    AnimatedBuilder(
                      animation: _textAnimationController,
                      builder: (context, child) {
                        return Column(
                          children: [
                            // Texto principal
                            Transform.translate(
                              offset: _textSlideAnimation.value,
                              child: Opacity(
                                opacity: _textFadeAnimation.value,
                                child: Text(
                                  'Bienvenido a Capachica',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3 * _textFadeAnimation.value),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            // Texto secundario
                            Transform.translate(
                              offset: Offset(0, 20 * (1 - _textFadeAnimation.value)),
                              child: Opacity(
                                opacity: _textFadeAnimation.value * 0.8,
                                child: Text(
                                  'Cargando...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 60),

                    // Indicadores de puntos animados
                    AnimatedBuilder(
                      animation: _progressAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _progressFadeAnimation.value * 0.6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                      0.3 + (0.7 * (((_progressAnimationController.value * 3) - index).clamp(0.0, 1.0)))
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _initAnimations() {
    _logoAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _textAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Nuevos controladores para animaciones intensas
    _heartbeatController = AnimationController(
      duration: Duration(milliseconds: 600), // Latido rápido como corazón
      vsync: this,
    );
    _fastSpinController = AnimationController(
      duration: Duration(milliseconds: 200), // Rotación muy rápida
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _logoPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _logoRotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Animación de latido intenso como corazón
    _heartbeatAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _heartbeatController,
        curve: Curves.easeInOut,
      ),
    );

    // Animación de rotación rápida
    _fastSpinAnimation = Tween<double>(begin: 0.0, end: 6.28319).animate( // 2π para rotación completa
      CurvedAnimation(
        parent: _fastSpinController,
        curve: Curves.linear,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeIn,
      ),
    );
    _textSlideAnimation = Tween<Offset>(begin: Offset(0, 30), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeIn,
      ),
    );
    _progressFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _exitAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _logoAnimationController.forward().then((_) => _startPulseAnimation());
    });
    Future.delayed(Duration(milliseconds: 600), () {
      _textAnimationController.forward();
    });
  }

  void _startPulseAnimation() {
    _logoAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    _textAnimationController.dispose();
    _progressAnimationController.dispose();
    _heartbeatController.dispose();
    _fastSpinController.dispose();
    _exitAnimationController.dispose();
    super.dispose();
  }
}