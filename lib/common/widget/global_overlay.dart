import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';

import '../../features/accessibility/presentation/screens/settings_screen.dart';
import '../../main.dart';
import '../pages/home/presentation/screens/home_page.dart';

class GlobalOverlay extends StatefulWidget {
  final Widget child;

  const GlobalOverlay({super.key, required this.child});

  @override
  State<GlobalOverlay> createState() => _GlobalFloatingButtonState();
}

class _GlobalFloatingButtonState extends State<GlobalOverlay> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // L'application principale
        GestureDetector(
          onTap: _closeMenu,
          child: widget.child,
        ),

        // Fond noir transparent
        if (_isMenuOpen)
          GestureDetector(
            onTap: _closeMenu,
            child: Container(
              color: Colors.black.withValues(alpha: 0.9),
              width: double.infinity,
              height: double.infinity,
            ),
          ),

        // Le menu flottant centré
        if (_isMenuOpen)
          Center(
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    // Items du menu
                    _buildMenuItem(
                      icon: Icons.home,
                      label: 'Accueil',
                      labelColor: context.colorScheme.onPrimaryContainer,
                      bgColor: context.colorScheme.primaryContainer,
                      onTap: () {
                        _closeMenu();
                        navigatorKey.currentState!.pushNamedAndRemoveUntil(
                          HomePage.route,
                              (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      icon: Icons.settings,
                      label: 'Préférences',
                      labelColor: context.colorScheme.onPrimaryContainer,
                      bgColor: context.colorScheme.primaryContainer,
                      onTap: () {
                        _closeMenu();
                        navigatorKey.currentState!.pushNamedAndRemoveUntil(
                          SettingsScreen.route,
                              (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      icon: Icons.close,
                      label: 'Fermer',
                      labelColor: context.colorScheme.onSurfaceVariant,
                      bgColor: Colors.transparent,
                      onTap: () {
                        _closeMenu();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Le bouton flottant principal
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _toggleMenu,
            backgroundColor: context.colorScheme.primary,
            child: AnimatedRotation(
              turns: _isMenuOpen ? 0.4 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.settings,
                color: context.colorScheme.onPrimary,
                size: 36,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color labelColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: labelColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
