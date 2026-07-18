import 'package:book_store/features/audio_player/controllers/audio_player_controller.dart';
import 'package:get/get.dart';

class AudioPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AudioPlayerController());
  }
}
