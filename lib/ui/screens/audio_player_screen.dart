import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.15),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                _CoverArt(),
                const SizedBox(height: 32),
                _TrackInfo(),
                const SizedBox(height: 32),
                _ProgressBar(),
                const SizedBox(height: 24),
                _PlaybackControls(),
                const SizedBox(height: 24),
                _ExtraControls(),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final size = MediaQuery.of(context).size.width * 0.65;

    return Obx(() {
      final uri = audio.currentArtUri.value;
      ImageProvider? provider;
      if (uri != null && uri.isNotEmpty) {
        provider = coverImageProvider(uri);
      }

      return Hero(
        tag: 'audioCover',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: provider != null
                ? Image(
                    image: provider,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(context, size),
                  )
                : _placeholder(context, size),
          ),
        ),
      );
    });
  }

  Widget _placeholder(BuildContext context, double size) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.music_note,
        size: size * 0.3,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);

    return Obx(() {
      return Column(
        children: [
          Text(
            audio.currentTitle.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            audio.currentSubtitle.value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    });
  }
}

class _ProgressBar extends StatelessWidget {
  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);

    return Obx(() {
      final positionMs = audio.position.value.inMilliseconds.toDouble();
      final durationMs = audio.duration.value.inMilliseconds.toDouble();
      final max = (durationMs > 0 ? durationMs : 1.0).toDouble();
      final value = positionMs.clamp(0.0, max).toDouble();

      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              trackHeight: 4,
            ),
            child: Slider(
              min: 0,
              max: max,
              value: value,
              onChanged: (v) => audio.seek(Duration(milliseconds: v.toInt())),
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _format(audio.position.value),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  _format(audio.duration.value),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _PlaybackControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 36,
            icon: const Icon(Icons.skip_previous),
            onPressed: audio.hasMedia.value ? audio.skipToPrevious : null,
          ),
          const SizedBox(width: 16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              iconSize: 40,
              color: colorScheme.onPrimary,
              icon: audio.isLoading.value
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Icon(audio.isPlaying.value ? Icons.pause : Icons.play_arrow),
              onPressed: audio.togglePlayPause,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            iconSize: 36,
            icon: const Icon(Icons.skip_next),
            onPressed: audio.queueLength.value > 1 ? audio.skipToNext : null,
          ),
        ],
      );
    });
  }
}

class _ExtraControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);

    return Obx(() {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SpeedButton(),
              _VolumeButton(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.speed, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                '${audio.speed.value.toStringAsFixed(1)}x',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 24),
              Icon(Icons.volume_up, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                '${(audio.volume.value * 100).round()}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _SpeedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    return PopupMenuButton<double>(
      icon: const Icon(Icons.speed),
      tooltip: 'Playback speed',
      onSelected: audio.setSpeed,
      itemBuilder: (context) => speeds
          .map((s) => PopupMenuItem(
                value: s,
                child: Text('${s}x'),
              ))
          .toList(),
    );
  }
}

class _VolumeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();

    return PopupMenuButton<double>(
      icon: const Icon(Icons.volume_up),
      tooltip: 'Volume',
      onSelected: audio.setVolume,
      itemBuilder: (context) => [0.0, 0.25, 0.5, 0.75, 1.0]
          .map((v) => PopupMenuItem(
                value: v,
                child: Text('${(v * 100).round()}%'),
              ))
          .toList(),
    );
  }
}
