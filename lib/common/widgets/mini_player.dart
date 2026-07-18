import 'package:book_store/common/widgets/audio_player_widget.dart';
import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const AudioPlayerWidget(mode: AudioPlayerMode.mini);
  }
}
