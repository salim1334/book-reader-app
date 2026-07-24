import 'package:book_store/core/services/notification_service.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:book_store/features/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  late MockSettingsRepository repository;
  late MockBookRepository bookRepository;
  late MockNotificationService notificationService;

  setUp(() {
    resetGetX();
    repository = MockSettingsRepository();
    bookRepository = MockBookRepository();
    notificationService = MockNotificationService();

    when(() => repository.themeMode).thenReturn(ThemeMode.system.obs);
    when(() => repository.fontSize).thenReturn('Medium'.obs);
    when(() => repository.fontSizeScale).thenReturn(1.0.obs);
    when(() => repository.autoScroll).thenReturn(true.obs);
    when(() => repository.defaultSpeed).thenReturn(1.0.obs);
    when(() => repository.autoPlayNext).thenReturn(true.obs);
    when(() => repository.offlineMode).thenReturn(false.obs);
    when(() => repository.autoDownload).thenReturn(false.obs);
    when(() => repository.notifyNewBooks).thenReturn(true.obs);
    when(() => repository.notifyUpdates).thenReturn(true.obs);

    Get.put<SettingsRepository>(repository, permanent: true);
    Get.put<BookRepository>(bookRepository, permanent: true);
    Get.put<NotificationService>(notificationService, permanent: true);
  });

  group('SettingsController', () {
    test('setThemeMode delegates to repository', () async {
      when(() => repository.setThemeMode(ThemeMode.dark))
          .thenAnswer((_) async {});

      final controller = SettingsController();
      Get.put(controller);

      await controller.setThemeMode(ThemeMode.dark);

      verify(() => repository.setThemeMode(ThemeMode.dark)).called(1);
    });

    test('updateFontSize maps slider values to labels', () async {
      when(() => repository.setFontSize(any())).thenAnswer((_) async {});
      when(() => repository.setFontSizeSlider(any())).thenAnswer((_) async {});

      final controller = SettingsController();
      Get.put(controller);

      controller.updateFontSize(0.8);
      verify(() => repository.setFontSize('Small')).called(1);

      controller.updateFontSize(1.2);
      verify(() => repository.setFontSize('Medium')).called(1);

      controller.updateFontSize(1.5);
      verify(() => repository.setFontSize('Large')).called(1);
    });

    test('toggle switches delegate to repository', () async {
      when(() => repository.setAutoScroll(any())).thenAnswer((_) async {});
      when(() => repository.setAutoPlayNext(any())).thenAnswer((_) async {});
      when(() => repository.setOfflineMode(any())).thenAnswer((_) async {});
      when(() => repository.setAutoDownload(any())).thenAnswer((_) async {});
      when(() => repository.setNotifyNewBooks(any())).thenAnswer((_) async {});
      when(() => repository.setNotifyUpdates(any())).thenAnswer((_) async {});

      final controller = SettingsController();
      Get.put(controller);

      controller.toggleAutoScroll(false);
      verify(() => repository.setAutoScroll(false)).called(1);

      controller.toggleOfflineMode(true);
      verify(() => repository.setOfflineMode(true)).called(1);

      controller.toggleNotifyNewBooks(false);
      verify(() => repository.setNotifyNewBooks(false)).called(1);
    });

    test('testNotification sends notification', () async {
      when(() => notificationService.showTestNotification())
          .thenAnswer((_) async {});

      final controller = SettingsController();
      Get.put(controller);

      await controller.testNotification();

      verify(() => notificationService.showTestNotification()).called(1);
    });
  });
}
