import 'package:flutter/material.dart';
import 'package:leodys/common/utils/no_params.dart';

import '../../../../common/mixins/usecase_mixin.dart';
import '../../../../common/theme/app_theme_manager.dart';
import '../../../../common/theme/theme_provider.dart';
import '../../domain/entities/settings.dart';

class SettingsViewModel extends ChangeNotifier implements ThemeProvider {
  final UseCaseMixin<Settings, NoParams> getSettingsUseCase;
  final UseCaseMixin<void, Settings> updateSettingsUseCase;
  final UseCaseMixin<void, NoParams> resetSettingsUseCase;

  Settings _settings = const Settings();
  bool _isLoading = false;
  String? _errorMessage;

  Settings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constantes
  static const List<String> availableFonts = [
    'Roboto',
    'OpenDyslexic',
    'Lexend',
    'Comic Sans MS',
    'Arial',
    'Verdana',
  ];

  static const double minFontSize = 12.0;
  static const double maxFontSize = 28.0;
  static const double defaultFontSize = 16.0;

  static const double minLetterSpacing = 0.0;
  static const double maxLetterSpacing = 5.0;

  static const double minLineHeight = 1.0;
  static const double maxLineHeight = 2.5;

  static const List<ColorBlindMode> colorBlindModes = [
    ColorBlindMode(
      value: 'none',
      label: 'Aucun',
      description: 'Vision normale',
    ),
    ColorBlindMode(
      value: 'protanopia',
      label: 'Protanopie',
      description: 'Difficulté rouge-vert',
    ),
    ColorBlindMode(
      value: 'deuteranopia',
      label: 'Deutéranopie',
      description: 'Difficulté rouge-vert',
    ),
    ColorBlindMode(
      value: 'tritanopia',
      label: 'Tritanopie',
      description: 'Difficulté bleu-jaune',
    ),
  ];

  final AppThemeManager? _themeManager;

  SettingsViewModel({
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
    required this.resetSettingsUseCase,
    AppThemeManager? themeManager,
  }) : _themeManager = themeManager {
    // S'enregistrer comme provider de thème
    _themeManager?.registerThemeProvider(this);
  }

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getSettingsUseCase(NoParams());

    result.fold(
          (failure) {
        _errorMessage = failure.message;
        _settings = const Settings(); // Fallback
      },
          (settings) {
        _settings = settings;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateFontFamily(String fontFamily) async {
    _settings = _settings.copyWith(fontFamily: fontFamily);
    final result = await updateSettingsUseCase(_settings);

    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _errorMessage = null,
    );

    notifyListeners();
  }

  Future<void> updateFontSize(double fontSize) async {
    _settings = _settings.copyWith(fontSize: fontSize);
    final result = await updateSettingsUseCase(_settings);

    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _errorMessage = null,
    );

    notifyListeners();
  }

  Future<void> updateThemeMode(String themeMode) async {
    _settings = _settings.copyWith(themeMode: themeMode);
    final result = await updateSettingsUseCase(_settings);

    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _errorMessage = null,
    );

