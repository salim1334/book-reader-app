import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class SnackbarHelper {
  static void show(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
