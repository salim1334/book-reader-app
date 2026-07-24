import 'package:book_store/core/theme/sacred_theme_extension.dart';
import 'package:book_store/core/utils/extensions/theme_extension.dart';
import 'package:book_store/data/local/models/book_local_models.dart';
import 'package:flutter/material.dart';

class ChapterListTile extends StatelessWidget {
  final int index;
  final LocalChapter chapter;
  final double progress;
  final double downloadProgress;
  final bool isOutdated;
  final bool isDownloading;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const ChapterListTile({
    super.key,
    required this.index,
    required this.chapter,
    required this.progress,
    this.downloadProgress = 0.0,
    required this.isOutdated,
    required this.isDownloading,
    this.isFavorite = false,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Amharic subtitle fallbacks
    final subtitleText = chapter.description ??
        (chapter.isDownloaded ? 'ወርዷል' : 'ለማውረድ ይጫኑ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Index badge
                _IndexBadge(index: index + 1),
                const SizedBox(width: 14),

                // Title, description, and reading progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chapter.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Reading progress bar
                      if (chapter.isDownloaded && progress > 0) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            color: theme.colorScheme.primary,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(progress * 100).round()}% ተጠናቋል',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action controls (Favorite & Download)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorite
                            ? context.sacred.gold
                            : theme.colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      onPressed: onFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      splashRadius: 18,
                    ),
                    const SizedBox(height: 4),

                    if (isDownloading)
                      _DownloadIndicator(progress: downloadProgress)
                    else
                      IconButton(
                        icon: Icon(
                          chapter.isDownloaded
                              ? (isOutdated
                                  ? Icons.update
                                  : Icons.check_circle_outline)
                              : Icons.cloud_download_outlined,
                          color: chapter.isDownloaded
                              ? (isOutdated
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary)
                              : theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        onPressed: onTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        splashRadius: 18,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Sub-components ----

class _IndexBadge extends StatelessWidget {
  final int index;

  const _IndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.7),
            theme.colorScheme.primary,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$index',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _DownloadIndicator extends StatelessWidget {
  final double progress;

  const _DownloadIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            color: theme.colorScheme.primary,
          ),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}