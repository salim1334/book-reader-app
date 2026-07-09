import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppHelper {
  AppHelper._();

  static bool get isDarkMode => Get.isDarkMode;

  static Size screenSize() => Get.size;

  static double screenWidth() => Get.width;

  static double screenHeight() => Get.height;

  static void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future<T?>? toNamed<T>(String route, {dynamic arguments}) {
    return Get.toNamed<T>(route, arguments: arguments);
  }

  static Future<T?>? offAllNamed<T>(String route, {dynamic arguments}) {
    return Get.offAllNamed<T>(route, arguments: arguments);
  }

  static void back<T>({T? result}) => Get.back<T>(result: result);

  static void showSnack(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Notice',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
      colorText: Colors.black87,
      margin: const EdgeInsets.all(16),
    );
  }
}
