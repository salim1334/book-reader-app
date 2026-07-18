import 'package:book_store/common/widgets/mini_player.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioPlayerOverlay extends StatelessWidget {
  final Widget child;

  const AudioPlayerOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();

    return Column(
      children: [
        Expanded(child: child),
        Obx(() {
          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: audio.hasMedia.value && !audio.isReaderActive.value
                ? const SafeArea(
                    top: false,
                    left: false,
                    right: false,
                    child: MiniPlayer(),
                  )
                : const SizedBox.shrink(),
          );
        }),
      ],
    );
  }
}
