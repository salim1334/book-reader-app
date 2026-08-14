import 'package:book_store/core/constants/app_texts.dart';
import 'package:flutter/material.dart';

/// Informational banner that either tells users more books are available
/// online, or reassures them that the author's books are here and they
/// will be notified when new ones are released.
class MoreBooksBanner extends StatelessWidget {
  final bool showMoreBooks;

  const MoreBooksBanner({
    super.key,
    this.showMoreBooks = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            showMoreBooks ? Icons.cloud_download_outlined : Icons.info_outline,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              showMoreBooks
                  ? AppTexts.homeMoreBooksOnline
                  : AppTexts.homeAllBooksHere,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
