import 'package:book_store/core/services/audio_player_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A playback-speed button that displays the current value and opens a popup
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
      itemBuilder: (context) => items
          .map(
            (item) => CheckedPopupMenuItem(
              value: item,
              checked: item == value,
              child: Text(itemLabel(item)),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              valueLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
