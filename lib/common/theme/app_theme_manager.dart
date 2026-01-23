
import 'package:flutter/material.dart';
import 'theme_provider.dart';

class AppThemeManager extends ChangeNotifier {
  ThemeProvider? _themeProvider;
  ThemeData _currentTheme = _defaultTheme();

  ThemeData get currentTheme => _currentTheme;

  /// Enregistre un provider de thème (appelé par la feature accessibility)
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

  static ThemeData _defaultTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Colors.white,
        background: Colors.grey[50]!,
      ),
    );
  }
}