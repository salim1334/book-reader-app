import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);

    return Obx(() {
      if (!audio.hasMedia.value) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.audioPlayer),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    _MiniCover(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audio.currentTitle.value,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            audio.currentSubtitle.value,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          _MiniProgressBar(),
                        ],
                      ),
                    ),
                    _MiniPlayButton(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: audio.stop,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _MiniCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();

    return Obx(() {
      final uri = audio.currentArtUri.value;
      ImageProvider? provider;
      if (uri != null && uri.isNotEmpty) {
        provider = coverImageProvider(uri);
      }

      return Hero(
        tag: 'audioCover',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 48,
            child: provider != null
                ? Image(
                    image: provider,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stackTrace) => _placeholder(context),
                  )
                : _placeholder(context),
          ),
        ),
      );
    });
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.music_note,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);

    return Obx(() {
      final positionMs = audio.position.value.inMilliseconds.toDouble();
      final durationMs = audio.duration.value.inMilliseconds.toDouble();
      final max = (durationMs > 0 ? durationMs : 1.0).toDouble();

      return LinearProgressIndicator(
        value: positionMs / max,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(2),
      );
    });
  }
}

class _MiniPlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      return IconButton(
        icon: audio.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(audio.isPlaying.value ? Icons.pause : Icons.play_arrow),
        onPressed: audio.togglePlayPause,
        color: colorScheme.primary,
      );
    });
  }
}
