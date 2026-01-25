import 'package:flutter/material.dart';
import 'package:leodys/common/utils/no_params.dart';
import '../../../../common/mixins/usecase_mixin.dart';
import '../../../../common/theme/app_theme_manager.dart';
import '../../../../common/theme/app_themes.dart';
import '../../../../common/theme/theme_provider.dart';
import '../../domain/entities/settings.dart';

class SettingsViewModel extends ChangeNotifier implements ThemeProvider {
  final UseCaseMixin<Settings, NoParams> getSettingsUseCase;
  final UseCaseMixin<void, Settings> updateSettingsUseCase;
  final UseCaseMixin<void, NoParams> resetSettingsUseCase;
  final AppThemeManager? _themeManager;

  Settings _settings = const Settings();
  bool _isLoading = false;
  String? _errorMessage;

  Settings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constantes
  static const List<String> availableFonts = ['Roboto', 'OpenDyslexic', 'Lexend'];
  static const double minFontSize = 12.0;
  static const double maxFontSize = 20.0;
  static const double defaultFontSize = 16.0;
  static const double minLetterSpacing = 0.0;
  static const double maxLetterSpacing = 3.0;
  static const double minLineHeight = 1.0;
  static const double maxLineHeight = 2.5;

  SettingsViewModel({
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
    required this.resetSettingsUseCase,
    AppThemeManager? themeManager,
  }) : _themeManager = themeManager {
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
        _settings = const Settings();
      },
          (settings) => _settings = settings,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateFontFamily(String fontFamily) async {
    _settings = _settings.copyWith(fontFamily: fontFamily);
    await _saveSettings();
  }

  Future<void> updateFontSize(double fontSize) async {
    _settings = _settings.copyWith(fontSize: fontSize);
    await _saveSettings();
  }

  Future<void> updateThemeMode(String themeMode) async {
    _settings = _settings.copyWith(themeMode: themeMode);
    await _saveSettings();
  }

  Future<void> updateLetterSpacing(double letterSpacing) async {
    _settings = _settings.copyWith(letterSpacing: letterSpacing);
    await _saveSettings();
  }

  Future<void> updateLineHeight(double lineHeight) async {
    _settings = _settings.copyWith(lineHeight: lineHeight);
    await _saveSettings();
  }

  Future<void> toggleHighlightCurrentLine(bool value) async {
    _settings = _settings.copyWith(highlightCurrentLine: value);
    await _saveSettings();
  }

  Future<void> toggleTextToSpeech(bool value) async {
    _settings = _settings.copyWith(textToSpeechEnabled: value);
    await _saveSettings();
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

  Future<void> _saveSettings() async {
    final result = await updateSettingsUseCase(_settings);
    result.fold(
          (failure) => _errorMessage = failure.message,
          (_) => _errorMessage = null,
    );
    notifyListeners();
  }

  @override
  ThemeData getTheme() => getThemeData();

  ThemeData getThemeData() {
    final baseTheme = _getBaseTheme();
    return baseTheme.copyWith(
      textTheme: _applyTextSettings(baseTheme.textTheme),
    );
  }

  ThemeData _getBaseTheme() {
    return AppThemes.getThemeByKey(_settings.themeMode);
  }

  TextTheme _applyTextSettings(TextTheme base) {
    final factor = _settings.fontSize / defaultFontSize;
    return TextTheme(
      displayLarge: _scale(base.displayLarge, factor),
      displayMedium: _scale(base.displayMedium, factor),
      displaySmall: _scale(base.displaySmall, factor),
      headlineLarge: _scale(base.headlineLarge, factor),
      headlineMedium: _scale(base.headlineMedium, factor),
      headlineSmall: _scale(base.headlineSmall, factor),
      titleLarge: _scale(base.titleLarge, factor),
      titleMedium: _scale(base.titleMedium, factor),
      titleSmall: _scale(base.titleSmall, factor),
      bodyLarge: _scale(base.bodyLarge, factor),
      bodyMedium: _scale(base.bodyMedium, factor),
      bodySmall: _scale(base.bodySmall, factor),
      labelLarge: _scale(base.labelLarge, factor),
      labelMedium: _scale(base.labelMedium, factor),
      labelSmall: _scale(base.labelSmall, factor),
    );
  }

  TextStyle? _scale(TextStyle? style, double factor) {
    if (style == null) return null;
    return style.copyWith(
      fontFamily: _settings.fontFamily,
      fontSize: (style.fontSize ?? defaultFontSize) * factor,
      letterSpacing: (style.letterSpacing ?? 0.0) + _settings.letterSpacing,
      height: style.height != null
          ? style.height! * (_settings.lineHeight / 1.5)
          : _settings.lineHeight,
    );
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _themeManager?.onSettingsChanged();
  }
}