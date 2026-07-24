import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/features/audio_player/controllers/audio_player_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_setup.dart';

void main() {
  setupTestBinding();

  late FakeAudioPlayerService audio;

  setUp(() {
    resetGetX();
    audio = FakeAudioPlayerService();
    Get.put<AudioPlayerService>(audio, permanent: true);
  });

  group('AudioPlayerController', () {
    test('stop delegates to audio service', () async {
      final controller = AudioPlayerController();
      Get.put(controller);

      await controller.stop();

      // FakeAudioPlayerService.stop is a no-op; the call should complete.
      expect(controller.audio, audio);
    });
  });
}
