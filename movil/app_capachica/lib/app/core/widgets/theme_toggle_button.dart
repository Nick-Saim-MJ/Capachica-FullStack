import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RotationTransition(
              turns: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(controller.isDarkMode),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              onPressed: () {
                controller.toggleTheme();
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  controller.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey(controller.isDarkMode),
                  color: controller.isDarkMode 
                    ? Color(0xFF182447)
                    : Colors.white,
                  size: 26,
                ),
              ),
              tooltip: controller.isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: const CircleBorder(),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
        );
      },
    );
  }
} 