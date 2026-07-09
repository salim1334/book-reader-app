import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class DeviceUtils {
  DeviceUtils._();

  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;

  static Future<void> setLightStatusBar() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
    );
  }

  static Future<String> deviceDescription() async {
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return '${info.brand} ${info.model} (Android ${info.version.release})';
    }
    if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return '${info.name} ${info.systemName} ${info.systemVersion}';
    }
    return 'Unknown device';
  }
}