    notifyListeners();
  }

  Future<void> updateLetterSpacing(double letterSpacing) async {
    _settings = _settings.copyWith(letterSpacing: letterSpacing);
    final result = await updateSettingsUseCase(_settings);

    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _errorMessage = null,
    );

    notifyListeners();
  }

  Future<void> updateLineHeight(double lineHeight) async {
    _settings = _settings.copyWith(lineHeight: lineHeight);
    final result = await updateSettingsUseCase(_settings);

    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _errorMessage = null,
    );

    notifyListeners();
  }

  Future<void> toggleHighlightCurrentLine(bool value) async {
    _settings = _settings.copyWith(highlightCurrentLine: value);
    final result = await updateSettingsUseCase(_settings);

    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _errorMessage = null,
    );

    notifyListeners();
  }

  Future<void> updateColorBlindMode(String colorBlindMode) async {
    _settings = _settings.copyWith(colorBlindMode: colorBlindMode);
    final result = await updateSettingsUseCase(_settings);

    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _errorMessage = null,
    );

    notifyListeners();
  }

  Future<void> toggleTextToSpeech(bool value) async {
    _settings = _settings.copyWith(textToSpeechEnabled: value);
    final result = await updateSettingsUseCase(_settings);

    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _errorMessage = null,
    );

    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    final result = await resetSettingsUseCase(NoParams());

    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) {
        _errorMessage = null;
        _settings = const Settings();
      },
    );

    notifyListeners();
  }

  // Méthodes pour obtenir les thèmes
  ThemeData getThemeData() {
    final baseTheme = _getBaseTheme();
    return _applyColorBlindMode(baseTheme);
  }

  ThemeData _getBaseTheme() {
    switch (_settings.themeMode) {
      case 'dark':
        return _createDarkTheme();
      case 'highContrast':
        return _createHighContrastTheme();
      default:
        return _createLightTheme();
    }
  }

  ThemeData _createLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Colors.white,
        background: Colors.grey[50]!,
      ),
      fontFamily: _settings.fontFamily,
      textTheme: _getScaledTextTheme(ThemeData.light().textTheme),
    );
  }

  ThemeData _createDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue[300]!,
        secondary: Colors.blueAccent[100]!,
        surface: Colors.grey[900]!,
        background: Colors.black,
      ),
      fontFamily: _settings.fontFamily,
      textTheme: _getScaledTextTheme(ThemeData.dark().textTheme),
    );
  }

  ThemeData _createHighContrastTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.yellow,
        surface: Colors.white,
        background: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onBackground: Colors.black,
      ),
      fontFamily: _settings.fontFamily,
      textTheme: _getScaledTextTheme(ThemeData.light().textTheme),
    );
  }

  TextTheme _getScaledTextTheme(TextTheme base) {
    final factor = _settings.fontSize / defaultFontSize;

    // CORRECTION: Ne pas utiliser apply() car certains styles n'ont pas de fontSize
    // Au lieu de cela, créer un nouveau TextTheme avec les styles modifiés
    return TextTheme(
      displayLarge: _applyTextStyle(base.displayLarge, factor),
      displayMedium: _applyTextStyle(base.displayMedium, factor),
      displaySmall: _applyTextStyle(base.displaySmall, factor),
      headlineLarge: _applyTextStyle(base.headlineLarge, factor),
      headlineMedium: _applyTextStyle(base.headlineMedium, factor),
      headlineSmall: _applyTextStyle(base.headlineSmall, factor),
      titleLarge: _applyTextStyle(base.titleLarge, factor),
      titleMedium: _applyTextStyle(base.titleMedium, factor),
      titleSmall: _applyTextStyle(base.titleSmall, factor),
      bodyLarge: _applyTextStyle(base.bodyLarge, factor),
      bodyMedium: _applyTextStyle(base.bodyMedium, factor),
      bodySmall: _applyTextStyle(base.bodySmall, factor),
      labelLarge: _applyTextStyle(base.labelLarge, factor),
      labelMedium: _applyTextStyle(base.labelMedium, factor),
      labelSmall: _applyTextStyle(base.labelSmall, factor),
    );
  }

  TextStyle? _applyTextStyle(TextStyle? style, double fontSizeFactor) {
    if (style == null) return null;

    return style.copyWith(
      fontFamily: _settings.fontFamily,
      fontSize: (style.fontSize ?? defaultFontSize) * fontSizeFactor,
      letterSpacing: (style.letterSpacing ?? 0.0) + _settings.letterSpacing,
      height: style.height != null
          ? style.height! * (_settings.lineHeight / 1.5)
          : _settings.lineHeight,
    );
  }

  ThemeData _applyColorBlindMode(ThemeData theme) {
    if (_settings.colorBlindMode == 'none') return theme;

    ColorScheme adjustedColorScheme;

    switch (_settings.colorBlindMode) {
      case 'protanopia':
        adjustedColorScheme = theme.colorScheme.copyWith(
          primary: Colors.blue[700],
          secondary: Colors.amber,
          error: Colors.blue[900],
        );
        break;
      case 'deuteranopia':
        adjustedColorScheme = theme.colorScheme.copyWith(
          primary: Colors.blue,
          secondary: Colors.orange,
          error: Colors.blue[800],
        );
        break;
      case 'tritanopia':
        adjustedColorScheme = theme.colorScheme.copyWith(
          primary: Colors.red,
          secondary: Colors.pink[200],
          error: Colors.red[900],
        );
        break;
      default:
        adjustedColorScheme = theme.colorScheme;
    }

    return theme.copyWith(colorScheme: adjustedColorScheme);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    // Notifier aussi le theme manager
    _themeManager?.onSettingsChanged();
  }

  @override
  ThemeData getTheme() {
    return getThemeData();
  }
}

class ColorBlindMode {
  final String value;
  final String label;
  final String description;

  const ColorBlindMode({
    required this.value,
    required this.label,
    required this.description,
  });
}