import 'package:flutter/material.dart';

class ThemeConfig {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final ThemeData themeData;

  const ThemeConfig({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.themeData,
  });
}

class AppThemes {
  AppThemes._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.blue, // texte, icônes, éléments principaux
        onPrimary: Colors.white,

        primaryContainer: Colors.blue, // conteneurs, boutons
        onPrimaryContainer: Colors.white,
        onSecondaryContainer: const Color(0xFFEBEBEB),

        secondary: const Color(0xFF191919), // éléments secondaires
        onSecondary: const Color(0xFFB4B4B4),

        surface: const Color(0xFFF5F5F5), // surfaces principales
        onSurface: Colors.black,

        surfaceContainerHighest: Colors.white, // surfaces supérieures,
        onSurfaceVariant: const Color(0xFF0F0F0F),

        outline: const Color(0xFFC8C8C8),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Colors.grey[900]!,
      ),
    );
  }

  static ThemeData get highContrastTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.white, // texte, icônes, éléments principaux
        onPrimary: Colors.black,

        primaryContainer: const Color(0xFF141414), // conteneurs, boutons
        onPrimaryContainer: Colors.white,
        onSecondaryContainer: const Color(0xFFEBEBEB),

        secondary: const Color(0xFFB4B4B4), // éléments secondaires
        onSecondary: const Color(0xFF0F0F0F),

        surface: Colors.black, // surfaces principales
        onSurface: Colors.white,

        surfaceContainerHighest: const Color(0xFF141414), // surfaces supérieures,
        onSurfaceVariant: Colors.white,

        outline: const Color(0xFF666666),
      ),
    );
  }

  /// Liste de tous les thèmes disponibles
  static final List<ThemeConfig> availableThemes = [
    ThemeConfig(
      key: 'light',
      title: 'Clair',
      description: 'Fond blanc, idéal en journée',
      icon: Icons.light_mode,
      themeData: lightTheme,
    ),
    ThemeConfig(
      key: 'dark',
      title: 'Sombre',
      description: 'Réduit la fatigue oculaire',
      icon: Icons.dark_mode,
      themeData: darkTheme,
    ),
    ThemeConfig(
      key: 'highContrast',
      title: 'Contraste élevé',
      description: 'Noir sur blanc pour une lisibilité maximale',
      icon: Icons.contrast,
      themeData: highContrastTheme,
    ),
  ];

  /// Récupère un thème par sa clé
  static ThemeData getThemeByKey(String key) {
    return availableThemes
        .firstWhere((theme) => theme.key == key,
        orElse: () => availableThemes.first).themeData;
  }
}