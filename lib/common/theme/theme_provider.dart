import 'package:flutter/material.dart';

/// Interface pour fournir un thème à l'application.
abstract class ThemeProvider {
  ThemeData getTheme();
}