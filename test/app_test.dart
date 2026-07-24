import 'package:book_store/app.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'helpers/mocks.dart';
import 'helpers/test_setup.dart';

void main() {
  setupTestBinding();

  testWidgets('App widget builds', (tester) async {
    final settings = MockSettingsRepository();
    when(() => settings.themeMode).thenReturn(ThemeMode.system.obs);
    when(() => settings.hasSeenOnboarding()).thenAnswer((_) async => true);
    Get.put<SettingsRepository>(settings, permanent: true);
    Get.put<AudioPlayerService>(FakeAudioPlayerService(), permanent: true);

    await tester.pumpWidget(const App());

    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
