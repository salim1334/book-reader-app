import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  /// Optional text to display below the spinner.
  final String? message;

  /// Optional progress value (0.0 – 1.0) for a determinate indicator.
  /// If null, an indeterminate spinner is shown.
  final double? progress;

  const LoadingIndicator({super.key, this.message, this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spinner or determinate progress ring
              progress != null
                  ? SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                    )
                  : const SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(strokeWidth: 5),
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
