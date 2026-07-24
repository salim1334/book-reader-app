import 'package:book_store/data/local/daos/settings_dao.dart';
import 'package:book_store/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  late MockSettingsDao dao;
  late SettingsRepository repository;

  setUp(() async {
    resetGetX();
    dao = MockSettingsDao();
    repository = SettingsRepository(dao: dao);
    when(() => dao.getString(any())).thenAnswer((_) async => null);
    when(() => dao.getBool(any(), defaultValue: any(named: 'defaultValue')))
        .thenAnswer((_) async => false);
    when(() => dao.getDouble(any())).thenAnswer((_) async => null);
  });

  group('SettingsRepository loads defaults', () {
    test('default theme is system', () {
      expect(repository.themeMode.value, ThemeMode.system);
    });

    test('setThemeMode persists and updates reactive value', () async {
      when(() => dao.setString(any(), any())).thenAnswer((_) async {});

      await repository.setThemeMode(ThemeMode.dark);

      expect(repository.themeMode.value, ThemeMode.dark);
      verify(() => dao.setString('theme_mode', 'dark')).called(1);
    });

    test('font size helpers persist values', () async {
      when(() => dao.setString(any(), any())).thenAnswer((_) async {});
      when(() => dao.setDouble(any(), any())).thenAnswer((_) async {});

      await repository.setFontSize('Large');
      expect(repository.fontSize.value, 'Large');
      verify(() => dao.setString('font_size', 'Large')).called(1);

      await repository.setFontSizeSlider(1.5);
      expect(repository.fontSizeScale.value, 1.5);
      verify(() => dao.setDouble('font_size_slider', 1.5)).called(1);
    });

    test('clearCache resets all settings', () async {
      when(() => dao.setBool(any(), any())).thenAnswer((_) async {});
      when(() => dao.setString(any(), any())).thenAnswer((_) async {});
      when(() => dao.setDouble(any(), any())).thenAnswer((_) async {});

      await repository.clearCache();

      expect(repository.themeMode.value, ThemeMode.system);
      expect(repository.fontSize.value, 'Medium');
      expect(repository.offlineMode.value, false);
      verify(() => dao.setString('theme_mode', 'system')).called(1);
      verify(() => dao.setBool('offline_mode', false)).called(1);
    });
  });
}
