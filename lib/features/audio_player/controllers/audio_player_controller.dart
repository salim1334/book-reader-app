import 'package:book_store/core/services/audio_player_service.dart';
import 'package:get/get.dart';

class AudioPlayerController extends GetxController {
  final AudioPlayerService audio = Get.find<AudioPlayerService>();

  Future<void> stop() => audio.stop();
}
