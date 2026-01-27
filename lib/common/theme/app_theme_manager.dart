import 'package:flutter/material.dart';
import 'app_themes.dart';
import 'theme_provider.dart';

class AppThemeManager extends ChangeNotifier {
  ThemeProvider? _themeProvider;
  ThemeData _currentTheme = AppThemes.lightTheme;

  static final AppThemeManager _instance = AppThemeManager._internal();

  factory AppThemeManager() {
    return _instance;
  }

  AppThemeManager._internal();

  ThemeData get currentTheme => _currentTheme;

  /// Enregistre un provider de thème
  void registerThemeProvider(ThemeProvider provider) {
    _themeProvider = provider;
    _updateTheme();
  }

  /// Met à jour le thème depuis le provider enregistré
  void _updateTheme() {
    if (_themeProvider != null) {
      try {
        final newTheme = _themeProvider!.getTheme();
        if (_currentTheme != newTheme) {
          _currentTheme = newTheme;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('❌ Erreur lors de la récupération du thème: $e');
      }
    }
  }

  /// Appelé quand les settings changent
  void onSettingsChanged() {
    _updateTheme();
  }
}