import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'mocks.dart';

/// Shared setup for all tests. Call inside `setUp` or `setUpAll`.
void setupTestBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerMocktailFallbacks();
}

/// Resets the GetX dependency graph between tests.
void resetGetX() {
  Get.reset();
}
