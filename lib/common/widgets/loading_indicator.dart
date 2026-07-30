import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  /// Optional text to display below the loader.
  final String? message;

  /// Optional progress value (0.0 – 1.0).
  /// - null or <= 0: circular indeterminate loader.
  /// - > 0 and < 1: linear determinate loader with percentage.
  /// - == 1: success check.
  final double? progress;

  const LoadingIndicator({super.key, this.message, this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = (progress == null || progress! <= 0) ? null : progress;

    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value == null)
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: theme.colorScheme.primary,
                  ),
                )
              else if (value >= 1)
                Icon(
                  Icons.check_circle,
                  size: 52,
                  color: theme.colorScheme.primary,
                )
              else
                SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(value * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (message != null) ...[
                const SizedBox(height: 18),
                Text(
                  message!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
