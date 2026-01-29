import 'package:flutter/material.dart';

/// **AppColorsContext**
/// Extension pour accéder facilement aux couleurs d'état depuis un `BuildContext`.
extension StateColorExtension on BuildContext {
  StateColorScheme get stateColors {
    return Theme.of(this).extension<StateColorScheme>() ?? StateColorScheme.light;
  }
}

/// **AppColorScheme**
/// Thème Flutter pour gérer les couleurs d'état (succès, erreur, warning).
class StateColorScheme extends ThemeExtension<StateColorScheme> {
  final Color error;
  final Color onError;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;

  static const Color success30 = Color(0xFF267348);
  static const Color success40 = Color(0xFF339960);
  static const Color success50 = Color(0xFF3FC078);

  static const Color warning30 = Color(0xFF8E570B);
  static const Color warning40 = Color(0xFFBD740F);
  static const Color warning50 = Color(0xFFEC9213);

  static const Color error30 = Color(0xFF891010);
  static const Color error40 = Color(0xFFB71515);
  static const Color error50 = Color(0xFFE51A1A);

  const StateColorScheme({
    required this.error,
    required this.onError,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
  });

  static const light = StateColorScheme(
    error: error30,
    onError: Colors.white,
    success: success30,
    onSuccess: Colors.white,
    warning: warning30,
    onWarning: Colors.black,
  );

  static const dark = StateColorScheme(
    error: error40,
    onError: Colors.white,
    success: success40,
    onSuccess: Colors.white,
    warning: warning40,
    onWarning: Colors.black,
  );

  static const highContrast = StateColorScheme(
    error: error50,
    onError: Colors.white,
    success: success50,
    onSuccess: Colors.white,
    warning: warning50,
    onWarning: Colors.black,
  );

  @override
  StateColorScheme copyWith({
    Color? error,
    Color? onError,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
  }) {
    return StateColorScheme(
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
    );
  }

  @override
  StateColorScheme lerp(ThemeExtension<StateColorScheme>? other, double t) {
    if (other is! StateColorScheme) return this;
    return StateColorScheme(
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}