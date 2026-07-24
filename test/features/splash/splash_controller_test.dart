import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/splash/controllers/splash_controller.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

class _TestSplashController extends SplashController {
  @override
  Future<void> onReady() async {
    // Skip the 3 second delay in widget tests.
  }
}

void main() {
  setupTestBinding();

  late MockSettingsRepository repository;

  setUp(() {
    resetGetX();
    repository = MockSettingsRepository();
    Get.put<SettingsRepository>(repository, permanent: true);
  });

  Widget buildApp() {
    return GetMaterialApp(
      initialRoute: Routes.splash,
      getPages: [
        GetPage(
          name: Routes.splash,
          page: () => const SizedBox.shrink(),
        ),
        GetPage(
          name: Routes.main,
          page: () => const Scaffold(body: Text('Main')),
        ),
        GetPage(
          name: Routes.onboarding,
          page: () => const Scaffold(body: Text('Onboarding')),
        ),
      ],
    );
  }

  group('SplashController', () {
    testWidgets('navigates to main when onboarding is complete', (tester) async {
      when(() => repository.hasSeenOnboarding()).thenAnswer((_) async => true);

      Get.put<SplashController>(_TestSplashController(), permanent: true);
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final controller = Get.find<SplashController>();
      await controller.navigateNext();
      await tester.pumpAndSettle();

      expect(find.text('Main'), findsOneWidget);
    });

    testWidgets('navigates to onboarding when not complete', (tester) async {
      when(() => repository.hasSeenOnboarding()).thenAnswer((_) async => false);

      Get.put<SplashController>(_TestSplashController(), permanent: true);
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final controller = Get.find<SplashController>();
      await controller.navigateNext();
      await tester.pumpAndSettle();

      expect(find.text('Onboarding'), findsOneWidget);
    });
  });
}
