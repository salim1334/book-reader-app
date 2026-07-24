import 'package:book_store/common/widgets/audio_control_buttons.dart';
import 'package:book_store/common/widgets/audio_progress_bar.dart';
import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/asset_url.dart';
import 'package:book_store/data/repositories/book_repository.dart';
import 'package:book_store/features/chapter_reader/presentation/arguments/chapter_reader_args.dart';
import 'package:book_store/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AudioPlayerMode { mini, reader }

class AudioPlayerWidget extends StatelessWidget {
  final AudioPlayerMode mode;

  const AudioPlayerWidget({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);

    return Obx(() {
      if (!audio.hasMedia.value) return const SizedBox.shrink();

      return switch (mode) {
        AudioPlayerMode.mini => _buildMini(context, audio, theme),
        AudioPlayerMode.reader => _buildReader(context, audio, theme),
      };
    });
  }

  // ---------- MINI MODE ----------
  Widget _buildMini(
    BuildContext context,
    AudioPlayerService audio,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(.98),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final book = audio.currentBook;
              final chapter = audio.currentChapter;
              if (book == null || chapter == null) return;

              final progress = await Get.find<BookRepository>()
                  .getReadingProgress(bookId: book.id, chapterId: chapter.id);
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _CoverArt(mode: AudioPlayerMode.mini),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final bookTitle =
                                    audio.currentBook?.title ?? '';
                                final chapterTitle =
                                    audio.currentChapter?.title ?? '';
                                final remaining = _formatRemaining(
                                  audio.duration.value - audio.position.value,
                                );

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      bookTitle,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: .2,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '$chapterTitle • $remaining left',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 11,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                );
                              }),
                            ),
                            const _PlayPauseButton(mode: AudioPlayerMode.mini),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: audio.stop,
                              color: theme.colorScheme.onSurfaceVariant,
                              splashRadius: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const AudioProgressBar(
                          trackHeight: 2,
                          thumbRadius: 0,
                          showTimeLabels: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to format remaining time cleanly as "MM:SS" or "H:MM:SS"
  String _formatRemaining(Duration duration) {
    if (duration.isNegative) return '00:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ---------- READER MODE ----------
  Widget _buildReader(
    BuildContext context,
    AudioPlayerService audio,
    ThemeData theme,
  ) {
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(.98),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AudioProgressBar(showTimeLabels: true),
            SizedBox(height: 6),
            _PlaybackControls(mode: AudioPlayerMode.reader),
            SizedBox(height: 6),
            _ExtraControls(),
          ],
        ),
      ),
    );
  }
}

// ---------- COVER ART ----------
class _CoverArt extends StatelessWidget {
  final AudioPlayerMode mode;

  const _CoverArt({required this.mode});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final isMini = mode == AudioPlayerMode.mini;
    final size = isMini ? 44.0 : 64.0;
    final radius = isMini ? 8.0 : 16.0;

    return Obx(() {
      final uri = audio.currentArtUri.value;
      final provider = uri != null && uri.isNotEmpty
          ? coverImageProvider(uri)
          : null;

      return Hero(
        tag: 'audio_cover_${audio.currentBook?.id ?? 'default'}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: size,
            height: size,
            child: provider != null
                ? Image(
                    image: provider,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _ArtworkPlaceholder(
                          mode: mode,
                          iconSize: isMini ? null : 30,
                        ),
                  )
                : _ArtworkPlaceholder(mode: mode, iconSize: isMini ? null : 30),
          ),
        ),
      );
    });
  }
}

// ---------- PLACEHOLDER ----------
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
          ? colorScheme.primary.withOpacity(0.15)
          : colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          isReader ? Icons.headphones_rounded : Icons.music_note,
          color: isReader ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: iconSize ?? 28,
        ),
      ),
    );
  }
}

// ---------- PLAYBACK CONTROLS ----------
class _PlaybackControls extends StatelessWidget {
  final AudioPlayerMode mode;

  const _PlaybackControls({required this.mode});

  @override
  Widget build(BuildContext context) {
    if (mode == AudioPlayerMode.mini) {
      return const _PlayPauseButton(mode: AudioPlayerMode.mini);
    }

    final audio = Get.find<AudioPlayerService>();

    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            icon: Icons.replay_10_rounded,
            tooltip: 'Back 10s',
            onPressed: () => audio.seek(
              Duration(
                seconds: (audio.position.value.inSeconds - 10).clamp(
                  0,
                  audio.duration.value.inSeconds,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            tooltip: 'Previous chapter',
            onPressed: audio.hasMedia.value ? audio.skipToPrevious : null,
          ),
          const SizedBox(width: 10),
          _PlayPauseButton(mode: mode),
          const SizedBox(width: 10),
          _ControlButton(
            icon: Icons.skip_next_rounded,
            tooltip: 'Next chapter',
            onPressed: audio.hasMedia.value ? audio.skipToNext : null,
          ),
          const SizedBox(width: 4),
          _ControlButton(
            icon: Icons.forward_10_rounded,
            tooltip: 'Forward 10s',
            onPressed: () => audio.seek(
              Duration(
                seconds: (audio.position.value.inSeconds + 10).clamp(
                  0,
                  audio.duration.value.inSeconds,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ---------- CONTROL BUTTON ----------
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      iconSize: 30,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      color: colorScheme.onSurfaceVariant,
      disabledColor: colorScheme.onSurface.withOpacity(0.2),
      splashRadius: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}

// ---------- PLAY/PAUSE BUTTON ----------
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
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
          onPressed: audio.togglePlayPause,
          color: colorScheme.primary,
          splashRadius: 22,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        );
      }

      // Reader mode – large circular button
      return SizedBox(
        width: 60,
        height: 60,
        child: FilledButton(
          onPressed: audio.togglePlayPause,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 4,
            shadowColor: colorScheme.primary.withOpacity(0.3),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 34,
                ),
        ),
      );
    });
  }
}

// ---------- EXTRA CONTROLS (speed + volume) ----------
class _ExtraControls extends StatelessWidget {
  const _ExtraControls();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [AudioSpeedButton(), SizedBox(width: 16), AudioVolumeButton()],
    );
  }
}
