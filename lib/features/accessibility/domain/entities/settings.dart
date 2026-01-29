class Settings {
  final String fontFamily;
  final double fontSize;
  final String themeMode;
  final double letterSpacing;
  final double lineHeight;
  final bool highlightCurrentLine;
  final String colorBlindMode;
  final bool textToSpeechEnabled;

  const Settings({
    this.fontFamily = 'Roboto',
    this.fontSize = 16.0,
    this.themeMode = 'light',
    this.letterSpacing = 0.0,
    this.lineHeight = 1.5,
    this.highlightCurrentLine = false,
    this.colorBlindMode = 'none',
    this.textToSpeechEnabled = false,
  });

  Settings copyWith({
    String? fontFamily,
    double? fontSize,
    String? themeMode,
    double? letterSpacing,
    double? lineHeight,
    bool? highlightCurrentLine,
    String? colorBlindMode,
    bool? textToSpeechEnabled,
  }) {
    return Settings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      themeMode: themeMode ?? this.themeMode,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      highlightCurrentLine: highlightCurrentLine ?? this.highlightCurrentLine,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      textToSpeechEnabled: textToSpeechEnabled ?? this.textToSpeechEnabled,
    );
  }
}