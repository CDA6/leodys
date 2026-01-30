import 'package:flutter/material.dart';

import 'state_color_extension.dart';

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

  static const Color blue70 = Color(0xFF7D8FE8);
  static const Color blue60 = Color(0xFF5269E0);
  static const Color blue50 = Color(0xFF2644D9);
  static const Color blue40 = Color(0xFF1F36AD);
  static const Color blue30 = Color(0xFF172982);
  static const Color blue20 = Color(0xFF0F1B57);
  static const Color blue10 = Color(0xFF080E2B);

  static const Color grey98 = Color(0xFFFAFAFA);
  static const Color grey96 = Color(0xFFF0F0F0);
  static const Color grey94 = Color(0xFFEBEBEB);
  static const Color grey92 = Color(0xFFE6E6E6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: blue40, // texte, icônes, éléments principaux
        onPrimary: Colors.white,

        primaryContainer: blue40, // conteneurs, boutons
        onPrimaryContainer: Colors.white,
        onSecondaryContainer: grey98,

        secondary: const Color(0xFF191919), // éléments secondaires
        onSecondary: grey96,

        surface: grey96, // surfaces principales
        onSurface: Colors.black,

        surfaceContainerHighest: Colors.white, // surfaces supérieures,
        onSurfaceVariant: const Color(0xFF0F0F0F),

        outline: grey92,
      ),
      extensions: <ThemeExtension<dynamic>>[
        StateColorScheme.light,
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: blue60, // texte, icônes, éléments principaux
        onPrimary: Colors.white,

        primaryContainer: blue60, // conteneurs, boutons
        onPrimaryContainer: Colors.white,
        onSecondaryContainer: const Color(0xFFEBEBEB),

        secondary: const Color(0xFFB4B4B4), // éléments secondaires
        onSecondary: const Color(0xFF0F0F0F),

        surface: const Color(0xFF0A0A0A), // surfaces principales
        onSurface: Colors.white,

        surfaceContainerHighest: const Color(0xFF1E1E1E), // surfaces supérieures,
        onSurfaceVariant: Colors.white,

        outline: const Color(0xFF666666),
      ),
      extensions: <ThemeExtension<dynamic>>[
        StateColorScheme.dark,
      ],
    );
  }

  static ThemeData get highContrastTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Colors.white, // texte, icônes, éléments principaux
        onPrimary: Colors.black,

        primaryContainer: Colors.white, // conteneurs, boutons
        onPrimaryContainer: Colors.black,
        onSecondaryContainer: const Color(0xFF141414),

        secondary: const Color(0xFFB4B4B4), // éléments secondaires
        onSecondary: const Color(0xFF0F0F0F),

        surface: Colors.black, // surfaces principales
        onSurface: Colors.white,

        surfaceContainerHighest: const Color(0xFF141414), // surfaces supérieures,
        onSurfaceVariant: Colors.white,

        outline: const Color(0xFF666666),
      ),
      extensions: <ThemeExtension<dynamic>>[
        StateColorScheme.highContrast,
      ],
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