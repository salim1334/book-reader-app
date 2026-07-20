import 'dart:math' as math;

import 'package:book_store/core/services/audio_player_service.dart';
import 'package:book_store/core/utils/duration_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A reusable, theme-aware audio progress bar with drag-state handling.
///
/// It does not rely on [Slider], so it works safely inside widgets that live
/// outside a [Navigator]/[Overlay] (like the persistent mini player).
class AudioProgressBar extends StatefulWidget {
  final double trackHeight;
  final double thumbRadius;
  final bool showTimeLabels;

  const AudioProgressBar({
    super.key,
    this.trackHeight = 4,
    this.thumbRadius = 7,
    this.showTimeLabels = false,
  });

  @override
  State<AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    final theme = Theme.of(context);

    return Obx(() {
      final durationMs = audio.duration.value.inMilliseconds.toDouble();
      final max = durationMs > 0 ? durationMs : 1.0;
      final positionMs = audio.position.value.inMilliseconds.toDouble().clamp(
            0.0,
            max,
          ).toDouble();
      final value = (_dragValue ?? positionMs).clamp(0.0, max).toDouble();

      final bar = LayoutBuilder(
        builder: (context, constraints) {
          return _buildBar(context, constraints.maxWidth, value, max, theme);
        },
      );

      if (!widget.showTimeLabels) return bar;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          bar,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(audio.position.value),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  formatDuration(audio.duration.value),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBar(
    BuildContext context,
    double width,
    double value,
    double max,
    ThemeData theme,
  ) {
    if (!width.isFinite) return const SizedBox.shrink();

    final progress = value / max;
    final thumbDiameter = widget.thumbRadius * 2;
    final minTouchHeight = 32.0;
    final touchHeight = math.max(
      thumbDiameter + widget.trackHeight,
      minTouchHeight,
    );
    final trackTop = (touchHeight - widget.trackHeight) / 2;
    final thumbTop = (touchHeight - thumbDiameter) / 2;
    final thumbLeft = (width * progress) - widget.thumbRadius;

    void updateValue(double dx) {
      final fraction = (dx / width).clamp(0.0, 1.0).toDouble();
      setState(() => _dragValue = fraction * max);
    }

    void endSeek() {
      final target = _dragValue;
      if (target == null) return;
      Get.find<AudioPlayerService>().seek(
        Duration(milliseconds: target.toInt()),
      );
      setState(() => _dragValue = null);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => updateValue(details.localPosition.dx),
      onTap: endSeek,
      onTapCancel: () => setState(() => _dragValue = null),
      onHorizontalDragStart: (details) => updateValue(details.localPosition.dx),
      onHorizontalDragUpdate: (details) => updateValue(details.localPosition.dx),
      onHorizontalDragEnd: (_) => endSeek(),
      onHorizontalDragCancel: () => setState(() => _dragValue = null),
      child: Container(
        height: touchHeight,
        width: double.infinity,
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: trackTop,
              left: 0,
              right: 0,
              child: Container(
                height: widget.trackHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                ),
              ),
            ),
            Positioned(
              top: trackTop,
              left: 0,
              width: width * progress,
              child: Container(
                height: widget.trackHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                ),
              ),
            ),
            if (widget.thumbRadius > 0)
              Positioned(
                top: thumbTop,
                left: thumbLeft,
                child: Container(
                  width: thumbDiameter,
                  height: thumbDiameter,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

