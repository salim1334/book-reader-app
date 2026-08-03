import 'dart:io';

import 'package:book_store/core/constants/app_texts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Opens the default email app with a pre-filled feedback message that
  /// includes the app version and device description.
  static Future<bool> openFeedbackEmail() async {
    String appVersion;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (_) {
      appVersion = AppTexts.feedbackVersionFallback;
    }

    String deviceInfo;
    try {
      deviceInfo = await deviceDescription();
    } catch (_) {
      deviceInfo = AppTexts.feedbackDeviceFallback;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: AppTexts.aboutEmail,
      queryParameters: {
        'subject': AppTexts.feedbackEmailSubject,
        'body': AppTexts.feedbackEmailBody(appVersion, deviceInfo),
      },
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }
}
