import 'package:leodys/features/accessibility/domain/entities/settings.dart';

class SettingsModel {
  final String fontFamily;
  final double fontSize;
  final String themeMode;
  final double letterSpacing;
  final double lineHeight;
  final bool highlightCurrentLine;
  final String colorBlindMode;
  final bool textToSpeechEnabled;

  const SettingsModel({
    required this.fontFamily,
    required this.fontSize,
    required this.themeMode,
    required this.letterSpacing,
    required this.lineHeight,
    required this.highlightCurrentLine,
    required this.colorBlindMode,
    required this.textToSpeechEnabled
  });

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'fontSize': fontSize,
    'themeMode': themeMode,
    'letterSpacing': letterSpacing,
    'lineHeight': lineHeight,
    'highlightCurrentLine': highlightCurrentLine,
    'colorBlindMode': colorBlindMode,
    'textToSpeechEnabled': textToSpeechEnabled,
  };

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      fontFamily: json['fontFamily'] ?? 'Roboto',
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
      themeMode: json['themeMode'] ?? 'light',
      letterSpacing: json['letterSpacing']?.toDouble() ?? 0.0,
      lineHeight: json['lineHeight']?.toDouble() ?? 1.5,
      highlightCurrentLine: json['highlightCurrentLine'] ?? false,
      colorBlindMode: json['colorBlindMode'] ?? 'none',
      textToSpeechEnabled: json['textToSpeechEnabled'] ?? false,
    );
  }

  factory SettingsModel.fromEntity(Settings entity) {
    return SettingsModel(
      fontFamily: entity.fontFamily,
      fontSize: entity.fontSize,
      themeMode: entity.themeMode,
      letterSpacing: entity.letterSpacing,
      lineHeight: entity.lineHeight,
      highlightCurrentLine: entity.highlightCurrentLine,
      colorBlindMode: entity.colorBlindMode,
      textToSpeechEnabled: entity.textToSpeechEnabled,
    );
  }

  Settings toEntity() {
    return Settings(
      fontFamily: fontFamily,
      fontSize: fontSize,
      themeMode: themeMode,
      letterSpacing: letterSpacing,
      lineHeight: lineHeight,
      highlightCurrentLine: highlightCurrentLine,
      colorBlindMode: colorBlindMode,
      textToSpeechEnabled: textToSpeechEnabled,
    );
  }
}