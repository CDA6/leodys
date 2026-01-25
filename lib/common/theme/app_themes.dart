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
        primaryContainer: Colors.blue,
        primary: Colors.blue,
        secondary: Colors.grey[900]!,
        tertiary: Colors.grey[300]!,
        surface: Color(0xFFF5F5F5),
        onSurface: Colors.white,
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
        primary: const Color(0xFFFFFFFF), // Noir pur (texte, icônes, éléments principaux)
        onPrimary: const Color(0xFF000000), // Blanc pur (texte/icônes SUR un fond `primary`)

        primaryContainer: const Color(0xFF0A0A0A), // Noir très foncé (conteneurs, boutons)
        onPrimaryContainer: const Color(0xFFFFFFFF), // Blanc (texte/icônes SUR `primaryContainer`)

        secondary: const Color(0xFFB4B4B4), // Gris foncé (éléments secondaires)
        onSecondary: const Color(0xFF232323), // Blanc (texte/icônes SUR `secondary`)

        surface: const Color(0xFF000000), // Blanc (fond des cartes, surfaces principales)
        onSurface: const Color(0xFF0A0A0A), // Noir (texte/icônes SUR `surface`)

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