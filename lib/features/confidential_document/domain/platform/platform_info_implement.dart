import 'package:leodys/features/confidential_document/domain/platform/platform_enum.dart';
import 'package:leodys/features/confidential_document/domain/platform/platform_info.dart';

import '../../../../common/utils/platform_util.dart';

class FlutterPlatformInfo implements PlatformInfo {
  @override
  PlatformType get platform {
    if (PlatformUtil.isWeb) return PlatformType.web;
    if (PlatformUtil.isAndroid) return PlatformType.android;
    if (PlatformUtil.isWindows) return PlatformType.windows;

    throw UnsupportedError('Platform not supported');
  }
}