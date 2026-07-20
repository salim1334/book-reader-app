import 'package:book_store/core/services/audio_player_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A playback‑speed button that displays the current value and opens a popup
/// menu with preset speed options.
class AudioSpeedButton extends StatelessWidget {
  const AudioSpeedButton({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    return Obx(() {
      return _ValuePopupButton<double>(
        icon: Icons.speed_rounded,
        tooltip: 'Playback speed',
        value: audio.speed.value,
        valueLabel: '${audio.speed.value.toStringAsFixed(2)}x',
        items: speeds,
        onSelected: audio.setSpeed,
        itemLabel: (speed) => '${speed}x',
      );
    });
  }
}

/// A volume button that displays the current volume percentage and opens a
/// popup menu with preset volume options.
class AudioVolumeButton extends StatelessWidget {
  const AudioVolumeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerService>();
    const volumes = [0.0, 0.25, 0.5, 0.75, 1.0];

    return Obx(() {
      final volume = audio.volume.value;
      final icon = volume == 0
          ? Icons.volume_off_rounded
          : volume < 0.5
          ? Icons.volume_down_rounded
          : Icons.volume_up_rounded;

      return _ValuePopupButton<double>(
        icon: icon,
        tooltip: 'Volume',
        value: volume,
        valueLabel: '${(volume * 100).round()}%',
        items: volumes,
        onSelected: audio.setVolume,
        itemLabel: (v) => '${(v * 100).round()}%',
      );
    });
  }
}

/// A reusable popup button that displays the current value and opens a
/// styled popup menu with a list of preset options.
class _ValuePopupButton<T> extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final T value;
  final String valueLabel;
  final List<T> items;
  final ValueChanged<T> onSelected;
  final String Function(T) itemLabel;

  const _ValuePopupButton({
    required this.icon,
    required this.tooltip,
    required this.value,
    required this.valueLabel,
    required this.items,
    required this.onSelected,
    required this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      offset: const Offset(0, 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem<T>(
              value: item,
              height: 44,
              child: Row(
                children: [
                  // Selected indicator (checkmark or radio)
                  if (item == value)
                    Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.primary,
                      size: 18,
                    )
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      itemLabel(item),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: item == value
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: item == value
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              valueLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
