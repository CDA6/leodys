import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/accessibility/domain/entities/settings.dart';
import '../../features/accessibility/presentation/viewmodels/settings_viewmodel.dart';

/// Extension pour accéder facilement aux propriétés du thème et des paramètres d'accessibilité depuis un `BuildContext`.
///
/// Permet d'obtenir :
/// - Le `ColorScheme`.
/// - Les paramètres d'accessibilité (police, tailles, espacements).
/// - Un fallback sécurisé si `SettingsViewModel` n'est pas disponible. (cf. feature/accessibility)
extension ThemeContextExtension on BuildContext {
  /// ColorScheme du thème actuel
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// ThemeData complet
  ThemeData get theme => Theme.of(this);

  /// Settings d'accessibilité (lecture seule)
  Settings get accessibilitySettings {
    try {
      return watch<SettingsViewModel>().settings;
    } catch (e) {
      return const Settings();
    }
  }

  /// Police de caractères actuelle
  String get fontFamily => accessibilitySettings.fontFamily;

  /// Taille des textes
  double get baseFontSize => accessibilitySettings.fontSize;

  /// Taille des titres
  double get titleFontSize => accessibilitySettings.fontSize * 1.2;

  /// Espacement entre les lettres
  double get letterSpacing => accessibilitySettings.letterSpacing;

  /// Hauteur de ligne
  double get lineHeight => accessibilitySettings.lineHeight;

  /// Mode de thème actuel
  String get themeMode => accessibilitySettings.themeMode;
}
