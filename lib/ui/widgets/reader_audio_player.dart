import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReaderAudioPlayer extends StatelessWidget {
  const ReaderAudioPlayer({super.key});

  String _format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final colors = Theme.of(context).colorScheme;

    return Obx(() {
      if (!audio.hasMedia.value) return const SizedBox.shrink();

      final durationMs = audio.duration.value.inMilliseconds.toDouble();
      final max = durationMs > 0 ? durationMs : 1.0;
      final position = audio.position.value.inMilliseconds.toDouble().clamp(0.0, max).toDouble();
      final artUri = audio.currentArtUri.value;
      final image = artUri == null || artUri.isEmpty ? null : coverImageProvider(artUri);

      return Container(
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primaryContainer, colors.surfaceContainerHighest],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 58,
                      height: 58,
                      child: image == null
                          ? _ArtworkPlaceholder(colors: colors)
                          : Image(image: image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ArtworkPlaceholder(colors: colors)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NOW READING',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          audio.currentTitle.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          audio.currentSubtitle.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Stop audio',
                    onPressed: audio.stop,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: colors.primary,
                  inactiveTrackColor: colors.onSurface.withOpacity(0.12),
                  thumbColor: colors.primary,
                ),
                child: Slider(
                  min: 0,
                  max: max,
                  value: position,
                  onChanged: (value) => audio.seek(Duration(milliseconds: value.toInt())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_format(audio.position.value), style: Theme.of(context).textTheme.labelSmall),
                    Text(_format(audio.duration.value), style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ReaderActionButton(
                    icon: Icons.replay_10_rounded,
                    tooltip: 'Back 10 seconds',
                    onPressed: () => audio.seek(Duration(seconds: (audio.position.value.inSeconds - 10).clamp(0, audio.duration.value.inSeconds).toInt())),
                  ),
                  const SizedBox(width: 8),
                  _ReaderActionButton(
                    icon: Icons.skip_previous_rounded,
                    tooltip: 'Previous track',
                    onPressed: audio.queueLength.value > 1 ? audio.skipToPrevious : null,
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: FilledButton(
                      onPressed: audio.togglePlayPause,
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                      ),
                      child: audio.isLoading.value
                          ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onPrimary))
                          : Icon(audio.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 32),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ReaderActionButton(
                    icon: Icons.skip_next_rounded,
                    tooltip: 'Next track',
                    onPressed: audio.queueLength.value > 1 ? audio.skipToNext : null,
                  ),
                  const SizedBox(width: 8),
                  _ReaderActionButton(
                    icon: Icons.forward_10_rounded,
                    tooltip: 'Forward 10 seconds',
                    onPressed: () => audio.seek(Duration(seconds: (audio.position.value.inSeconds + 10).clamp(0, audio.duration.value.inSeconds).toInt())),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SpeedMenu(audio: audio),
                  const SizedBox(width: 12),
                  _VolumeMenu(audio: audio),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  final ColorScheme colors;

  const _ArtworkPlaceholder({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.primary.withOpacity(0.14),
      child: Icon(Icons.headphones_rounded, color: colors.primary, size: 28),
    );
  }
}

class _ReaderActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ReaderActionButton({required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

class _SpeedMenu extends StatelessWidget {
  final AudioPlayerService audio;

  const _SpeedMenu({required this.audio});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'Playback speed',
      onSelected: audio.setSpeed,
      itemBuilder: (_) => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
          .map((speed) => PopupMenuItem(value: speed, child: Text('${speed}x')))
          .toList(),
      child: Row(
        children: [
          const Icon(Icons.speed_rounded, size: 18),
          const SizedBox(width: 4),
          Text('${audio.speed.value.toStringAsFixed(2)}x'),
        ],
      ),
    );
  }
}

class _VolumeMenu extends StatelessWidget {
  final AudioPlayerService audio;

  const _VolumeMenu({required this.audio});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'Volume',
      onSelected: audio.setVolume,
      itemBuilder: (_) => [0.0, 0.25, 0.5, 0.75, 1.0]
          .map((volume) => PopupMenuItem(value: volume, child: Text('${(volume * 100).round()}%')))
          .toList(),
      child: Row(
        children: [
          Icon(audio.volume.value == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded, size: 18),
          const SizedBox(width: 4),
          Text('${(audio.volume.value * 100).round()}%'),
        ],
      ),
    );
  }
}
