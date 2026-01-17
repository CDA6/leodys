import 'package:flutter/foundation.dart';

class PlatformUtil
{
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static bool get isWeb => kIsWeb;
}