import 'package:flutter/material.dart';
import 'app_themes.dart';
import 'theme_provider.dart';

class AppThemeManager extends ChangeNotifier {
  ThemeProvider? _themeProvider;
  ThemeData _currentTheme = AppThemes.lightTheme;

  ThemeData get currentTheme => _currentTheme;

  /// Enregistre un provider de thème
  void registerThemeProvider(ThemeProvider provider) {
    _themeProvider = provider;
    _updateTheme();
  }

  /// Met à jour le thème depuis le provider enregistré
  void _updateTheme() {
    if (_themeProvider != null) {
      final newTheme = _themeProvider!.getTheme();
      if (_currentTheme != newTheme) {
        _currentTheme = newTheme;
        notifyListeners();
      }
    }
  }

  /// Appelé quand les settings changent
  void onSettingsChanged() {
    _updateTheme();
  }
}