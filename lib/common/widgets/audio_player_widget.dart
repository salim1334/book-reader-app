import 'package:book_store/common/widgets/audio_control_buttons.dart';
import 'package:book_store/common/widgets/audio_progress_bar.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The visual mode used by [AudioPlayerWidget].
enum AudioPlayerMode {
  /// Compact bar shown at the bottom of most screens.
  mini,

  /// Embedded card shown inside the chapter reader.
  reader,
}

/// A single, adaptive audio player UI that renders as a mini bar or an
/// embedded reader card depending on [mode].
class AudioPlayerWidget extends StatelessWidget {
  final AudioPlayerMode mode;

  const AudioPlayerWidget({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);

    return Obx(() {
      if (!audio.hasMedia.value) {
        return const SizedBox.shrink();
      }

      return switch (mode) {
        AudioPlayerMode.mini => _buildMini(context, audio, theme),
        AudioPlayerMode.reader => _buildReader(context, audio, theme),
      };
    });
  }

  Widget _buildMini(
    BuildContext context,
    AudioPlayerService audio,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () async {
        final book = audio.currentBook;
        final chapter = audio.currentChapter;
        if (book == null || chapter == null) return;

        final progress = await Get.find<BookRepository>().getReadingProgress(
          bookId: book.id,
          chapterId: chapter.id,
        );

        final lastPageIndex =
            (progress?['last_page_index'] as num?)?.toInt() ?? 0;

        Get.toNamed(
          Routes.chapterReader,
          arguments: ChapterReaderArgs(
            book: book,
            chapter: chapter,
            initialPageIndex: lastPageIndex,
            initialPositionMs: audio.position.value.inMilliseconds,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.95,
          ),
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
                  const _CoverArt(mode: AudioPlayerMode.mini),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _TrackInfo(mode: AudioPlayerMode.mini),
                        const SizedBox(height: 6),
                        const AudioProgressBar(
                          trackHeight: 3,
                          thumbRadius: 0,
                          showTimeLabels: false,
                        ),
                      ],
                    ),
                  ),
                  const _PlayPauseButton(mode: AudioPlayerMode.mini),
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
  }

  Widget _buildReader(
    BuildContext context,
    AudioPlayerService audio,
    ThemeData theme,
  ) {
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primaryContainer, colors.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // only border radius for top right and top left
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          children: [
            // Row(
            //   children: [
            //     const _CoverArt(mode: AudioPlayerMode.reader),
            //     const SizedBox(width: 12),
            //     const Expanded(child: _TrackInfo(mode: AudioPlayerMode.reader)),
            //     IconButton(
            //       tooltip: 'Stop audio',
            //       onPressed: audio.stop,
            //       icon: const Icon(Icons.close_rounded),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),
            const AudioProgressBar(showTimeLabels: true),
            const SizedBox(height: 4),
            const _PlaybackControls(mode: AudioPlayerMode.reader),
            const SizedBox(height: 2),
            const _ExtraControls(),
          ],
        ),
      ),
    );
  }
}

class _CoverArt extends StatelessWidget {
  final AudioPlayerMode mode;

  const _CoverArt({required this.mode});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final isMini = mode == AudioPlayerMode.mini;
    final size = isMini ? 48.0 : 58.0;
    final radius = isMini ? 8.0 : 14.0;

    return Obx(() {
      final uri = audio.currentArtUri.value;
      final provider = uri != null && uri.isNotEmpty
          ? coverImageProvider(uri)
          : null;

      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: provider != null
              ? Image(
                  image: provider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ArtworkPlaceholder(
                    mode: mode,
                    iconSize: isMini ? null : 28.0,
                  ),
                )
              : _ArtworkPlaceholder(mode: mode, iconSize: isMini ? null : 28.0),
        ),
      );
    });
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  final AudioPlayerMode mode;
  final double? iconSize;

  const _ArtworkPlaceholder({required this.mode, this.iconSize});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReader = mode == AudioPlayerMode.reader;

    return Container(
      color: isReader
          ? colorScheme.primary.withValues(alpha: 0.14)
          : colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          isReader ? Icons.headphones_rounded : Icons.music_note,
          color: isReader ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: iconSize,
        ),
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  final AudioPlayerMode mode;

  const _TrackInfo({required this.mode});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);

    return Obx(() {
      final title = audio.currentTitle.value;
      final subtitle = audio.currentSubtitle.value;
      final isMini = mode == AudioPlayerMode.mini;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMini)
            Text(
              'NOW READING',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          if (!isMini) const SizedBox(height: 4),
          Text(
            title,
            style: isMini
                ? theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    });
  }
}

class _PlaybackControls extends StatelessWidget {
  final AudioPlayerMode mode;

  const _PlaybackControls({required this.mode});

  @override
  Widget build(BuildContext context) {
    if (mode == AudioPlayerMode.mini) {
      return const _PlayPauseButton(mode: AudioPlayerMode.mini);
    }

    final audio = Get.find<AudioPlayerService>();
    final compact = mode == AudioPlayerMode.reader;

    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            icon: Icons.replay_10_rounded,
            tooltip: 'Back 10 seconds',
            onPressed: () => audio.seek(
              Duration(
                seconds: (audio.position.value.inSeconds - 10)
                    .clamp(0, audio.duration.value.inSeconds)
                    .toInt(),
              ),
            ),
          ),
          SizedBox(width: compact ? 8 : 8),
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            tooltip: 'Previous',
            onPressed: audio.hasMedia.value ? audio.skipToPrevious : null,
          ),
          SizedBox(width: compact ? 10 : 16),
          _PlayPauseButton(mode: mode),
          SizedBox(width: compact ? 10 : 16),
          _ControlButton(
            icon: Icons.skip_next_rounded,
            tooltip: 'Next',
            onPressed: audio.queueLength.value > 1 ? audio.skipToNext : null,
          ),
          SizedBox(width: compact ? 8 : 8),
          _ControlButton(
            icon: Icons.forward_10_rounded,
            tooltip: 'Forward 10 seconds',
            onPressed: () => audio.seek(
              Duration(
                seconds: (audio.position.value.inSeconds + 10)
                    .clamp(0, audio.duration.value.inSeconds)
                    .toInt(),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      iconSize: 32,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      color: colorScheme.onSurfaceVariant,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.2),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final AudioPlayerMode mode;

  const _PlayPauseButton({required this.mode});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isLoading = audio.isLoading.value;
      final isPlaying = audio.isPlaying.value;

      if (mode == AudioPlayerMode.mini) {
        return IconButton(
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: audio.togglePlayPause,
          color: colorScheme.primary,
        );
      }

      if (mode == AudioPlayerMode.reader) {
        return SizedBox(
          width: 58,
          height: 58,
          child: FilledButton(
            onPressed: audio.togglePlayPause,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 32,
                  ),
          ),
        );
      }

      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IconButton(
          iconSize: 40,
          color: colorScheme.onPrimary,
          icon: isLoading
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
          onPressed: audio.togglePlayPause,
        ),
      );
    });
  }
}

class _ExtraControls extends StatelessWidget {
  const _ExtraControls();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [AudioSpeedButton(), SizedBox(width: 12), AudioVolumeButton()],
    );
  }
}
